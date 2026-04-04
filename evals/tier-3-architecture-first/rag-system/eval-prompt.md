Build a RAG (Retrieval-Augmented Generation) system that lets me ask questions about a folder of markdown documents.

The system has two parts:

**Indexer** — a CLI tool that takes a directory of `.md` files and builds a vector index from them. It should:
- Chunk each document into overlapping segments (configurable chunk size and overlap)
- Generate embeddings for each chunk using the Claude API (or a local embedding model — your choice, document the decision)
- Store the embeddings and their source metadata (file name, chunk index, raw text) in a vector store. SQLite with a simple cosine similarity search is fine; pgvector or Chroma are also acceptable.
- Be idempotent — re-running on the same directory should update changed files and skip unchanged ones

**Query CLI** — a CLI tool that takes a question as a string argument and:
- Embeds the question using the same model as the indexer
- Retrieves the top-K most relevant chunks (K configurable, default 5)
- Sends the question and retrieved context to Claude (claude-3-5-haiku or similar) with a prompt that instructs it to answer based only on the provided context
- Prints the answer and, with a `--sources` flag, prints the source file and chunk for each retrieved passage

The system should be built in Python. Configuration (API key, model name, DB path, chunk size) should come from environment variables or a `.env` file — nothing hardcoded.

Write tests for the chunking logic, the cosine similarity ranking, and the prompt assembly function. The indexer and query CLI can share a library module for embedding and retrieval.
