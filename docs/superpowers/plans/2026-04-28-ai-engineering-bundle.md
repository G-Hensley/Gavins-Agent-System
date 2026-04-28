# AI Engineering Bundle Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Promote all 13 AI Engineering improvements from `improvements/` into live skill references, an agent, and a rule. One PR for the whole bundle.

**Architecture:** Add 9 new reference files under `skills/ai-engineering/references/`, split + expand `prompt-engineering.md` into basics + advanced, create `agents/llm-evaluator.md`, add `rules/llm-evals.md`, update `skills/ai-engineering/SKILL.md` to surface the refs, delete the 13 source improvement files in the same commits that promote them.

**Tech Stack:** Markdown only. No code, no tests in the traditional sense — verification is structural (file exists, line count ≤ 200, internal links resolve, cross-references match).

**Branch:** `feat/ai-engineering-bundle`. One PR at the end.

---

## File Structure

### Files to create

| Path | Source improvement | Approx lines |
|---|---|---|
| `skills/ai-engineering/references/agentic-design-patterns.md` | `new-skill-reference-agentic-design-patterns.md` | ~150 |
| `skills/ai-engineering/references/context-management.md` | `new-skill-reference-context-management.md` | ~120 |
| `skills/ai-engineering/references/tool-design.md` | `new-skill-reference-tool-design.md` | ~140 |
| `skills/ai-engineering/references/structured-output.md` | `new-skill-reference-structured-output.md` | ~140 |
| `skills/ai-engineering/references/mcp-engineering.md` | `new-skill-reference-mcp-engineering.md` | ~140 |
| `skills/ai-engineering/references/rag-engineering.md` | `new-skill-reference-rag-engineering.md` | ~160 |
| `skills/ai-engineering/references/streaming-patterns.md` | `new-skill-reference-streaming-patterns.md` | ~130 |
| `skills/ai-engineering/references/cost-optimization-and-routing.md` | `new-skill-reference-cost-optimization-and-routing.md` | ~140 |
| `skills/ai-engineering/references/llm-security.md` | `new-skill-reference-llm-security.md` | ~150 |
| `skills/ai-engineering/references/evaluation-and-observability.md` | `new-skill-reference-llm-evaluation-and-observability.md` | ~160 |
| `skills/ai-engineering/references/prompt-engineering-advanced.md` | `expand-prompt-engineering-with-advanced-techniques.md` (split) | ~180 |
| `agents/llm-evaluator.md` | `new-agent-llm-evaluator.md` | ~50 |
| `rules/llm-evals.md` | `establish-eval-suite-infrastructure-pattern.md` | ~120 |

### Files to modify

| Path | Change |
|---|---|
| `skills/ai-engineering/SKILL.md` | Add 11 new entries to "Reference Files" section; update `last_verified` to 2026-04-28 |
| `skills/ai-engineering/references/prompt-engineering.md` | Stays as "basics"; add cross-link to `prompt-engineering-advanced.md` at the bottom |
| `agents/ai-engineer.md` | (No change needed — already loads `ai-engineering` skill) |
| `agents/qa-engineer.md` | Add `ai-engineering` to skills list (LLM-feature work overlaps testing) |
| `agents/architect.md` | Add `ai-engineering` to skills list (designs that include LLM features) |
| `agents/backend-engineer.md` | Add `ai-engineering` to skills list (structured output, tool design overlap backend) |
| `agents/frontend-engineer.md` | Add `ai-engineering` to skills list (streaming patterns) |
| `agents/automation-engineer.md` | Add `ai-engineering` to skills list (tool design, agentic patterns) |
| `agents/backend-security-reviewer.md` | Add `ai-engineering` to skills list (llm-security ref) |
| `agents/appsec-reviewer.md` | Add `ai-engineering` to skills list (llm-security ref) |
| `agents/devops-engineer.md` | Add `ai-engineering` to skills list (cost-optimization, eval/obs) |

### Files to delete (one per task, same commit)

All 13 files in `improvements/skills/` and `improvements/agents/` and `improvements/system/` corresponding to the items above.

### Cross-bundle deferred links

`streaming-patterns.md` references `skills/security/references/websocket-security.md` (lives in Security bundle, not yet built). Use `<!-- TODO(security-bundle): link to websocket-security.md when promoted -->` placeholder; resolve when Security bundle ships.

`llm-security.md` references the same target — same placeholder treatment.

### Order rationale

Ref files first (independent), then the SKILL.md update that surfaces them all, then `llm-evaluator` agent (depends on the eval/obs ref), then `rules/llm-evals.md` (depends on the agent), then agent-skill-list updates, then PR. Within ref files the order minimizes "TODO add link later" loops by creating dependencies first.

---

## Task 1: Branch setup

**Files:**
- No file changes; git only

- [ ] **Step 1: Create the bundle branch from `main`**

```bash
git fetch origin
git checkout main
git pull --ff-only origin main
git checkout -b feat/ai-engineering-bundle
```

- [ ] **Step 2: Verify clean working tree**

Run: `git status`
Expected: `On branch feat/ai-engineering-bundle` and `nothing to commit, working tree clean`

---

## Task 2: Add `agentic-design-patterns.md`

**Files:**
- Create: `skills/ai-engineering/references/agentic-design-patterns.md`
- Delete: `improvements/skills/new-skill-reference-agentic-design-patterns.md`

**Source spec:** `improvements/skills/new-skill-reference-agentic-design-patterns.md`

**Sections to write (per source proposal):**
1. Pattern selection ladder (Level 0–4) at top, one-line decision criterion per level
2. ReAct — loop structure, iteration cap default (5–15), give-up clause, logging requirements
3. Reflection — self vs. external critic, evaluation criteria specificity, revision cap (2–3), cheaper-model-for-critic pattern
4. Planning (plan-then-execute) — when vs. ReAct, plan revision, dependency tracking, model split (planner ≥ executor)
5. Human-in-the-Loop — approval gates, escalation thresholds, destructive-action confirmation, state machine note
6. Evaluator-Optimizer — retry cap, cost ceiling, criteria specificity, log-every-eval requirement
7. Anti-pattern list — unbounded loops, vague critic prompts, planning when requirements unclear

**Cross-links to include:**
- `evaluation-and-observability.md` (built later — use relative link `./evaluation-and-observability.md`; verify at end)
- `cost-optimization-and-routing.md` (built later — same approach)

- [ ] **Step 1: Write the file**

Create `skills/ai-engineering/references/agentic-design-patterns.md` from the spec. Include short code skeletons (Python or pseudo-code) per pattern as the source proposal recommends. Cap at 200 lines.

- [ ] **Step 2: Verify line count**

Run: `wc -l skills/ai-engineering/references/agentic-design-patterns.md`
Expected: ≤ 200

- [ ] **Step 3: Delete the source improvement**

```bash
git rm improvements/skills/new-skill-reference-agentic-design-patterns.md
```

- [ ] **Step 4: Commit**

```bash
git add skills/ai-engineering/references/agentic-design-patterns.md
git commit -m "feat(ai-engineering): add agentic-design-patterns reference"
```

---

## Task 3: Add `context-management.md`

**Files:**
- Create: `skills/ai-engineering/references/context-management.md`
- Delete: `improvements/skills/new-skill-reference-context-management.md`

**Source spec:** `improvements/skills/new-skill-reference-context-management.md`

**Sections:**
1. Token budget allocation table (system / history / RAG / tools / output reserve) with defaults
2. Conversation history strategies — sliding window, summarization, hierarchical memory, selective inclusion, with selection criteria
3. RAG context optimization — lost in the middle, ordering rule (best at start AND end), context compression
4. Tool definition cost — count tokens, decision rule for dispatcher pattern
5. Anti-pattern list — fill-the-window-because-you-can, summarize-everything (loses nuance), pure-recency selection

**Cross-links:**
- `rag-engineering.md` (forward-link, will exist after Task 7)
- `tool-design.md` (forward-link, will exist after Task 4)

- [ ] **Step 1: Write the file** — under 200 lines, structured per spec.
- [ ] **Step 2: Verify line count** — `wc -l skills/ai-engineering/references/context-management.md`
- [ ] **Step 3: Delete source** — `git rm improvements/skills/new-skill-reference-context-management.md`
- [ ] **Step 4: Commit** — `git commit -am "feat(ai-engineering): add context-management reference"` (use `-am` only if no new files; else `git add` first)

---

## Task 4: Add `tool-design.md`

**Files:**
- Create: `skills/ai-engineering/references/tool-design.md`
- Delete: `improvements/skills/new-skill-reference-tool-design.md`

**Source spec:** `improvements/skills/new-skill-reference-tool-design.md`

**Sections:**
1. Naming and descriptions — bad/good examples (`search` → `search_customer_orders`)
2. Parameter design — typed, enumerated, defaults, single-action discipline
3. Return shapes — structured data not prose, standard error envelope
4. Tool count limits — 5–10 comfortable, dispatcher pattern when exceeded; ~30-line dispatcher example
5. Selection accuracy testing — eval pattern for "given input, did agent pick right tool with right params"
6. Anti-pattern list — `do_everything(mode=...)`, prose returns, exceptions instead of structured errors, undocumented "do NOT use for"

**Cross-links:**
- `evaluation-and-observability.md` (forward, exists after Task 11)
- Mention `mcp-builder` skill exists separately, do not duplicate

- [ ] **Step 1: Write the file** — include the dispatcher example.
- [ ] **Step 2: Verify line count.**
- [ ] **Step 3: Delete source.**
- [ ] **Step 4: Commit** — `feat(ai-engineering): add tool-design reference`

---

## Task 5: Add `structured-output.md`

**Files:**
- Create: `skills/ai-engineering/references/structured-output.md`
- Delete: `improvements/skills/new-skill-reference-structured-output.md`

**Source spec:** `improvements/skills/new-skill-reference-structured-output.md`

**Sections:**
1. Four generations table — name / what it guarantees / when / providers
2. Syntactic vs. semantic correctness — constrained output still needs evals
3. Schema design rules — flat structure, descriptive names, descriptions as guidance, enums, **reasoning-before-decision** ordering
4. Worked example — same task, four implementations (Gen 1 prompt-only, Gen 2 JSON mode, Gen 3 schema-enforced, Gen 4 constrained decoding via Outlines)
5. Anti-pattern list — `decision` before `reasoning`, free-text where enums fit, deeply nested schemas, missing `additionalProperties`

**Cross-links:**
- `prompt-engineering-advanced.md` (forward, exists after Task 12)

- [ ] **Step 1: Write the file** — include the four-implementation worked example.
- [ ] **Step 2: Verify line count.**
- [ ] **Step 3: Delete source.**
- [ ] **Step 4: Commit** — `feat(ai-engineering): add structured-output reference`

---

## Task 6: Add `mcp-engineering.md`

**Files:**
- Create: `skills/ai-engineering/references/mcp-engineering.md`
- Delete: `improvements/skills/new-skill-reference-mcp-engineering.md`

**Source spec:** `improvements/skills/new-skill-reference-mcp-engineering.md`

**Sections:**
1. What MCP is — JSON-RPC 2.0, "USB-C for AI", governance
2. Architecture — Host / Client / Server (ASCII sketch)
3. Transport — stdio vs. Streamable HTTP, when each
4. Three primitives — Tools, Resources, Prompts; concrete example each; tool-vs-resource decision
5. MCP vs. function calling — they pair (MCP discovers/connects; function calling invokes)
6. Security — tool poisoning, indirect injection via tool outputs, over-permissioning, server trust model
7. When MCP vs. direct function calling
8. Brief catalog of common MCP servers (filesystem, web search, GitHub) at bottom

**Cross-links:**
- `llm-security.md` (forward, exists after Task 10) for indirect-injection-via-tool-outputs
- `tool-design.md` (Task 4) for tool-design principles
- Reference `mcp-builder` skill (server-author-facing) without duplicating

- [ ] **Step 1: Write the file.**
- [ ] **Step 2: Verify line count.**
- [ ] **Step 3: Delete source.**
- [ ] **Step 4: Commit** — `feat(ai-engineering): add mcp-engineering reference`

---

## Task 7: Add `rag-engineering.md`

**Files:**
- Create: `skills/ai-engineering/references/rag-engineering.md`
- Delete: `improvements/skills/new-skill-reference-rag-engineering.md`

**Source spec:** `improvements/skills/new-skill-reference-rag-engineering.md`

**Sections:**
1. High-level flow — embed → retrieve → **rerank** → inject → generate → cite (rerank first-class)
2. Chunking strategies — fixed-size, semantic, structural/heading-aware (default for docs), parent-child, contextual retrieval (Anthropic 2024)
3. Retrieval strategy — hybrid (dense + sparse + RRF) as default; RRF code snippet; when dense-only or sparse-only
4. Query rewriting — HyDE, expansion, sub-question decomposition; when each helps
5. Reranking — K=20–50 → N=3–5 with cross-encoder (Cohere Rerank, BGE Reranker, ms-marco-MiniLM); latency tradeoff stated explicitly
6. Evaluation split — retrieval (Precision@K, Recall@K, MRR) vs. generation (faithfulness, relevance, completeness); RAGAS / TruLens / DeepEval / custom LLM-as-judge
7. Context optimization — 3–5 chunks beats 10–15; link to `context-management.md`

**Cross-links:**
- `context-management.md` (Task 3)
- `evaluation-and-observability.md` (forward)
- `llm-security.md` (forward, mentions vector poisoning)

- [ ] **Step 1: Write the file** — include RRF snippet (~10 lines Python).
- [ ] **Step 2: Verify line count** — if approaching 200, plan a sub-skill split (`rag/` subdir) note in PR description for follow-up.
- [ ] **Step 3: Delete source.**
- [ ] **Step 4: Commit** — `feat(ai-engineering): add rag-engineering reference`

---

## Task 8: Add `streaming-patterns.md`

**Files:**
- Create: `skills/ai-engineering/references/streaming-patterns.md`
- Delete: `improvements/skills/new-skill-reference-streaming-patterns.md`

**Source spec:** `improvements/skills/new-skill-reference-streaming-patterns.md`

**Sections:**
1. Why stream — TTFT framing, when streaming isn't worth it
2. Provider APIs — Anthropic `messages.stream` and OpenAI `stream=True` snippets
3. SSE for web — minimal handler example, event types (`text_delta`, `tool_use_start`, `tool_use_result`, `message_stop`)
4. WebSocket alternative — when bidirectional matters; cross-bundle TODO link
5. Tool use mid-stream — UX pattern, indicator messaging, server-side state handling
6. Streaming structured output — three options with **prose-then-JSON-whole** as default
7. Anti-pattern list — buffer-and-stream (no point), top-tier model with no streaming, no error handling on stream interruption
8. Client snippets — both `EventSource` and `fetch` ReadableStream (per spec open-question recommendation)

**Cross-bundle TODO:**
```html
<!-- TODO(security-bundle): link to skills/security/references/websocket-security.md when Security bundle ships -->
```

- [ ] **Step 1: Write the file** — include both client snippets.
- [ ] **Step 2: Verify line count.**
- [ ] **Step 3: Delete source.**
- [ ] **Step 4: Commit** — `feat(ai-engineering): add streaming-patterns reference`

---

## Task 9: Add `cost-optimization-and-routing.md`

**Files:**
- Create: `skills/ai-engineering/references/cost-optimization-and-routing.md`
- Delete: `improvements/skills/new-skill-reference-cost-optimization-and-routing.md`

**Source spec:** `improvements/skills/new-skill-reference-cost-optimization-and-routing.md`

**Sections:**
1. Routing strategies — task type, input analysis, **confidence cascade** (highest leverage); cascade code skeleton
2. Caching — three layers (provider prompt cache, app semantic cache, embedding cache); when each
3. Prompt prefix stability rules — what to put / NOT put in the prefix (no timestamps, no user IDs, no random tokens); show Anthropic `cache_control` markers AND OpenAI automatic
4. Cost tracking — required log fields (model, in/out tokens, computed cost, cache hit/miss, total latency)
5. Budget ceilings + graceful degradation — return-cached, return-truncated, return-error patterns
6. Anti-pattern list — top-tier for every request, cache without similarity threshold, untracked LLM spend

**Cross-links:**
- `structured-output.md` (Task 5) — cascade requires confidence scores in structured output

- [ ] **Step 1: Write the file** — include cascade skeleton (~15 lines).
- [ ] **Step 2: Verify line count.**
- [ ] **Step 3: Delete source.**
- [ ] **Step 4: Commit** — `feat(ai-engineering): add cost-optimization-and-routing reference`

---

## Task 10: Add `llm-security.md`

**Files:**
- Create: `skills/ai-engineering/references/llm-security.md`
- Delete: `improvements/skills/new-skill-reference-llm-security.md`

**Source spec:** `improvements/skills/new-skill-reference-llm-security.md`

**Sections:**
1. Direct vs. indirect prompt injection — examples, why indirect is the dangerous one
2. Defense layers (5, none sufficient alone) with concrete examples per layer
3. System prompt hardening template — instructions at start AND end, delimiter tags, explicit anti-injection clause
4. Privilege separation pattern — propose/dispose split, worked example (LLM drafts DELETE; non-LLM validator confirms; only validator executes)
5. **OWASP LLM Top 10 (2025)** — entire list, one-paragraph entry each, with one defense or detection per item
6. RAG-specific attacks — vector poisoning, adversarial documents; link to `rag-engineering.md` (Task 7)
7. Detection rules sketch — brief Semgrep / regex starting points with explicit false-positive note

**Cross-bundle TODO:**
```html
<!-- TODO(security-bundle): cross-link from skills/security/SKILL.md when Security bundle ships -->
```

- [ ] **Step 1: Write the file** — full OWASP LLM Top 10 list.
- [ ] **Step 2: Verify line count.**
- [ ] **Step 3: Delete source.**
- [ ] **Step 4: Commit** — `feat(ai-engineering): add llm-security reference`

---

## Task 11: Add `evaluation-and-observability.md`

**Files:**
- Create: `skills/ai-engineering/references/evaluation-and-observability.md`
- Delete: `improvements/skills/new-skill-reference-llm-evaluation-and-observability.md`

**Source spec:** `improvements/skills/new-skill-reference-llm-evaluation-and-observability.md`

**Sections:**
1. Why eval is non-optional — one-paragraph framing
2. Offline eval types — assertion-based, LLM-as-judge (with prompt template), human evaluation, reference-based (BLEU/ROUGE/exact/cosine)
3. Online eval — trace-level scoring, sampling-based LLM-as-judge, drift detection (embedding distributions, output patterns), user feedback
4. Eval suite anatomy — 50–200 cases, criteria specificity, thresholds, regression triggers
5. Required tracing fields per LLM call — full input/output, model+version, tokens, cost, latency (TTFT + total), tool calls, trace ID
6. Tool selection — Langfuse / Arize / LangSmith / Braintrust / OpenTelemetry; pick-by-need
7. Anti-pattern list — "we test it manually," "users will tell us," "we'll add evals later"
8. Minimum viable eval bar to ship: ≥30 hand-curated cases, criteria defined, traces enabled

**Cross-links:**
- `agentic-design-patterns.md` (Task 2) — evaluator-optimizer pattern uses eval
- `rag-engineering.md` (Task 7) — RAG eval split

- [ ] **Step 1: Write the file** — include LLM-as-judge prompt template.
- [ ] **Step 2: Verify line count** — likely close to 200; split into sub-files only if over.
- [ ] **Step 3: Delete source.**
- [ ] **Step 4: Commit** — `feat(ai-engineering): add evaluation-and-observability reference`

---

## Task 12: Split + expand `prompt-engineering.md`

**Files:**
- Modify: `skills/ai-engineering/references/prompt-engineering.md`
- Create: `skills/ai-engineering/references/prompt-engineering-advanced.md`
- Delete: `improvements/skills/expand-prompt-engineering-with-advanced-techniques.md`

**Source spec:** `improvements/skills/expand-prompt-engineering-with-advanced-techniques.md`

**Approach:** Keep `prompt-engineering.md` as the basics file (current 52 lines). Add a "See also" footer pointing to advanced. Create the advanced file with:

1. Chain of Thought (CoT) — phrasing, structured-output integration (link to `structured-output.md` Task 5), provider variants (Anthropic `<thinking>` tags, OpenAI o-series intrinsic, Anthropic extended-thinking parameter)
2. Prompt decomposition — when to split, common shapes (Extract/Analyze/Synthesize), debugging payoff
3. Context positioning — start and end attention, repeat critical instructions, RAG ordering rule (link to `rag-engineering.md` Task 7)
4. Negative examples — when "do not" pairs help; canonical examples
5. Temperature and sampling — selection by task; **never combine high temp + Gen 1 structured output**; per-provider defaults table
6. Anti-pattern list — CoT requested but no `<thinking>` allowance, unbroken complex prompts, default temperature for everything

- [ ] **Step 1: Write `prompt-engineering-advanced.md`** — full content per spec.
- [ ] **Step 2: Update `prompt-engineering.md`** — add a "See also" line at the end:

```markdown

---

For advanced techniques (Chain of Thought, decomposition, context positioning, temperature selection), see [prompt-engineering-advanced.md](./prompt-engineering-advanced.md).
```

- [ ] **Step 3: Verify both line counts** — both ≤ 200.
- [ ] **Step 4: Delete source.**
- [ ] **Step 5: Commit**

```bash
git add skills/ai-engineering/references/prompt-engineering.md skills/ai-engineering/references/prompt-engineering-advanced.md
git rm improvements/skills/expand-prompt-engineering-with-advanced-techniques.md
git commit -m "feat(ai-engineering): split + expand prompt-engineering with advanced techniques"
```

---

## Task 13: Update `skills/ai-engineering/SKILL.md`

**Files:**
- Modify: `skills/ai-engineering/SKILL.md`

**Changes:**
1. Update `last_verified: 2026-04-04` → `last_verified: 2026-04-28`
2. In the "Reference Files" section (currently 3 entries), add 11 new entries — one per file created in Tasks 2–12. Keep entries one-line each.
3. Add a brief note in section "3. Design the Architecture" that points readers to `agentic-design-patterns.md` for the pattern selection ladder, and to `context-management.md` for token-budget defaults.
4. Add a brief note in section "4. Implement and Test" that points to `evaluation-and-observability.md` for eval suite design.

- [ ] **Step 1: Update frontmatter `last_verified`.**
- [ ] **Step 2: Append the 11 new reference entries** to the "Reference Files" list.

Suggested format per entry (keep one line each):

```markdown
- `references/agentic-design-patterns.md` — ReAct, Reflection, Planning, Human-in-the-Loop, Evaluator-Optimizer; pattern selection ladder. Read when designing any agent loop.
- `references/context-management.md` — Token budget allocation, conversation-history strategies, lost-in-the-middle. Read when designing memory or context-heavy systems.
- `references/tool-design.md` — Tool naming, descriptions, parameter design, dispatcher pattern. Read when authoring tools for any agent.
- `references/structured-output.md` — Four generations, schema design rules, reasoning-before-decision ordering. Read when designing structured output.
- `references/mcp-engineering.md` — MCP architecture, transport, primitives, security model. Read when consuming or integrating MCP servers.
- `references/rag-engineering.md` — Chunking, hybrid retrieval, reranking, RAG eval split. Read when building RAG.
- `references/streaming-patterns.md` — TTFT framing, SSE, tool-use mid-stream, structured output streaming. Read when building user-facing AI features.
- `references/cost-optimization-and-routing.md` — Routing strategies (cascade), caching, cost tracking, budget ceilings. Read when running LLM features in production.
- `references/llm-security.md` — Prompt injection, OWASP LLM Top 10, defense layers, privilege separation. Read when reviewing or building LLM features.
- `references/evaluation-and-observability.md` — Offline + online eval, tracing, drift detection, eval suite anatomy. Read when shipping any LLM feature to production.
- `references/prompt-engineering-advanced.md` — Chain of Thought, decomposition, context positioning, temperature. Read after `prompt-engineering.md` for production prompts.
```

- [ ] **Step 3: Add cross-links in the Process sections** as described.
- [ ] **Step 4: Verify line count** ≤ 200.

Run: `wc -l skills/ai-engineering/SKILL.md`

- [ ] **Step 5: Commit**

```bash
git add skills/ai-engineering/SKILL.md
git commit -m "docs(ai-engineering): surface new references in SKILL.md"
```

---

## Task 14: Create `agents/llm-evaluator.md`

**Files:**
- Create: `agents/llm-evaluator.md`
- Delete: `improvements/agents/new-agent-llm-evaluator.md`

**Source spec:** `improvements/agents/new-agent-llm-evaluator.md`

**Frontmatter (per spec):**

```yaml
---
name: llm-evaluator
description: LLM evaluation specialist. Use when designing eval suites for LLM features, calibrating LLM-as-judge prompts, interpreting drift, deciding pass thresholds. Dispatches alongside `ai-engineer` during build, and during incident review. Builds offline + online eval, tracing strategy, regression triggers on prompt changes.
tools: Read, Write, Edit, Bash, Grep
model: sonnet
skills:
  - ai-engineering
  - qa-engineering
memory: user
---
```

(Note: the spec proposes Sonnet — match that. The agent loads the entire `ai-engineering` skill which now includes `evaluation-and-observability.md`, `structured-output.md`, `llm-security.md`, and `rag-engineering.md`. Plus `qa-engineering` skill for general testing discipline.)

**Body sections (per spec):**
- "How You Work" — eval design steps (define criteria → curate cases → set thresholds → wire to CI → calibrate judge → trace from day one)
- "What You Build" — eval suites, LLM-as-judge prompt templates, drift dashboards, regression tests, blameless eval-failure post-mortems
- "What You Don't Do" — vibes-only testing, vague criteria, low-temperature judge calibration without inter-rater check, "we'll add evals later"
- "Coexistence with `qa-engineer`" — qa-engineer owns deterministic; llm-evaluator owns probabilistic; explicit handoff
- "Authority" — may **block** prompt/model changes when evals regress (per CLAUDE.md eval-first rule once Task 15 lands)

- [ ] **Step 1: Write the agent file** — match style of existing agents (`ai-engineer.md` is the closest template).
- [ ] **Step 2: Verify line count** ≤ 200.
- [ ] **Step 3: Delete source.**
- [ ] **Step 4: Commit** — `feat(agents): add llm-evaluator specialist`

---

## Task 15: Create `rules/llm-evals.md`

**Files:**
- Create: `rules/llm-evals.md`
- Delete: `improvements/system/establish-eval-suite-infrastructure-pattern.md`

**Source spec:** `improvements/system/establish-eval-suite-infrastructure-pattern.md`

**Note:** This is **per-project** eval suite convention. NOT the §6 Baseline. Add an explicit scope note at the top:

```markdown
# LLM Evals (Per-Project)

> Scope: this rule governs eval suites for LLM features inside operator's user-facing projects. It does NOT govern the agent system's own §6 baseline harness — that lives in `evals/` at the root of this repo and is governed separately by ROADMAP §6.
```

**Sections:**
1. Scope clarification (above)
2. Directory layout per project — `docs/evals/` with subdirs `cases/`, `judges/`, `runners/`, `results/`
3. Runner contract — input (case file paths), output (structured results + summary), exit code 0 if pass thresholds met, non-zero otherwise
4. CI integration — run on every PR touching prompts/models/RAG/tools/AI-pipeline code; block merge on regression
5. Eval-first rule — new LLM features need ≥30 hand-curated cases + criteria + thresholds before merge; prompt changes require eval pass; cross-link to `agents/llm-evaluator.md` (Task 14)
6. JSONL format for case files (open question resolved as JSONL in spec)

- [ ] **Step 1: Write the rule file.**
- [ ] **Step 2: Verify line count** ≤ 200.
- [ ] **Step 3: Delete source.**
- [ ] **Step 4: Commit** — `feat(rules): add llm-evals per-project convention`

---

## Task 16: Update agent skill loads

**Files (modify each):**
- `agents/qa-engineer.md`
- `agents/architect.md`
- `agents/backend-engineer.md`
- `agents/frontend-engineer.md`
- `agents/automation-engineer.md`
- `agents/backend-security-reviewer.md`
- `agents/appsec-reviewer.md`
- `agents/devops-engineer.md`

**Pattern per file:** Add `ai-engineering` to the `skills:` list in frontmatter. If the skills list doesn't exist, add it. Example:

```yaml
# Before
skills:
  - frontend-engineering

# After
skills:
  - frontend-engineering
  - ai-engineering
```

- [ ] **Step 1: Read each file**, locate the frontmatter `skills:` block.
- [ ] **Step 2: Add `ai-engineering` to the list** (preserve existing entries; alphabetize is optional).
- [ ] **Step 3: Verify each file is still under 200 lines.**
- [ ] **Step 4: Commit**

```bash
git add agents/qa-engineer.md agents/architect.md agents/backend-engineer.md agents/frontend-engineer.md agents/automation-engineer.md agents/backend-security-reviewer.md agents/appsec-reviewer.md agents/devops-engineer.md
git commit -m "feat(agents): load ai-engineering skill across cross-cutting agents"
```

---

## Task 17: Final verification pass

**Goal:** Confirm the full bundle is internally consistent before opening the PR.

- [ ] **Step 1: Verify all expected files exist**

```bash
ls skills/ai-engineering/references/agentic-design-patterns.md \
   skills/ai-engineering/references/context-management.md \
   skills/ai-engineering/references/tool-design.md \
   skills/ai-engineering/references/structured-output.md \
   skills/ai-engineering/references/mcp-engineering.md \
   skills/ai-engineering/references/rag-engineering.md \
   skills/ai-engineering/references/streaming-patterns.md \
   skills/ai-engineering/references/cost-optimization-and-routing.md \
   skills/ai-engineering/references/llm-security.md \
   skills/ai-engineering/references/evaluation-and-observability.md \
   skills/ai-engineering/references/prompt-engineering-advanced.md \
   agents/llm-evaluator.md \
   rules/llm-evals.md
```

Expected: all 13 paths listed without "No such file" errors.

- [ ] **Step 2: Verify all line counts**

```bash
wc -l skills/ai-engineering/SKILL.md skills/ai-engineering/references/*.md agents/llm-evaluator.md rules/llm-evals.md
```

Expected: every line count ≤ 200.

- [ ] **Step 3: Verify all 13 source improvement files are deleted**

```bash
ls improvements/skills/new-skill-reference-agentic-design-patterns.md 2>&1 | grep -c "No such file" || echo "MISSING: file still exists"
# Repeat for each of the 13 source files OR run:
ls improvements/agents/new-agent-llm-evaluator.md \
   improvements/system/establish-eval-suite-infrastructure-pattern.md \
   improvements/skills/expand-prompt-engineering-with-advanced-techniques.md \
   improvements/skills/new-skill-reference-*.md 2>&1
```

Expected: every source file should be `No such file or directory` (or absent from the listing).

- [ ] **Step 4: Verify no broken internal links**

```bash
# Check for any markdown link to a missing target inside the new ref files
grep -rE '\]\(\.?\/?(skills|agents|rules)/[^)]+\)' skills/ai-engineering/references/ agents/llm-evaluator.md rules/llm-evals.md
```

Manually scan the output: each linked path should resolve to a real file. Cross-bundle TODO comments are expected and acceptable.

- [ ] **Step 5: Verify cross-bundle TODOs are explicit**

```bash
grep -rn "TODO(security-bundle)" skills/ai-engineering/references/
```

Expected: exactly two matches (in `streaming-patterns.md` and `llm-security.md`).

- [ ] **Step 6: Verify ai-engineering SKILL.md surfaces every new ref**

```bash
for f in agentic-design-patterns context-management tool-design structured-output mcp-engineering rag-engineering streaming-patterns cost-optimization-and-routing llm-security evaluation-and-observability prompt-engineering-advanced; do
  grep -q "$f" skills/ai-engineering/SKILL.md || echo "MISSING: $f not in SKILL.md"
done
```

Expected: no output (every reference is surfaced).

- [ ] **Step 7: Verify cross-cutting agents load `ai-engineering`**

```bash
for a in qa-engineer architect backend-engineer frontend-engineer automation-engineer backend-security-reviewer appsec-reviewer devops-engineer; do
  grep -q "ai-engineering" agents/$a.md || echo "MISSING: ai-engineering not in $a.md"
done
```

Expected: no output.

- [ ] **Step 8: Commit any fix-ups** discovered during verification.

If anything is broken, fix and commit with message: `fix(ai-engineering): <specific fix>`. Then re-run Steps 1–7.

---

## Task 18: Open the PR

- [ ] **Step 1: Push the branch**

```bash
git push -u origin feat/ai-engineering-bundle
```

- [ ] **Step 2: Open the PR**

```bash
gh pr create --title "feat(ai-engineering): promote AI Engineering improvements bundle" --body "$(cat <<'EOF'
## Summary

Promotes the entire AI Engineering Depth bundle from `improvements/` into live skill references, an agent, and a rule. 13 items total.

### Added
- 9 new references under `skills/ai-engineering/references/`
- 1 split (`prompt-engineering.md` basics + new `prompt-engineering-advanced.md`)
- 1 new agent (`agents/llm-evaluator.md`, Sonnet-class)
- 1 new rule (`rules/llm-evals.md`, per-project eval convention)

### Changed
- `skills/ai-engineering/SKILL.md` — surfaces all 11 new references; `last_verified` bumped
- 8 cross-cutting agents now load the `ai-engineering` skill (qa, architect, backend, frontend, automation, backend-security-reviewer, appsec-reviewer, devops)

### Removed
- 13 source files in `improvements/` (one per promoted item)

### Cross-bundle deferrals
Two TODO links to `skills/security/references/websocket-security.md` will be resolved when the Security bundle ships.

### Out of scope
- Per-project eval suite (`rules/llm-evals.md`) is NOT the §6 baseline harness; baseline lives in `evals/` at repo root and is governed separately by ROADMAP §6.

## Test plan
- [x] All expected files exist
- [x] Every file ≤ 200 lines
- [x] All 13 source `improvements/` files deleted
- [x] No broken internal links (cross-bundle TODOs excepted)
- [x] `ai-engineering` SKILL.md surfaces every new reference
- [x] All cross-cutting agents load `ai-engineering`

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```

- [ ] **Step 3: Capture the PR URL** in the output and report back.

---

## Self-Review Checklist (run after writing this plan)

**Spec coverage:** All 13 AI Engineering improvements have a corresponding task. ✅

| Improvement file | Task |
|---|---|
| `new-skill-reference-agentic-design-patterns.md` | Task 2 |
| `new-skill-reference-context-management.md` | Task 3 |
| `new-skill-reference-tool-design.md` | Task 4 |
| `new-skill-reference-structured-output.md` | Task 5 |
| `new-skill-reference-mcp-engineering.md` | Task 6 |
| `new-skill-reference-rag-engineering.md` | Task 7 |
| `new-skill-reference-streaming-patterns.md` | Task 8 |
| `new-skill-reference-cost-optimization-and-routing.md` | Task 9 |
| `new-skill-reference-llm-security.md` | Task 10 |
| `new-skill-reference-llm-evaluation-and-observability.md` | Task 11 |
| `expand-prompt-engineering-with-advanced-techniques.md` | Task 12 |
| `new-agent-llm-evaluator.md` | Task 14 |
| `establish-eval-suite-infrastructure-pattern.md` | Task 15 |

Plus Task 13 (SKILL.md update), Task 16 (agent skill-load updates), Task 17 (verification), Task 18 (PR).

**Placeholder scan:** No "TBD," "implement later," "TODO" except the explicit cross-bundle deferrals which are documented.

**Type consistency:** All file paths, frontmatter shapes, and cross-link targets are consistent across tasks.

---

## Execution Handoff

Plan complete and saved to `docs/superpowers/plans/2026-04-28-ai-engineering-bundle.md`. Two execution options:

**1. Subagent-Driven (recommended)** — Fresh subagent per task, review between tasks, fast iteration. Each ref-file task is a clean, isolated context — well-suited to subagent dispatch.

**2. Inline Execution** — Execute tasks in this session. Faster wall-clock for one operator; main-context grows as we go.

Which approach?
