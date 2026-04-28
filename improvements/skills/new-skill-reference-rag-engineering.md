# New skill reference: RAG engineering

## What I Observed

The existing AI engineering material treats RAG as one line ("embed → retrieve → inject → generate → cite"). Production RAG has depth at every stage and the choices interact. The single line is fine as a high-level orientation; it is wholly insufficient as guidance for building or reviewing a real RAG system.

Missing depth:

**Chunking** — fixed-size, semantic, structural/heading-aware, parent-child (small-to-big), contextual retrieval (Anthropic 2024). Different document types want different strategies; the choice meaningfully changes retrieval quality.

**Retrieval strategy** — dense (vector) is great for semantic queries and bad for exact terms; sparse (BM25) is the inverse. Hybrid with Reciprocal Rank Fusion is the production default. The skill should state this default explicitly.

**Query rewriting** — HyDE (hypothetical doc embeddings), query expansion (multiple phrasings), sub-question decomposition. None of these are obvious without prior exposure.

**Reranking** — initial K=20–50, rerank to N=3–5 with a cross-encoder (Cohere Rerank, BGE Reranker, ms-marco-MiniLM). Cosine similarity rewards proximity, not usefulness.

**Evaluation** — separate retrieval metrics (Precision@K, Recall@K, MRR) from generation metrics (faithfulness/groundedness, relevance, completeness). Tools: RAGAS, TruLens, DeepEval, or custom LLM-as-judge.

## Why It Would Help

- RAG is the most common production AI pattern after raw chat completions. The operator's existing customers and projects will hit it.
- Hybrid retrieval as the production default is a key correction — many implementations ship with dense-only and quietly underperform on exact-term queries (product names, error codes, IDs).
- Reranking is the single highest-leverage quality improvement and is consistently skipped because it adds latency. The reference should state explicitly that the latency is worth it.
- Eval splits matter — without separating retrieval from generation, you can't tell if the bug is in your index or your prompt.

## Proposal

Create `skills/ai-engineering/references/rag-engineering.md` with sections:

- High-level flow (embed → retrieve → rerank → inject → generate → cite) — with rerank as a first-class stage
- Chunking strategies (5 strategies, when to use each, with structural/heading-aware as default for documentation)
- Retrieval strategy (hybrid as default, RRF code snippet, when dense-only or sparse-only is acceptable)
- Query rewriting (HyDE, expansion, sub-question decomposition — when each helps)
- Reranking (K and N defaults, cross-encoder models, latency tradeoff stated explicitly)
- Evaluation split (retrieval metrics vs. generation metrics, tool list, LLM-as-judge prompt template)
- Context optimization for the LLM (3–5 chunks beats 10–15, "lost in the middle" — links to context-management ref)

Update `agents/ai-engineer.md` to load this when RAG-related code is detected (vector DB clients, embeddings APIs, retrieval libraries, etc.).

## Open questions for review

- This is a candidate for a sub-skill (`ai-engineering/rag/`) with its own SKILL.md if it grows beyond ~200 lines. Start as a single ref; promote if needed.
- Should the operator standardize a default vector DB? AWS context suggests OpenSearch / pgvector / Pinecone are the candidates; the ref should mention defaults but not enforce.
- Contextual retrieval (Anthropic) is expensive at index time but improves quality. Should it be the documented default? Recommended-when-affordable, not default — the cost story is real.
