# RAG Engineering

Retrieval-Augmented Generation grounds LLM responses in a corpus you control. The production pipeline is not "embed → retrieve → inject" — reranking is a first-class stage and skipping it is the single most common cause of silent quality degradation. Every stage has defaults that work and traps that look like they work.

---

## High-Level Flow

```
embed → index
           ↓
query → rewrite → retrieve (dense + sparse) → RRF → rerank → inject → generate → cite
```

1. **Embed** — chunk documents and store vectors at index time
2. **Rewrite** — expand or transform the query before retrieval
3. **Retrieve** — dense (vector ANN) + sparse (BM25) → fuse with RRF, initial K = 20–50
4. **Rerank** — cross-encoder scores all K candidates → keep N = 3–5 for injection
5. **Inject** — order chunks for the LLM (see context optimization below)
6. **Generate** — LLM receives system prompt + ordered chunks + user query
7. **Cite** — surface chunk source IDs in the response for faithfulness tracing

---

## Chunking Strategies

| Strategy | How it works | Use when |
|---|---|---|
| **Fixed-size** | Split by token count, optional overlap | Simple corpus, homogeneous format, fast indexing |
| **Semantic** | Split at embedding-distance breakpoints | Unstructured prose where sentences span topics |
| **Structural / heading-aware** | Split at markdown or HTML headings | **Documentation, wikis, knowledge bases — this is the default** |
| **Parent-child (small-to-big)** | Index small child chunks; retrieve parent chunk for context | Dense reference material where surrounding context clarifies meaning |
| **Contextual retrieval** | Prepend LLM-generated chunk summary to each chunk before embedding (Anthropic, 2024) | High-quality corpus where index-time cost is acceptable; improves recall measurably |

**Decision rule:**
- Structural/heading-aware is the default for documentation and knowledge bases.
- Parent-child is the default for technical references with dense terminology.
- Contextual retrieval is recommended-when-affordable, not default — costs one LLM call per chunk at index time.
- Overlap 10–20% of chunk size on fixed-size splits to prevent context truncation at boundaries.
- Target 256–512 tokens per chunk for most embedding models; smaller for parent-child child chunks (64–128 tokens).

---

## Retrieval Strategy

**Hybrid (dense + sparse + RRF) is the production default.** Dense-only quietly underperforms on exact-term queries (product names, error codes, version strings, identifiers). Sparse-only misses semantic paraphrases. Neither alone is production-grade.

| Mode | Strengths | Acceptable when |
|---|---|---|
| **Hybrid (default)** | Handles semantic + exact-term queries | Always — start here |
| **Dense-only** | Simpler infra, good for purely conceptual corpora | Corpus has no exact-term queries and infra cannot run BM25 |
| **Sparse-only** | Exact-term precision, keyword search | Corpus is structured records (logs, code); semantic similarity adds noise |

**Reciprocal Rank Fusion (RRF)** normalizes scores across ranking lists without requiring score calibration:

```python
def rrf(dense_hits: list[str], sparse_hits: list[str], k: int = 60) -> list[str]:
    scores: dict[str, float] = {}
    for rank, doc_id in enumerate(dense_hits, start=1):
        scores[doc_id] = scores.get(doc_id, 0.0) + 1.0 / (k + rank)
    for rank, doc_id in enumerate(sparse_hits, start=1):
        scores[doc_id] = scores.get(doc_id, 0.0) + 1.0 / (k + rank)
    return sorted(scores, key=lambda d: scores[d], reverse=True)
```

`k=60` is the standard default. A document that ranks highly in both lists accumulates score from both terms. No score normalization required.

---

## Query Rewriting

The user's raw query is often the worst possible retrieval signal. Rewrite before issuing retrieval calls.

| Technique | How it works | Use when |
|---|---|---|
| **HyDE** (Hypothetical Document Embeddings) | Generate a hypothetical ideal answer; embed that answer; retrieve against it | Queries phrased as questions; the corpus contains answers, not questions |
| **Query expansion** | Generate N alternate phrasings; retrieve against all; RRF the merged results | Short or ambiguous queries; multilingual corpora |
| **Sub-question decomposition** | Decompose a complex query into independent sub-questions; retrieve for each | Multi-hop questions that require synthesizing across documents |

```python
def hyde(query: str) -> str:
    hypothetical = llm.call(
        f"Write a paragraph that would answer this question: {query}\n"
        "Answer directly as if you are an expert. Do not hedge."
    )
    return hypothetical  # embed this, not the original query

def expand_query(query: str, n: int = 3) -> list[str]:
    phrasings = llm.call(
        f"Generate {n} alternate phrasings of this query: {query}\n"
        "Return one per line."
    ).splitlines()
    return [query] + phrasings[:n]
```

**Decision rule:** HyDE is the highest-value single technique for question-answering RAG. Query expansion adds cost but improves recall on ambiguous or short queries. Sub-question decomposition is needed only when a single retrieval pass cannot cover all facets of the question.

---

## Reranking

Cosine similarity scores proximity in embedding space — it does not score usefulness to the query. Initial retrieval with K = 20–50 casts a wide net; a cross-encoder reranks candidates with full query-document attention.

**The latency cost is worth it.** A cross-encoder rerank adds 50–200 ms for K = 50 candidates. The quality improvement from 20 mixed chunks to 3–5 well-ranked chunks consistently reduces hallucination and improves faithfulness scores. Do not skip reranking to save latency without measuring the quality cost.

| Model | Characteristics |
|---|---|
| **Cohere Rerank** | Hosted API; fast; good multilingual coverage |
| **BGE Reranker** | Open-source (BAAI/bge-reranker-v2-m3); strong performance; self-hostable |
| **ms-marco-MiniLM** | Lightweight; lower latency; good for high-throughput use cases |

```python
def rerank(query: str, candidates: list[str], top_n: int = 5) -> list[str]:
    scores = cross_encoder.predict([(query, doc) for doc in candidates])
    ranked = sorted(zip(candidates, scores), key=lambda x: x[1], reverse=True)
    return [doc for doc, _ in ranked[:top_n]]
```

**Defaults:** initial K = 20–50; rerank to N = 3–5. Increase K if recall metrics are low; increase N only after verifying the LLM handles additional context (see context optimization below).

---

## Evaluation Split

RAG has two independent failure modes: bad retrieval and bad generation. Conflating them makes debugging impossible. Evaluate them separately.

### Retrieval metrics

| Metric | What it measures |
|---|---|
| **Precision@K** | Fraction of the top K retrieved chunks that are relevant |
| **Recall@K** | Fraction of all relevant chunks that appear in the top K |
| **MRR** (Mean Reciprocal Rank) | How far down the ranked list the first relevant chunk appears |

Retrieval metrics require a labeled ground-truth set: query → expected chunk IDs. Build this once from a sample of real queries; expand it when retrieval failures surface in production.

### Generation metrics

| Metric | What it measures |
|---|---|
| **Faithfulness / groundedness** | Does the answer contain only claims supported by the retrieved chunks? |
| **Relevance** | Does the answer address the query? |
| **Completeness** | Does the answer cover all aspects the chunks support? |

### Tools

- **RAGAS** — framework for automated RAG evaluation; built-in faithfulness, answer relevance, context precision/recall metrics
- **TruLens** — evaluation + tracing with RAG-specific feedback functions
- **DeepEval** — pytest-style assertions on LLM outputs; supports custom metrics
- **Custom LLM-as-judge** — cheap and fast for faithfulness: send (query, answer, chunks) to a judge LLM with a structured scoring rubric; output pass/fail + reason

**Decision rule:** automate faithfulness checks on every eval run — it is the most common failure mode and easiest to catch with LLM-as-judge. Retrieval metrics should gate index and chunking changes. For eval framework depth, see `./evaluation-and-observability.md`.

---

## Context Optimization for the LLM

**Fewer, higher-quality chunks beat many mixed chunks.** 3–5 high-quality retrieved chunks consistently outperform 10–15 mixed ones. Irrelevant context degrades answers more than missing relevant context.

**Lost in the middle:** models attend most to the beginning and end of the context window. Chunks placed in the middle receive systematically less attention regardless of relevance. Place the highest-relevance chunks at positions 1 and N, not in the middle. For 5 chunks, put ranks 1 and 2 at positions 1 and 5, ranks 3–5 in between.

**Context compression:** before injection, strip boilerplate and extract only the sentences relevant to the query. This is optional but reduces token cost and sharpens signal.

For token budget allocation, window sizing, and the compression code pattern, see `./context-management.md`.

For vector poisoning and adversarial document attacks against the retrieval index, see `./llm-security.md`.
