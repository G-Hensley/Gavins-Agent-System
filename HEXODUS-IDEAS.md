# Hexodus — Composed Ideas + Versioned Roadmap

A working spec for evolving `gavins-agent-system` into **Hexodus**: an open-source Claude Code plugin marketplace built around frontmatter-first retrieval, tiered per-agent memory, hypothesize-then-verify search, and cross-project knowledge composition.

Last updated: 2026-04-27

---

## 1. Vision

Most Claude Code plugin marketplaces today are pile-of-skills distributions. Hexodus is different: it's a **composed memory + retrieval architecture** delivered as a marketplace, where every plugin participates in the same system rather than being an isolated bag of files.

The framing that drives every design decision:

> Retrieval isn't a search problem. It's a budget problem.
> Memory isn't a store problem. It's a hygiene problem.
> Plugins aren't a packaging problem. They're a composition problem.

Hexodus solves all three by treating skills/agents/rules/hooks/memory as one unified surface with shared conventions (frontmatter schema, tier discipline, sentinel hooks) and shipping it as a coherent marketplace where each plugin extends the same architecture.

## 2. Working corrections from prior research

The published Memory/Context/Repo Retrieval research is mostly right but two things need adjusting for our specific situation:

**Cross-project memory is filesystem-based, not Notion-based.** Notion is for work — TTL/APIsec operational systems, dashboards, hubs. Project context and accumulated technical memory live on the filesystem. Don't bolt a third source of truth into the loop. The cross-project layer is a separate Hexodus plugin (`hexodus-bridge`) that walks `~/Projects/` and composes memory across projects via filesystem reads.

**Idea 3 (hypothesize-then-verify) becomes self-improving.** The research framed this as a one-way search optimization. The real value is bidirectional: every prediction-vs-reality delta becomes a memory entry, so future hypotheses for similar repos use accumulated learned priors. The search loop becomes a training loop. See §5.3 below.

## 3. The composed architecture

```
┌──────────────────────────── Tier 0 (always loaded, ~2-5k tokens) ────────────────────────────┐
│  Project CLAUDE.md  ·  Agent CLAUDE.md  ·  Today's session goals                              │
│  Sentinel warnings (if any)  ·  /hexodus status snapshot                                      │
└───────────────────────────────────────────────────────────────────────────────────────────────┘

┌──────────────────────────── Tier 1 (warm, JIT-fetched on keyword/intent match) ──────────────┐
│  Frontmatter index across all skills/agents/rules/hooks                                       │
│  Recent exploration journal entries (last 30 days, per-agent)                                 │
│  File summaries (synthesize-on-write outputs)                                                 │
│  Cross-project bridge hits (recent decisions/patterns from other projects)                    │
└───────────────────────────────────────────────────────────────────────────────────────────────┘

┌──────────────────────────── Tier 2 (cool, on-demand) ─────────────────────────────────────────┐
│  Full agent memory archive  ·  Older exploration logs  ·  ADRs  ·  PR history                 │
│  Hypothesis-prediction deltas (the learned-prior store)                                       │
└───────────────────────────────────────────────────────────────────────────────────────────────┘

┌──────────────────────────── Tier 3 (cold, archived) ──────────────────────────────────────────┐
│  Deprecated patterns  ·  Completed-project residue  ·  Reference material                     │
└───────────────────────────────────────────────────────────────────────────────────────────────┘

Routed by:    Question-type router (skill, not LLM call) + tool descriptions
Maintained by: SessionStart sentinel hook · Pre-commit summary writer · Cartographer (v4+)
Composed by:  Marketplace plugins, each respecting the same frontmatter + tier conventions
```

## 4. Marketplace structure

Hexodus ships as a marketplace with one core plugin and several themed satellites. Users install just what they need; the satellites all extend the core's conventions.

| Plugin | Surface | Contains |
|---|---|---|
| **hexodus-core** | Always required. Provides the kernel. | `/hexodus init`, `/hexodus status`, `/hexodus search`, frontmatter schema, tier-promotion logic, sentinel hook, hypothesize-verify rule, agent journal convention, the meta-skills (`create-skill`, `create-agent`, `hookify`), the orchestration agents (`architect`, `implementer`, `code-explorer`, `plan-reviewer`, `spec-reviewer`, `doc-writer`), and the cross-cutting skills (`brainstorming`, `writing-plans`, `executing-plans`, `validation-and-verification`, `parallel-agents`, `parallel-review`, `systematic-debugging`, `refactoring`, `test-driven-development`, `git-workflow`, `git-health-check`, `doc-sync`, `codex-plan-review`). |
| **hexodus-eng** | Engineering capabilities. | Backend, frontend, DB, API design, devops skills + corresponding agents (`backend-engineer`, `frontend-engineer`, `database-engineer`, `devops-engineer`, `automation-engineer`, `qa-engineer`, `ai-engineer`). |
| **hexodus-sec** | Security capabilities. | Security skills + threat modeling + security audit + agents (`appsec-reviewer`, `backend-security-reviewer`, `frontend-security-reviewer`, `cloud-security-reviewer`, `devsecops-engineer`, `threat-modeler`). |
| **hexodus-design** | Design + UX. | `frontend-design` skill + `uiux-designer` agent + future copy/research skills. |
| **hexodus-product** | Product management. | `product-management` skill + `product-reviewer` agent + spec writing patterns. |
| **hexodus-bridge** | Cross-project memory layer. | Filesystem walker that reads sibling project memory tiers, dedupe + tag, exposes a `cross_project_search` tool to the main agent. |
| **hexodus-graph** *(v4+)* | Knowledge graph for large repos. | Tree-sitter parser, AST graph, blast-radius queries. Optional, only worth it past ~50k LOC. |
| **hexodus-semantic** *(v5+)* | Embeddings-based retrieval. | Local-first vector index over journal entries + summaries. Only when frontmatter + summaries no longer suffice. |

**Why this slicing works:** every satellite plugin's skills/agents follow the core's conventions (frontmatter schema, journal directory, tier discipline). The core defines the architecture; satellites extend it with domain-specific capability. Users running a security-focused workflow install `hexodus-core + hexodus-sec` and don't pay token cost for marketing skills they'll never use.

## 5. The five load-bearing ideas, composed

### 5.1 Universal frontmatter (across all files in projects)

Not just skills. **Every file in projects gets YAML frontmatter** — skills, agents, rules, hooks, source code (in language-appropriate comments), even docs. The schema:

```yaml
---
purpose: one-line description of what this file does
type: skill | agent | rule | hook | source | doc
triggers: [when this gets loaded]
requires: [dependencies / prerequisites]
last_validated: 2026-04-27
last_used: 2026-04-26
tier: hot | warm | cool | cold
tags: [domain, language, layer]
---
```

A `/hexodus search` command hits frontmatter first, body only when frontmatter doesn't suffice. This collapses the "I need to find the file that handles X" question from a multi-file grep loop into a single frontmatter scan that returns ranked candidates with their `purpose` line as the snippet.

For source code: include the frontmatter as a top-of-file comment block. Tree-sitter extracts it without reading the body. A 50-file frontmatter scan is ~10k tokens; the equivalent file-content read is 100k+. **10x context efficiency for the most common retrieval question.**

The `last_validated` field is what powers the sentinel — files whose validation timestamp lags too far behind their last-modified timestamp get flagged for review.

### 5.2 Tiered per-agent memory

Restructure `agent-memory/{agent-name}/` from flat to tiered:

```
agent-memory/
└── code-explorer/
    ├── CLAUDE.md              ← tier 0 (always loaded)
    ├── hot/                   ← tier 0 (always loaded if present)
    ├── warm/                  ← tier 1 (JIT-fetched, last 30 days)
    ├── cool/                  ← tier 2 (search-on-demand)
    ├── cold/                  ← tier 3 (archived)
    └── journal/               ← exploration logs (see §5.4)
```

Promotion/demotion happens automatically:
- Files unaccessed for 30+ days move warm → cool
- Files unaccessed for 180+ days move cool → cold
- Files cited or read this session move up one tier
- Tier 0 (`hot/`) is curated by hand — small, deliberate, never auto-populated

Agents get explicit `fetch_warm`, `fetch_cool`, `fetch_cold` tools. The cost-of-access becomes visible in the agent's reasoning, which means it'll learn to budget naturally instead of treating all retrieval as free.

### 5.3 Hypothesize-then-verify with self-improving priors

The behavioral pattern (from research Idea 3) plus the self-improvement loop (your enhancement):

```
Step 1 (predict): Agent commits to a structural hypothesis BEFORE searching.
                  "I think auth lives at middleware/auth.* and depends on lib/jwt.*"

Step 2 (verify):  A verify_hypothesis tool returns a delta:
                  "Of those: auth-v2.ts exists; auth-v1.ts is deprecated;
                   you missed lib/refresh-token.ts which is in the call chain."

Step 3 (act):     Agent reads the corrected target set.

Step 4 (learn):   The DELTA gets saved as a hypothesis-prior memory entry:
                  ---
                  repo_signature: nextjs-app + jwt + auth-middleware
                  predicted: [middleware/auth.*, lib/jwt.*]
                  actual:    [middleware/auth-v2.ts, lib/jwt.ts, lib/refresh-token.ts]
                  pattern:   refresh-token logic typically lives separately from
                             jwt validation in this stack
                  confidence: low (n=1)
                  ---

Step 5 (compound): Future sessions, when hypothesizing in similar repos, the
                   verify tool surfaces matching priors so the agent's first
                   guess is already wiser. Confidence grows with n.
```

The retrieval system gets smarter every session. After a few months, hypotheses for common stacks are accurate on the first try, and the verify tool degenerates into a no-op confirmation — which is the goal. The system trained itself out of needing intensive search.

This is encoded as a **rule** in `hexodus-core/rules/hypothesize-then-verify.md` — it's behavioral, not a tool. Plus a `verify_hypothesis` tool in the core, plus a `hypothesis-priors/` directory in each agent's memory.

### 5.4 Per-agent exploration journals

Each agent has a `journal/` directory containing structured logs of significant explorations. Format:

```yaml
---
session: 2026-04-27-auth-debug
agent: backend-engineer
question: why is token refresh failing for some users
explored: [middleware/auth.ts, lib/jwt.ts, tests/auth.spec.ts]
ruled_out:
  - cause: clock skew (verified, was fine)
  - cause: wrong secret (verified, all envs match)
discovered:
  - cause: refresh token TTL was 1h not 24h, set in config/auth.ts:42
fix: bumped TTL to 24h, added test
surprised_by: had been broken for 3 weeks unnoticed
related_priors: [hypothesis-priors/auth-stack-shapes.md]
tier: warm
---
```

Journals capture the *journey*, not just the artifact. Future sessions on similar questions surface relevant journal entries before re-discovering the same ground. Your existing `code-explorer/apisec-*.md` files are exactly this pattern, accidentally — Hexodus codifies it as a first-class convention.

Journal entries are written by a SessionEnd hook. The agent itself drafts the entry; the hook writes it. If the session crashes, a partial entry is written from the running transcript.

### 5.5 Stale-knowledge sentinel (SessionStart hook)

A hook that runs at session start and:

1. Walks all frontmatter, computing `last_validated` vs `last_modified` deltas.
2. Cross-checks claims in `hot/` memory against current code via grep + simple heuristics.
3. Detects contradictions between agent memory entries.
4. Writes findings to `.hexodus/sentinel-warnings.md`.
5. The main agent reads this file at the top of every session.

The sentinel is the antidote to silent-failure memory drift. It's also the feedback loop that keeps frontmatter honest — files that get flagged repeatedly are de facto deprecated.

## 6. Baseline measurement (the step before v0)

**Premise:** every version-gate in this roadmap claims to improve something. None of those claims are credible without a measured starting line. Before the v0 port begins, the current `gavins-agent-system` is measured end-to-end against a fixed scenario suite, so v1, v2, v3+ each have a numerical bar to clear. **No build work begins until the baseline exists.**

### 6.1 Existing eval scaffolding

Most of the surface is already there — it just isn't measuring enough yet. What exists today in `evals/`:

- **`run-eval.sh`** — bash harness that drives `claude --print --output-format json` per scenario, captures response, writes `result.json` with status + duration.
- **18 scenarios** across four tiers + six review challenges:
  - Tier 1 (single-agent): cli-calculator, chatbot-cli, dockerfile, rest-endpoint, codex-plan-review
  - Tier 2 (multi-agent): file-watcher, secrets-scanning, tic-tac-toe
  - Tier 3 (architecture-first): rag-system, snake-game, threejs-scene
  - Tier 4 (full-workflow): task-manager-app
  - Review challenges: sql-injection, overpermissive-iam, xss-vulnerability, dependency-vuln, spec-deviation, code-quality-issues
- **`agent-coverage.md`** mapping each of the 24 specialist agents to scenarios it appears in.
- **`result.json` schema** with stub fields for `total_tokens`, `agents_dispatched`, `review_cycles`, `findings` — the right shape, but most fields are still null after runs.

### 6.2 What the harness doesn't capture (the gap to a real baseline)

The current harness records "did the agent finish without crashing." That's a smoke test, not a baseline. Five additional metric streams need to come online:

1. **Token efficiency.** Total tokens per scenario, split into input/output/cached. Already in the `claude --print --output-format json` response — harness just doesn't extract it. This is the metric v1 frontmatter is supposed to improve, so without it there's no improvement claim.
2. **Skill + agent invocation trace.** Which skills loaded into context, which agents got dispatched via the Task tool, in what order. The JSON response includes a turn-by-turn trace; needs parsing.
3. **Quality score (LLM-as-judge).** Each scenario already has an `eval-criteria.md`. A grader reads the response against the criteria and produces a structured score (correctness, completeness, code quality, agent routing, skill selection). Without this, "passed" is binary and hides regressions.
4. **Memory utilization.** Whether and how often agents read from `agent-memory/`. Establishes the floor v1's tiered memory has to outperform.
5. **Latency breakdown.** Time to first token, time in tool calls vs reasoning, time per agent dispatch. Wall-clock duration alone hides where cost lives.

### 6.3 Harness patches required

Roughly ~250 LOC of Python, no new dependencies, all under `evals/lib/`:

- **Token + trace extractor** (~100 LOC) — parses the JSON response after each scenario, fills in `result.json["metrics"]["total_tokens"]`, `result.json["agents_dispatched"]`, and a new `skills_loaded` field.
- **LLM-as-judge grader** (~150 LOC + prompt template) — reads scenario response + `eval-criteria.md`, calls a small model, writes structured findings to `result.json["findings"]` with sub-scores per criterion.
- **Aggregator** — rolls per-scenario `result.json` files into a single `evals/BASELINE.md` with the comparison table from §6.5.

### 6.4 Execution plan

1. **Audit.** Run `./run-eval.sh --run-all` with the existing harness. Catalog any scenarios that fail for reasons unrelated to agent performance (stale prompts, missing fixtures, broken scaffolding). Fix those first — broken scenarios pollute the baseline.
2. **Patch.** Add the three modules above. Hook them into `run-eval.sh` after each scenario completes.
3. **Triple-run.** LLM-as-judge introduces variance — run each scenario 3 times, record median + range. Same sample size for token measurements.
4. **Write `evals/BASELINE.md`.** Captures aggregate metrics + per-scenario rows + the comparison protocol (§6.6). This is the canonical reference; v1+ regenerate the same table on the same scenarios.
5. **Tag the git SHA.** The baseline is bound to a specific commit of `gavins-agent-system`. v0 port begins from that commit; deviation from baseline scenarios is forbidden until v0 has shipped clean.

### 6.5 Aggregate baseline form

```
HEXODUS BASELINE — gavins-agent-system @ {git_sha}, {date}, n=3 runs

Scenario               Tokens (med)  Quality   Skills used  Agents used  Duration
cli-calculator         12,450        8.2/10    [3]          [1]          42s
sql-injection          8,990         9.1/10    [2]          [1]          28s
task-manager-app       89,300        7.4/10    [12]         [7]          512s
...

Aggregate:
  Median tokens/scenario:        18,400
  Median quality score:          8.0/10
  Skill selection accuracy:      76%
  Agent routing correctness:     84%
  Memory cite rate:              12%
  Median wasted skill loads/run: 2.4
  Median wasted agent calls/run: 0.8
  Model version:                 claude-{locked-version}
```

### 6.6 Comparison protocol — the contract every version must clear

- **v0** must reproduce the baseline metrics within ±5% on every scenario. The port is failed if it regresses anything.
- **v1** must improve median tokens/scenario by ≥15% with no quality regression >0.5pts, and skill selection accuracy must improve by ≥10pts (frontmatter-driven).
- **v2** must reduce wasted skill loads (loaded but uncited) by ≥30% (sentinel-driven), and surface ≥1 stale-knowledge contradiction per planted-stale test case.
- **v3** must demonstrate cross-project context transfer on a scenario set added in v3 specifically to exercise the bridge plugin.
- **v4** must show ≥10x token reduction on at least one "blast radius" query type.
- **General rule:** every version ships with a delta report against baseline OR fails to ship. No version's win condition is "it feels better."

### 6.7 Baseline-specific risks

- **Stale scenarios.** Some of the 18 may need prompt updates before they meaningfully exercise current functionality. Document fixes in the audit step.
- **Judge variance.** LLM-as-judge introduces ~5–10% scoring noise; mitigated by triple-runs + median scoring + recording the range.
- **Model version drift.** All baseline runs must use the same Claude model version. Lock it in `BASELINE.md` and re-baseline (with a new tagged commit) any time the locked model changes.
- **Sample-size weakness.** 18 scenarios × 3 runs = 54 data points isn't statistically robust. Treat improvements <5% with skepticism; require ≥15% gates for high-confidence claims.
- **Privacy at the eval boundary.** The same APIsec-content sanitization rule that applies to the public Hexodus repo also applies to baseline scenarios — no scenario should reference APIsec-internal flows. The existing 18 scenarios are clean; this rule must hold for any v3+ additions.

### 6.8 Effort estimate

- Audit + scenario fixes: half a day to one day
- Harness patches (extractor + grader + aggregator): one to two days
- Full triple-run on 18 scenarios: ~4 hours wall-clock (parallel-friendly)
- Writing `BASELINE.md` + locking the comparison protocol: half a day

**Total: 2–3 days of focused work** before v0 begins. This is the cheapest insurance available against shipping versions that regress what they were supposed to improve.

---

## 7. Maintenance + observability layer

**Architectural decision: Path A — pure plugin.** Hexodus does not ship a persistent daemon. Every maintenance job either fires inline via hooks, runs lazily with checkpoints, or is exposed as an explicit CLI command users can wire into the scheduler of their choice. Users who want truly continuous maintenance pair Hexodus with a local agent runtime they already trust (OpenClaw, Hermes, future Mothership) and schedule the CLI commands through that runtime's existing cadence.

This keeps Hexodus' identity simple: a Claude Code plugin marketplace, not a service. No daemon to install, no background process to audit, no cross-platform packaging story for a binary. The product surface is the plugins themselves plus a small set of well-documented CLI commands.

### 7.1 The four execution layers

Hexodus exposes maintenance through four layers, each picking up where the lighter one stops being viable:

1. **Hook-driven.** SessionStart / SessionEnd / PreToolUse / PostToolUse hooks fire inline with the session. Used for fast (<2s) jobs that pair naturally with session boundaries: sentinel drift check on session start, journal write on session end, memory-access tracking on tool use.

2. **Lazy with checkpoints.** Every job tracks its `last_run` timestamp in `.hexodus/maintenance.log`. On the next SessionStart, the healthcheck pass asks "is this stale?" If yes, it runs inline before the session begins (with a brief "catching up on maintenance" message). If no, it skips. This makes the system self-healing — a user who doesn't open Claude Code for two weeks gets all overdue jobs caught up on the next session, automatically.

3. **CLI commands.** Every maintenance job is exposed as `hexodus maintain <job-name>`: `hexodus maintain sentinel`, `hexodus maintain tier-sweep`, `hexodus maintain bridge-sync`, `hexodus maintain aggregate-priors`. These can be invoked manually or wired into any scheduler. Each command is idempotent and respects the same checkpoint state as the lazy path.

4. **External scheduler integration.** For users who want maintenance independent of session boundaries, the plugin documents how to schedule the CLI commands. Three documented paths:
   - **Native OS scheduler** — `cron` on Mac/Linux, Task Scheduler on Windows. Plugin ships an `hexodus install-scheduler` helper that scaffolds entries for the most common cadence (nightly tier sweep, weekly bridge sync, hourly sentinel).
   - **Local agent runtime** — pair Hexodus with OpenClaw, Hermes, or a similar local-first agent runtime. The runtime is already on a schedule; adding a few maintenance steps is trivial.
   - **Cowork scheduled tasks** — for Cowork users specifically, ship task templates in a companion package (`hexodus-cowork-tasks`) that wrap the CLI commands and register against the user's existing scheduled-task system.

### 7.2 Job inventory

| Job | Default cadence | Default mechanism | Manual command | Cost |
|---|---|---|---|---|
| Sentinel drift check | Hourly, debounced | SessionStart hook | `hexodus maintain sentinel` | <2s |
| Tier promotion/demotion | Daily | Lazy on SessionStart | `hexodus maintain tier-sweep` | <5s |
| Journal write | Per session | SessionEnd hook | n/a (automatic) | <1s |
| Frontmatter validation | Per file save | Git pre-commit hook | `hexodus maintain validate-frontmatter` | <1s/file |
| Prior pattern aggregation | Every 10 new priors | Threshold-triggered | `hexodus maintain aggregate-priors` | <10s |
| Bridge sync (cross-project) | Weekly | Lazy + on-demand | `hexodus maintain bridge-sync` | 30s–2min |
| File summarization (v4+) | Per file save | Git pre-commit hook | `hexodus maintain summarize-files` | 5–30s/file |
| Cartographer pass (v4+) | Per git push | Triggered | `hexodus maintain atlas-update` | continuous |

Every job has the same operational contract: idempotent, checkpointed, never blocks for >30s on the inline path, writes a structured entry to `.hexodus/maintenance.log` on completion.

### 7.3 Healthcheck + observability

Three pieces give the user confidence the system is working without forcing them to babysit it:

1. **`hexodus health` command.** Prints a live status panel — same shape as the branding splash, populated with real telemetry: every maintenance job, its last-run timestamp, a fresh/stale/failed flag, and any open sentinel warnings. If sentinel hasn't run in 48h: red. If bridge sync hasn't run in 30d: amber. If tier sweep ran successfully two hours ago: green. This is the daemon's UI without the daemon.

2. **`.hexodus/maintenance.log`.** Append-only structured log. Every job execution writes timestamp + job name + duration + items processed + warnings. Capped at ~10MB with rotation. The agent reads recent entries on SessionStart so it has context about system state going into a session.

3. **Self-healing on lag.** If SessionStart's healthcheck sees an overdue job, it runs it inline rather than silently skipping. The user sees a brief "running maintenance" message instead of opaque slowness; failures surface as warnings rather than disappearing.

### 7.4 Reference setup: pairing Hexodus with a local runtime

For users running a local agent runtime, the recommended pattern is to add Hexodus maintenance jobs to whatever schedule the runtime already operates on. Documented reference setup (used in the README):

```
Hermes agent (Ollama / Qwen 3.5) running on a nightly schedule.
Each night the agent invokes, in order:
  hexodus maintain sentinel
  hexodus maintain tier-sweep
  hexodus maintain aggregate-priors
  hexodus maintain bridge-sync   # weekly, gated by its own checkpoint

The runtime handles scheduling, retry, logging, error reporting.
Hexodus is a passive set of CLI commands the runtime calls.
```

This pattern keeps Hexodus' surface minimal (a plugin + a CLI) while letting users plug in whatever runtime they prefer. It also aligns with the local-first audience most likely to install Hexodus in the first place — they already have a runtime, they don't want another one. OpenClaw, Hermes, and the eventual Mothership all fit this slot equivalently; the README documents one (Hermes) as the worked example and links the others.

### 7.5 Path B revisit conditions

Path B (companion daemon / runtime binary) is explicitly deferred. It earns reconsideration only if one of these conditions hits in v4+:

- Cartographer in v4 needs continuous filesystem watching that hooks + git triggers can't satisfy at the required latency.
- File summarization (v4) ends up too slow inline on commit and a persistent background queue is required.
- A cross-user feature (shared priors pool, telemetry aggregation) requires a network-enabled local service.

Until then, layered scheduling + healthcheck observability covers the operational requirements without Hexodus owning the daemon problem.

---

## 8. Versioned roadmap

Each version has: scope, exit criteria, unit tests, e2e tests, and a **dogfood milestone** (a real thing you build using Hexodus to prove the new capabilities work end-to-end).

### v0 — Plugin port (existing system, repackaged)

**Scope:** Take the current `gavins-agent-system` content, sanitize APIsec-flavored references, fork to a clean public `hexodus/` repo, add `.claude-plugin/plugin.json`, validate plugin install/uninstall round-trip.

**No new architecture yet.** This version just proves the existing 39 skills + 25 agents + 12 rules + 9 hooks work as a Claude Code plugin.

**Exit criteria:**
- `claude plugin install hexodus` works on a clean instance
- All 39 skills appear in available-skills list
- All 25 agents are invokable via Task tool
- Sanitization complete: no APIsec internal references in public repo

**Unit tests:**
- Frontmatter parser passes on all existing skill YAML headers
- Plugin manifest validates against schema

**E2E tests:**
- Install on clean Claude Code → invoke `architect` agent → produces a plan → invoke `implementer` agent against the plan → succeeds

**Dogfood milestone:** Use Hexodus v0 to scaffold a tiny CLI tool (e.g., a Markdown TOC generator). Validates the existing skill+agent flow still works after repackaging.

---

### v1 — Foundation (frontmatter, tiers, journals, hypothesize-verify)

**Scope:**
- Universal frontmatter schema across skills/agents/rules/hooks
- `/hexodus search` command (frontmatter-first retrieval)
- Tiered memory restructure (`hot/`, `warm/`, `cool/`, `cold/` per agent)
- `/hexodus init` command (memory scaffold bootstrap)
- `/hexodus status` command (rendered as ASCII version of the splash panel)
- Hypothesize-then-verify rule + `verify_hypothesis` tool
- Per-agent journal convention + SessionEnd journal-writer hook
- `agent-memory/` ships empty in plugin; init command materializes it

**Exit criteria:**
- All Hexodus core files have valid frontmatter
- `/hexodus search "X"` returns ranked candidates by frontmatter purpose
- Tier promotion/demotion runs cleanly on a 30/180-day cadence
- Hypothesize-verify produces at least one prior-memory entry per session
- Journal hook fires on session end and writes a valid entry

**Unit tests:**
- Frontmatter parser: valid, invalid, missing fields, extra fields, malformed YAML
- Tier promotion logic: correct promotion/demotion at boundaries (29 vs 30 days, 179 vs 180)
- Frontmatter search: ranking correctness, tie-breaking, empty results
- Journal writer: well-formed entries, partial-session recovery, malformed transcripts
- Verify_hypothesis: empty prediction, exact match, partial match, contradicting prior

**E2E tests:**
- Fresh install → `/hexodus init` → run a real task → confirm journal entry written → confirm tier promotion happened on referenced files
- Run the same agent twice on similar tasks → confirm second run uses prior memory

**Dogfood milestone:** Use Hexodus v1 to build a small Python CLI (e.g., the `cross_project_search` prototype that v3 will need anyway). The agent must use frontmatter to find skills, write journal entries, and compound priors across two work sessions.

---

### v2 — Closing the loop (sentinel, observability, frontmatter rot)

**Scope:**
- SessionStart stale-knowledge sentinel hook
- `.hexodus/sentinel-warnings.md` write target
- Frontmatter rot detector: flag entries where `last_validated` lags `last_modified` by >30 days
- Memory observability: SessionEnd report — what got loaded, what got cited, what was wasted
- `/hexodus health` command (sentinel + observability rolled up)

**Exit criteria:**
- Sentinel runs in <2s on a 100-file project
- Observability report identifies "wasted" loads (high token cost, zero citations)
- Frontmatter rot detection catches synthetic stale cases in tests

**Unit tests:**
- Sentinel: detects contradiction, ignores valid entries, handles missing fields
- Rot detector: correct flag at boundary, no false positives on actively used files
- Observability: token accounting matches transcript

**E2E tests:**
- Plant 5 stale memory entries, run sentinel → confirm 5 warnings
- Run a session, intentionally load unused memory → confirm observability report flags it

**Dogfood milestone:** Use Hexodus v2 to do a real security review on `apisec-cicd-demo`'s vulnerable target. The sentinel must catch any stale security memory; the observability report must show <30% wasted token loads.

---

### v3 — Cross-project bridge + marketplace expansion

**Scope:**
- `hexodus-bridge` plugin: filesystem walker over sibling projects under `~/Projects/`
- Cross-project frontmatter index (deduplicated + project-tagged)
- `cross_project_search` tool exposed to main agent
- Question-type router (as a meta-skill, not LLM call) — uses tool descriptions + system prompt to self-route
- Marketplace formalized: `hexodus-core` + `hexodus-eng` + `hexodus-sec` + `hexodus-design` + `hexodus-product` published as separate plugins
- Cross-plugin compatibility tests

**Exit criteria:**
- `cross_project_search "auth pattern"` returns hits across at least 3 projects
- Bridge plugin respects per-project privacy (e.g., APIsec exclusion rules from existing memory)
- All five core+satellite plugins install independently and compose correctly

**Unit tests:**
- Bridge walker: respects exclusion patterns, dedupes correctly, tags by project
- Question-type router: classifies test set with >90% accuracy
- Plugin compatibility matrix: every pairwise install combination works

**E2E tests:**
- Install `hexodus-core + hexodus-eng + hexodus-sec` → invoke a security review on a new app → confirm cross-plugin agent calls work
- Modify a memory entry in project A → confirm bridge surfaces it in project B's session

**Dogfood milestone:** Add a feature to two projects in one session — e.g., a new skill in `gavins-agent-system` AND a related capability in `intel-feed`. Bridge must surface relevant context from each project to the other. This is the ultimate cross-project test.

---

### v4 — Synthesize-on-write + cartographer

**Scope:**
- Pre-commit hook: generate 200-token dense summary of every changed source file → `.summaries/path/to/file.md`
- Summaries become tier 1 retrieval target ahead of file bodies
- Repo cartographer subagent: watches `git log`, maintains `.hexodus/atlas.md` with structural changelog
- Cartographer feeds bridge index + sentinel
- Optional: `hexodus-graph` plugin (tree-sitter knowledge graph, only useful past 50k LOC)

**Exit criteria:**
- Summary generation adds <5s to commit time on a 50-file change
- Atlas auto-updates within 1 minute of new commits
- Graph plugin (if enabled) reduces token usage on "blast radius" queries by ≥10x

**Unit tests:**
- Summary writer: deterministic output for same input, handles edge cases (binary files, generated files, empty files)
- Atlas updater: idempotent on repeated runs, correct diff detection
- Graph queries: blast radius correctness on synthetic test repos

**E2E tests:**
- 100-commit replay → atlas converges to correct end state
- Summary-first retrieval beats file-content retrieval on token efficiency for "find handler for X" queries

**Dogfood milestone:** Refactor a meaningful piece of `gavins-agent-system` (or one of your real projects) using Hexodus v4. Summaries + atlas + cartographer must visibly reduce token consumption vs v3 on the same task.

---

### v5+ — Speculative

These are real ideas but earn the right to exist only if v1–v4 prove their architecture:

- **`hexodus-semantic`**: local-first embeddings over journal entries + summaries. Only worth it once journal corpus exceeds ~10k entries.
- **Dual graph (intent + code)**: linked feature graph + symbol graph. Worth it when ADR + PR history is rich enough to populate the intent side.
- **AI-assisted frontmatter migration**: scan a new repo, propose frontmatter for every file, human-confirm.
- **Hypothesis prior sharing**: cross-user opt-in pool of repo-signature → structure priors. Network effect on hypothesize-verify accuracy.

## 9. Testing philosophy

Three layers, every version:

**Layer 1 — Unit tests.** Pure-function logic: parsers, tier transitions, ranking, classifiers. Fast (<1s each), isolated, no Claude Code runtime needed. Target: >90% coverage on core logic.

**Layer 2 — E2E tests.** Plugin install → real session → assertions on side effects (files created, hooks fired, memory entries written). Slower (10-60s each), requires Claude Code instance, runs on every commit to a release branch. Use scripted Claude Code interactions where possible.

**Layer 3 — Dogfood milestones.** Build something real with Hexodus that exercises the new version's capabilities. Not a unit test, not a script — a deliberate project. Each milestone is documented in `dogfood/v{N}/` with the actual artifact, the transcript, and a written assessment of what worked vs what didn't. **This is what most plugin marketplaces skip and why most plugin marketplaces feel cheap.**

The dogfood milestones double as marketing material once v1+ is public — "here's a real CLI built end-to-end with Hexodus, and here's the session transcript that built it."

## 10. Open questions / risks

**Frontmatter rot.** What if metadata drifts from file content? Mitigation: sentinel + `last_validated` timestamps + visible warnings. But there's no perfect answer; some lying frontmatter will exist. Make it cheap to update, hard to ignore, and visible in `/hexodus health`.

**Memory tier migration on v0 → v1.** Existing flat memory needs to land in the right tiers. Approach: bulk-default everything to `warm/`, run access-pattern analysis for 30 days, let promotion/demotion settle. Manual `hot/` curation by hand.

**Cross-project privacy (APIsec wall).** The bridge MUST respect existing exclusion rules — TTL pentest tooling never surfaces in APIsec contexts and vice versa. Implementation: bridge reads a `.hexodus/bridge-exclude` file in each project root; honors it absolutely. Tests on this are P0.

**Plugin version pinning.** What happens when `hexodus-core` changes a frontmatter field that `hexodus-eng` depends on? Need semver discipline + plugin manifest declaring required core version. Failure mode: refuse to load on incompatible versions, never silent-degrade.

**Claude Code itself changes.** Plugin marketplace mechanics will evolve. Hexodus design must absorb upstream changes without redesign. Approach: keep all the novel stuff (frontmatter, tiers, journals, sentinel) implemented in plain markdown + bash + a thin Python lib, no exotic dependencies on Claude Code internals.

**The "is this overengineered?" check.** Every version must beat the prior version on a real dogfood task — not just on metrics. If v2 is harder to use than v1 with no measurable session-quality improvement, the version doesn't ship. Architecture must justify itself in the field.

## 11. Naming + branding alignment

The splash panel from the design session becomes the actual `/hexodus status` command output:

```
skills 39   ·   agents 25   ·   memory 54
hooks 9     ·   rules 12    ·   sentinel CLEAN
journal 187 entries          last sync 04:12
build 0xFF006E               tier hot/warm/cool/cold
> boot. dispatch. exit through hex.
```

Once v2 ships, the panel becomes telemetry — every number is a real measurement of system state. The brand is no longer aesthetic; it's diagnostic.

Vocabulary across docs/UI:
- **Skills, agents, rules, hooks, memory** — the canonical five surfaces
- **Tier** — hot/warm/cool/cold
- **Journal** — per-agent exploration log
- **Sentinel** — the stale-knowledge background process
- **Bridge** — cross-project memory layer
- **Atlas** — the cartographer's structural map (v4+)
- **Prior** — a saved hypothesis-vs-reality delta in `hypothesis-priors/`
- **Dispatch** — invocation of an agent or skill
- **Hex** — generic term for any addressable Hexodus unit (skill, agent, hook, rule)

## 12. Immediate next moves

1. Validate this doc lands. Adjust scope/sequence if anything looks wrong.
2. **Establish the baseline (§6) before any other build work.** Audit `run-eval.sh`, patch the harness for token + trace + judge metrics, run the full suite 3x, write `evals/BASELINE.md`, tag the git SHA. ~2–3 days.
3. Stand up the public `hexodus/` repo as an empty shell.
4. Begin v0: port + sanitize → plugin manifest → install round-trip test. v0 also re-runs the baseline scenario suite to confirm the port reproduces baseline metrics within ±5% — anything worse is a regression and v0 doesn't ship until it's fixed.
5. Once v0 ships clean, the v1 frontmatter-everywhere pass becomes the next focused session, gated by §6.6's v1 contract.

The whole roadmap is roughly 6 months of sustained work if v1 ships in May 2026 and each subsequent version takes 4-6 weeks. v3 (cross-project marketplace) is the inflection point where Hexodus becomes a product worth other people installing. **Step 2 (baseline) is the prerequisite gate to everything else** — without it, every subsequent version's improvement claim is just vibes.
