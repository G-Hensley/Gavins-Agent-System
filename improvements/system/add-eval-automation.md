# Wire run-eval.sh to Actually Execute Evals

## What I Observed

`evals/run-eval.sh` is a well-structured scaffold — argument parsing, result directory creation, result.json scaffolding — but `run_tier()` and `run_review_challenge()` both contain only TODO comments and placeholder echo statements. No eval actually runs when you invoke the script.

The eval suite has real prompt files and rubric files under the tier directories. The gap is the execution layer: reading a prompt, sending it to the agent system via `claude --print`, capturing output, and scoring it against the rubric.

## Why It Would Help

Without execution, the eval suite is documentation, not a test suite. The system can silently break (wrong agent dispatched, skill ignored, TDD skipped) with no automated signal. Every eval that exists today requires manual invocation and manual scoring — which means it doesn't get run.

## Proposal

Wire `run-eval.sh` in two phases:

### Phase 1 — Execution

Replace the TODO in `run_tier()` and `run_review_challenge()` with real execution:

```bash
run_prompt() {
  local prompt_file="$1"
  local output_file="$2"
  claude --print < "${prompt_file}" > "${output_file}" 2>&1
}
```

For each tier directory: find all `prompt.md` files, run each via `claude --print`, capture stdout to `output.txt` in the result directory.

For review challenges: concatenate `artifact.*` content into the prompt context (or pass as a file), then run against `prompt.md`.

### Phase 2 — Scoring

Auto-score dispatch correctness by parsing `output.txt` for agent dispatch markers. The agent system emits structured lines when dispatching — grep for them and compare against `expected_agents` in a `rubric.json` (or parsed from `rubric.md`).

Scoring dimensions that can be auto-checked:
- **Dispatch correctness**: Did output mention the expected agent name(s)?
- **TDD compliance**: Did output reference writing a test before implementation?
- **Review challenge findings**: Did output name the planted defect (SQL injection, wildcard IAM, etc.)?

Dimensions requiring human review (log as "manual"):
- Output quality
- Handoff fidelity
- Architectural soundness

Write scores to `result.json` under a `scores` key. Print a pass/fail summary to stdout with per-dimension breakdown.

### Changes Required

1. Add `expected_agents` and `auto_check_findings` fields to each eval's `rubric.md` (or a companion `rubric.json`)
2. Update `write_result_scaffold()` to include a `scores` block
3. Add a `score_output()` function that takes an output file and rubric, returns a score map
4. Add `--dry-run` flag that prints what would be executed without running it
