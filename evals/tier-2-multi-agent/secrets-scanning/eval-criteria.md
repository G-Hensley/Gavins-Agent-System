# Eval Criteria: Secrets Scanning Pipeline (Tier 2 — Multi-Agent Handoff)

Target agents: `devsecops-engineer` → `devops-engineer`
Max score: 12 (6 dimensions × 0–2)

---

## 1. Dispatch Correctness (0–2)

**What to check:**
- `devsecops-engineer` is dispatched first to make tool selection, configure the scanner, and define what the pipeline must enforce
- `devops-engineer` is dispatched after to translate that configuration into a working GitHub Actions workflow
- The orchestrator does not write the workflow YAML directly without dispatching `devops-engineer`
- The orchestrator does not make security tool selection decisions without dispatching `devsecops-engineer`

**Scoring:**
- 2 — Both agents dispatched in correct order; security config precedes CI integration
- 1 — Both dispatched but order is wrong (workflow built before scanner is configured), or one agent produces artifacts in the other's domain
- 0 — Only one agent dispatched, or neither used

---

## 2. Handoff Quality (0–2)

**What to check:**
- `devsecops-engineer` produces a handoff artifact before `devops-engineer` begins: selected tool(s), config file path, scan command syntax, exit code behavior, and what constitutes a failure
- `devops-engineer` uses the exact tool, config path, and scan command specified in the handoff — not a re-invented version
- The workflow's failure condition matches the scanner's exit code behavior as documented by `devsecops-engineer`

**Scoring:**
- 2 — Explicit handoff artifact produced; workflow aligns with scanner config on tool, command, and failure condition
- 1 — Handoff occurs but is informal; workflow partially aligns (e.g., correct tool but different config path or wrong failure condition)
- 0 — No handoff; `devops-engineer` picks its own tool/config independently of what `devsecops-engineer` specified

---

## 3. Design-First Compliance (0–2)

**What to check:**
- Before any config file or workflow is written, there is a stated security design: what categories of secrets to detect, what to exclude, what the PR failure experience should look like, and whether one or two tools are used
- Tool selection includes a rationale (even one sentence) — not just a default to gitleaks
- The workflow structure (triggers, jobs, steps, PR comment behavior) is planned before YAML is written

**Scoring:**
- 2 — Both security design and workflow design stated before any file is written
- 1 — One of the two is designed upfront; the other jumps to implementation
- 0 — No design step; first output is a config file or YAML

---

## 4. TDD Compliance (0–2)

**What to check:**
- This eval has a constrained TDD scope: infrastructure config is not unit-testable, but the local scan script (`scan-secrets.sh`) should be validated against a known fixture
- A test fixture with a fake/clearly-labeled credential is created, and the scan script is confirmed to detect it before the workflow is finalized
- The baseline exception (e.g., `tests/fixtures/`) is confirmed to suppress false positives — verified by running the scanner against a fixture file in that path
- Both positive detection and baseline suppression are verified, not just assumed

**Scoring:**
- 2 — Scanner confirmed to detect a planted fake secret; baseline suppression confirmed against a fixture in the excluded path; both verified before workflow is written
- 1 — One of the two is verified (detection or suppression), but not both
- 0 — No local verification; pipeline assumed to work without testing the scanner behavior

---

## 5. Output Quality (0–2)

**What to check:**
- `.github/workflows/secrets-scan.yml` triggers on `pull_request` and `push` to `main`
- Workflow fails the check when a secret is detected (non-zero exit code from scanner)
- PR comment is posted on failure with secret type and file location — secret value is not echoed
- Scanner config excludes `tests/fixtures/` (or equivalent) via allowlist/baseline
- `scripts/scan-secrets.sh` is executable, accepts an optional target path, and exits non-zero on findings
- Tool choice is explained with at least one concrete reason
- No production secrets required to run any part of the pipeline

**Scoring:**
- 2 — All seven checks pass
- 1 — 4–6 checks pass; one major item missing (e.g., no PR comment, no fixture exclusion, or local script is a stub)
- 0 — Fewer than 4 checks pass; workflow is absent or non-functional

---

## 6. Agent-Specific Rules (0–2)

**What to check:**
- `devsecops-engineer`: tool selection is justified, exclusions are specific (not wildcard-everything), scan covers both committed files and git history
- `devops-engineer`: workflow uses least-privilege permissions (`pull-requests: write` only, not `write-all`), secrets used in workflow come from `${{ secrets.* }}`, workflow has a descriptive name
- PR comment step does not use `GITHUB_TOKEN` with write permissions beyond what is needed for PR comments
- Neither agent hardcodes credentials or uses a real secret as a test fixture

**Scoring:**
- 2 — Both agents follow their domain rules; permissions are scoped; no hardcoded secrets anywhere
- 1 — Minor violation (e.g., `write-all` permissions on the workflow, or exclusion pattern is too broad)
- 0 — Credentials hardcoded in any artifact, or `devsecops-engineer` skips history scanning entirely
