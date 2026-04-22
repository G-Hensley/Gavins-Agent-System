# Agent System — Status Tracker

Current status of improvements from [IMPROVEMENTS.md](./IMPROVEMENTS.md) and eval runs.

Last updated: 2026-04-22

---

## Improvements Roadmap

| # | Improvement | Status | Notes |
|---|---|---|---|
| 1 | Eval suite — structure | Done | evals/ with README, run-eval.sh, agent-coverage.md |
| 1 | Eval suite — Tier 1 prompts | Done | 4 evals: cli-calculator, rest-endpoint, dockerfile, chatbot-cli |
| 1 | Eval suite — Tier 2 prompts | Done | 3 evals: tic-tac-toe, file-watcher, secrets-scanning |
| 1 | Eval suite — Tier 3 prompts | Done | 3 evals: snake-game, threejs-scene, rag-system |
| 1 | Eval suite — Tier 4 prompts | Done | 1 eval: task-manager-app |
| 1 | Review challenges (6/6) | Done | sql-injection, xss, iam, deps, spec-deviation, code-quality |
| 2 | Validation script | Done | scripts/validate.sh — 236 checks across 9 categories |
| 2 | install.sh improvements | Done | --dry-run, --verify, --help flags |
| 3 | Agent memory directories | Done | All 24 agents have agent-memory/<name>/MEMORY.md |
| 4 | Improvements backlog bootstrap | Done | README, 3 seeded suggestions, system/ directory |
| 5 | CONTEXT.md | Done | Pipeline, parallelism, architecture, eval system |
| 6 | Plans directory hygiene | Done | Old session plans removed |
| 7 | Skill composition & dependencies | Done | docs/SKILL-CHAINS.md + `follows:` frontmatter on 5 skills |
| 8 | Handoff protocols | Done | docs/HANDOFF-PROTOCOLS.md + ## Handoff in 5 agent files |
| 9 | Failure mode documentation | Done | docs/FAILURE-MODES.md — 7 scenarios with escalation |
| 10 | Skill staleness detection | Done | `last_verified` on all skills + validate.sh Check 9 |
| 11 | Cross-agent memory | Deferred | By design — revisit when proven needed |
| 12 | Agent parallelism map | Done | Documented in CONTEXT.md |
| 13 | Token tracking | Done | result.json scaffold + --results flag in run-eval.sh |
| 14 | Threat-modeler agent | Done | agents/threat-modeler.md + dispatch table + memory |

---

## Eval Runs

### Review Challenges (2026-04-03)

| Challenge | Target Agent | Planted | Caught | False Pos | Bonus | Grade |
|---|---|---|---|---|---|---|
| SQL Injection | backend-security-reviewer | 3 | 3 | 0 | 0 | PERFECT |
| XSS Vulnerability | frontend-security-reviewer | 3 | 3 | 0 | 0 | PERFECT |
| Overpermissive IAM | cloud-security-reviewer | 4 | 4 | 0 | 4 | EXCEEDED |
| Dependency Vulns | appsec-reviewer | 6 | 6 | 0 | 0 | PERFECT |
| Spec Deviation | spec-reviewer | 5 | 5 | 0 | 1 | STRONG PASS |
| Code Quality | code-quality-reviewer | 7 | 7 | 0 | 2 | EXCEEDED |

**Totals: 28/28 planted findings, 0 false positives, 7 bonus findings.**

### Tier 1 — Single Agent (2026-04-03)

| Eval | Agent | Tests | TDD | Verified | Grade |
|---|---|---|---|---|---|
| CLI Calculator | automation-engineer | 24 pass | Red->Green | 3 demo commands | PASS |
| REST Endpoint | backend-engineer | 15 pass | Red->Green | All routes tested | PASS |
| Dockerfile | devops-engineer | Build+Run | Verified live | curl + whoami | PASS |
| Chatbot CLI | ai-engineer | 18 pass | Red->Green | SDK mocked | PASS |

**4/4 passed. All followed TDD. All verified.**

### Tier 2 — Multi-Agent (2026-04-04)

| Eval | Agents Dispatched | Design First | TDD | Grade |
|---|---|---|---|---|
| Tic-Tac-Toe | uiux-designer -> frontend-engineer | Design system created | 26 tests Red->Green | PASS |
| File Watcher | automation-engineer -> devops-engineer | N/A | 19 tests Red->Green | PASS |
| Secrets Scanning | devsecops-engineer -> devops-engineer -> threat-modeler | N/A | N/A (config) | PASS |

**3/3 passed. All dispatched correct agents in correct order.**

### Tier 3 — Architecture-First (2026-04-04)

| Eval | Pipeline | Architecture | Threat Model | Tests | Grade |
|---|---|---|---|---|---|
| Snake Game | PRD -> Arch -> Threat -> Impl | Yes | 8 threats (VAST) | 57 tests | PASS |
| Three.js Scene | Design -> Arch -> Review -> Impl | Yes | Client-only (documented) | 28 tests | PASS |
| RAG System | Arch -> Threat -> AI + DB Eng | Yes | 10 threats (prompt injection) | 55 tests | PASS |

**3/3 passed. All produced architecture docs before implementation. Threat models where applicable.**

### Tier 4 — Full Workflow (2026-04-04)

| Stage | Agent(s) | Output |
|---|---|---|
| Brainstorm | brainstorming skill | brainstorm.md |
| PRD | product-manager | prd.md (12 user stories) |
| Architecture | architect | architecture.md (DynamoDB + 13 endpoints) |
| Threat Model | threat-modeler | threat-model.md (22 threats, STRIDE) |
| Plan | writing-plans | plan.md (19 tasks) |
| Implementation | backend-engineer + frontend-engineer | 42 source files, 104 tests |
| Quality Review | code-quality-reviewer | 10 findings, 4 critical fixed |
| Security Review | 4 reviewers in parallel | Critical fixes applied |
| Documentation | doc-writer | README + API ref + architecture overview |

**PASS — Full pipeline executed. 104 tests. 8 documentation files. Critical review findings resolved.**

---

## V2 Improvements (from Claude Code/Cowork research report)

| # | Improvement | Status | Notes |
|---|---|---|---|
| 15 | Path-scoped rules (`.claude/rules/`) | Done | 7 rule files in rules/ with glob-scoped activation |
| 16 | Dynamic context in skills (`` !`cmd` ``) | Done | Live git state, diffs, audit results injected into 5 skills |
| 17 | Hooks for structural enforcement | Done | 3 hook scripts + config template, install.sh merges into settings |
| 18 | Skill frontmatter modernization | Done | fork/opus on 5, allowed-tools on 3, paths on 6, user-invocable on 3 |
| 19 | Agent SDK evaluation | Deferred | Revisit if Tier 3/4 evals show dispatch failures |

## V3 Improvements (language/framework/tooling depth)

| # | Improvement | Status | Notes |
|---|---|---|---|
| 20 | Dependency management reference | Done | backend-engineering/references/dependency-management.md |
| 21 | TypeScript strictness rules | Done | rules/typescript.md enhanced with strictness rules |
| 22 | Python project structure rules | Done | rules/python.md enhanced with project structure |
| 23 | Project structure references | Done | nextjs-structure.md, python-structure.md, project-structure.md (AI) |
| 24 | Error handling patterns | Done | error-handling.md for backend + frontend |
| 25 | Database references expansion | Done | dynamodb-patterns.md, mongodb-patterns.md, postgresql-patterns.md |
| 26 | Google Cloud references | Done | gcp-infrastructure.md + gcp-security.md |
| 27 | API versioning + auto-docs | Done | versioning-and-docs.md in api-design |
| 28 | GitHub Actions CI/CD template | Done | templates/github-actions/ci.yml + claude-review.yml |
| 29 | Doc-sync skill + drift hook | Done | skills/doc-sync/, documentation.md rule, drift hook on structural changes |
| 30 | Codex plan review | Done | skills/codex-plan-review/, rules/codex-plan-review.md, 8 tier-1 fixtures, rescue-agent routing |
| 31 | Git health check | Done | skills/git-health-check/, commands/git-health-check.md — detects HEAD truncation, .corrupt.backup, dangling locks |
| 32 | PR check (rename+rewrite of resolve-pr-comments) | Done | skills/pr-check/, commands/pr-check.md, scripts/hooks/pr-push-nudge.sh — stale-detection, CI/merge state, thematic commits, Copilot retrigger |
| 33 | Tier-1 friction fixes | Done | CLAUDE.md Windows section, rules/reference-reading.md, scripts/hooks/file-size-cap.sh + gh-account-guard.sh |

## What's Left

### Eval Runs
- [x] Run Tier 2 evals — 3/3 passed
- [x] Run Tier 3 evals — 3/3 passed
- [x] Run Tier 4 eval — PASSED (full pipeline, 104 tests, 22 threats, 10 review findings)

### V3 Priority Order (system infrastructure first, then content)
1. TypeScript strictness rules (#21) — path-scoped, immediate quality impact
2. Python project structure rules (#22) — path-scoped, immediate quality impact
3. Dependency management reference (#20) — shared across 3 skills
4. Error handling patterns (#24) — backend + frontend + production hygiene
5. DynamoDB patterns reference (#25) — primary database, high priority
6. Next.js patterns reference (#23) — most-used frontend framework
7. API versioning + auto-docs (#27) — versioning + OAS generation
8. GitHub Actions CI/CD template (#28) — add to repo template
9. Additional database refs (#25) — MongoDB, PostgreSQL
10. Google Cloud references (#26) — when GCP projects start
11. Run remaining evals — with all new skills/rules in place

### From improvements/ backlog
- [x] Add caching patterns to backend-engineering skill — Done
- [x] Add threat-modeler to Tier 2 evals — Done
- [x] Wire run-eval.sh to execute evals automatically — Done (--run, --run-tier, --run-all)

### Deferred / Future
- Cross-agent memory (#11) — revisit when proven needed in practice
- CLAUDE.md splitting — evaluate after rules/ directory is in place
- Agent SDK (#19) — revisit if Tier 3/4 evals show dispatch failures
- React Native patterns — when mobile projects start
- Desktop app patterns (Electron/Tauri) — when desktop projects start
- Azure cloud references — when needed
- Monorepo patterns (pnpm workspaces/Turborepo) — when workspace projects start
