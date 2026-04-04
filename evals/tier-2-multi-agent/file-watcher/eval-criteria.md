# Eval Criteria: File Watcher with CI (Tier 2 — Multi-Agent Handoff)

Target agents: `automation-engineer` → `devops-engineer`
Max score: 12 (6 dimensions × 0–2)

---

## 1. Dispatch Correctness (0–2)

**What to check:**
- `automation-engineer` is dispatched first to build the watcher script
- `devops-engineer` is dispatched after the watcher is complete to build the GitHub Actions workflow
- The orchestrator does not write CI YAML directly without dispatching `devops-engineer`
- The orchestrator does not write `watcher.py` directly without dispatching `automation-engineer`

**Scoring:**
- 2 — Both agents dispatched in correct order; each agent owns its domain
- 1 — Both agents dispatched but order is reversed, or one agent produces artifacts in the other's domain
- 0 — Only one agent dispatched, or neither used

---

## 2. Handoff Quality (0–2)

**What to check:**
- When `devops-engineer` is dispatched, it receives: the trigger mechanism the watcher uses (e.g., `workflow_dispatch` API call), the required environment variables, and what the workflow is expected to do
- The GitHub Actions workflow file matches the trigger mechanism produced by `automation-engineer` — the `workflow_dispatch` event name and inputs align
- No mismatch between what the watcher dispatches and what the workflow listens for

**Scoring:**
- 2 — Watcher output explicitly handed off to `devops-engineer`; workflow event configuration matches watcher's dispatch call
- 1 — Handoff occurs but is incomplete — some context missing, causing the workflow to be slightly misaligned (e.g., wrong event name or missing inputs)
- 0 — No handoff; `devops-engineer` invents the workflow independently without knowing what the watcher produces

---

## 3. Design-First Compliance (0–2)

**What to check:**
- Before writing `watcher.py`, there is a brief design step: what events to capture, the debounce strategy, the trigger interface (env vars, API shape)
- The CI workflow is designed (what it runs, what secrets it needs, trigger config) before the YAML is written
- Design does not need to be a formal document — a clear plan stated before implementation counts

**Scoring:**
- 2 — Both the script and the workflow have a stated design/plan before implementation
- 1 — One of the two has a design step; the other jumps straight to implementation
- 0 — No design step for either component

---

## 4. TDD Compliance (0–2)

**What to check:**
- Tests for debounce logic are written and confirmed failing before `watcher.py` is implemented
- Tests for event classification (distinguish create vs. modify events) are written before implementation
- Both test cases are confirmed passing before the CI integration work begins
- The GitHub Actions workflow is not unit-tested (infra config — acceptable exception)

**Scoring:**
- 2 — Tests for both debounce and event classification written first, watched fail, then implemented
- 1 — Tests exist but written after implementation, or only one of the two behaviors is tested
- 0 — No tests, or tests only cover the GitHub API call (not the core logic)

---

## 5. Output Quality (0–2)

**What to check:**
- `watcher.py` accepts a target directory as an argument and validates it exists before starting
- Debounce is implemented (not just a comment or TODO)
- `--dry-run` flag suppresses all side effects but still logs what would happen
- Structured log output includes timestamp, file path, event type, and trigger result
- Script handles SIGINT/SIGTERM cleanly (no stack trace on Ctrl-C)
- `.env.example` documents `GITHUB_TOKEN`, `GITHUB_REPO`, and `GITHUB_WORKFLOW` (or equivalent)
- GitHub Actions workflow file is valid YAML with `workflow_dispatch` trigger and at least one meaningful job step

**Scoring:**
- 2 — All seven checks pass
- 1 — 4–6 checks pass; one major item missing (e.g., no dry-run, no signal handling, or invalid workflow YAML)
- 0 — Fewer than 4 checks pass; script is a stub or workflow is absent

---

## 6. Agent-Specific Rules (0–2)

**What to check:**
- `automation-engineer`: idempotent design, dry-run mode, structured logging, no hardcoded paths or credentials, meaningful exit codes (0 = clean stop, non-zero = startup failure)
- `devops-engineer`: least-privilege GitHub Actions permissions (`contents: read` or narrower), secrets referenced via `${{ secrets.* }}` not hardcoded, workflow has a descriptive name and job ID
- Neither agent writes files in the other's domain

**Scoring:**
- 2 — Both agents follow their domain rules; no violations
- 1 — Minor violation in one domain (e.g., `devops-engineer` uses a broad permissions block, or watcher lacks exit codes)
- 0 — Credentials hardcoded in either artifact, or agent domain crossover on a primary deliverable
