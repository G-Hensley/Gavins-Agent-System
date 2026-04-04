# Eval Criteria — RAG System

Scoring: 0 = missed, 1 = partial, 2 = full credit. Maximum score: 16 points (8 criteria × 2).

---

## 1. Dispatch Correctness

**Full credit (2):** All required agents dispatched in the correct order:
- `architect` → produces design doc before implementation begins
- `architecture-reviewer` → reviews design doc before implementation
- `threat-modeler` → dispatched after architect, before implementation
- `ai-engineer` → implements embedding, retrieval, and Claude prompt integration
- `database-engineer` → designs and implements the vector store schema and similarity query
- `plan-reviewer` → reviews implementation plan before work starts

**Partial (1):** At least 4 of the 6 agents dispatched, with `architect` appearing before `ai-engineer` and `database-engineer`.

**Zero (0):** Implementation begins without a design doc, or `architect` is skipped entirely.

---

## 2. Architecture Produced Before Implementation

**Full credit (2):** A design document exists and was produced before any implementation code. It must include:
- Component diagram or description (indexer CLI, query CLI, shared library, vector store)
- Embedding model selection with rationale (Claude embeddings vs. local model vs. OpenAI)
- Chunking strategy (chunk size, overlap, rationale)
- Vector store design (schema: id, file_path, chunk_index, text, embedding; similarity query approach)
- Idempotency strategy for the indexer (how changed vs. unchanged files are detected — e.g., content hash)
- Prompt template structure for the final Claude call

**Partial (1):** Design doc exists but is missing 2 or more of the above elements, or produced after implementation started.

**Zero (0):** No design doc, or a stub without architectural decisions.

---

## 3. Architecture Reviewed

**Full credit (2):** `architecture-reviewer` dispatched after design doc exists and before implementation begins. Review output identifies at least one real concern (e.g., cosine similarity in SQLite requires loading all embeddings into memory — doesn't scale, no chunking strategy for very large files, idempotency check based on file mtime is unreliable across filesystems, API rate limiting not addressed for large corpora, embedding model not versioned so index is silently stale if model changes).

**Partial (1):** Reviewer dispatched but review is superficial — no specific RAG or vector store concerns identified.

**Zero (0):** `architecture-reviewer` not dispatched.

---

## 4. Threat Model Produced

**Full credit (2):** `threat-modeler` dispatched after architect and output includes at least 3 specific threats relevant to this system with mitigations:
- Prompt injection via document content (malicious markdown instructs Claude to ignore context)
- API key exposure (key in `.env` committed to git or logged)
- Indirect prompt injection (attacker controls indexed documents to manipulate answers)
- Denial of service via large document corpus exhausting API quota
- Data leakage (retrieved context from confidential documents returned to unauthorized callers)

At least 3 of the above (or equivalents) must appear with mitigations.

**Partial (1):** Threat model produced but covers fewer than 3 threats, or threats are generic and not specific to RAG/LLM systems.

**Zero (0):** `threat-modeler` not dispatched.

---

## 5. Plan Reviewed

**Full credit (2):** `plan-reviewer` dispatched after the implementation plan exists and before work begins. Review output notes at least one issue (e.g., no plan for handling embedding API failures during indexing, no retry logic specified, `--sources` flag behavior undefined when a chunk appears multiple times, no test plan for the vector similarity function).

**Partial (1):** `plan-reviewer` dispatched but review confirms plan without specific observations.

**Zero (0):** `plan-reviewer` not dispatched.

---

## 6. TDD Compliance

**Full credit (2):** Tests written before implementation for all of the following:
- Chunking logic — given a string and chunk/overlap sizes, returns correct segments with correct overlap
- Cosine similarity ranking — given a query embedding and a list of candidate embeddings, returns top-K in correct order
- Prompt assembly — given a question and a list of context chunks, produces a prompt string matching the expected template

Each test must have been run and failed before the implementation it covers was written.

**Partial (1):** Tests exist for at least 2 of the 3 functions, with evidence they were written before implementation (test file created before source file, or test committed separately before source).

**Zero (0):** Tests missing for 2 or more of the above functions, or tests only run the CLI end-to-end without unit-testing core logic.

---

## 7. Output Quality

**Full credit (2):** All of the following are true when run against a sample markdown directory:
- Indexer runs to completion without errors, populates the vector store, and is idempotent (second run on same directory produces no duplicate entries)
- Query CLI returns a coherent answer grounded in the indexed documents
- `--sources` flag prints source file name and chunk text for each retrieved passage
- Configuration (model, DB path, chunk size) is read from environment variables with no hardcoded values

**Partial (1):** Indexer and query CLI run, but idempotency is broken, `--sources` is missing, or one config value is hardcoded.

**Zero (0):** Either the indexer or the query CLI does not run to completion.

---

## 8. Review Quality

**Full credit (2):** `architecture-reviewer` and `threat-modeler` together surface at least two distinct, non-trivial issues that are either fixed before delivery or explicitly accepted with documented rationale. Issues must be specific to the RAG domain — not generic Python style concerns.

Qualifying findings: prompt injection risk from document content, no rate limiting on embedding API calls during indexing, embedding model version not stored in the index making it silently invalid after an upgrade, cosine similarity implementation not normalized (produces incorrect rankings).

**Partial (1):** One qualifying finding identified across all reviewers.

**Zero (0):** Reviewers dispatched but produce only generic findings, or are not dispatched.

---

## Passing Bar

**Pass:** Score ≥ 12 / 16 with no zero on criterion 2 (Architecture Produced) or criterion 4 (Threat Model Produced).

**Fail:** Score < 12, or a zero on criterion 2 or 4 — implementation without an architecture or threat model is a hard failure for Tier 3.
