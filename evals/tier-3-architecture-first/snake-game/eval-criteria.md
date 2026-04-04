# Eval Criteria — Snake Game

Scoring: 0 = missed, 1 = partial, 2 = full credit. Maximum score: 16 points (8 criteria × 2).

---

## 1. Dispatch Correctness

**Full credit (2):** All required agents dispatched in the correct order:
- `product-manager` → produces PRD before any design begins
- `architect` → produces design doc before any implementation begins
- `architecture-reviewer` → reviews the design doc before implementation
- `threat-modeler` → dispatched after architect, before implementation
- `plan-reviewer` → reviews the implementation plan before work starts
- `backend-engineer` → implements game server and leaderboard API
- `frontend-engineer` → implements browser client (dispatched only after design exists)
- `qa-engineer` → writes and runs tests, validates end-to-end behavior
- `product-reviewer` → reviews final output against PRD

**Partial (1):** At least 5 of the 9 agents dispatched, core sequence mostly preserved (architect before implementation, reviewers after their target artifact).

**Zero (0):** Implementation begins without a PRD or design doc, or fewer than 5 agents dispatched.

---

## 2. Architecture Produced Before Implementation

**Full credit (2):** A design document exists and was committed before any implementation code. It must include:
- Component diagram or description (server, client, leaderboard, WebSocket protocol)
- Data model for leaderboard entries
- WebSocket message schema (at minimum: join, move, state-update, game-over)
- Tick rate and game-loop design decision
- Chosen storage backend with rationale

**Partial (1):** Design doc exists but is missing 2 or more of the above elements, or it was produced after implementation started.

**Zero (0):** No design doc produced, or design doc is a stub without architectural decisions.

---

## 3. Architecture Reviewed

**Full credit (2):** `architecture-reviewer` dispatched after design doc is produced and before implementation begins. Review output identifies at least one real concern (e.g., missing reconnection handling, no rate limiting on move events, leaderboard race condition under concurrent writes, missing auth on room join).

**Partial (1):** Reviewer dispatched but review output is superficial (no specific issues identified) or dispatched after implementation started.

**Zero (0):** `architecture-reviewer` not dispatched.

---

## 4. Threat Model Produced

**Full credit (2):** `threat-modeler` dispatched after architect, output includes:
- At least 3 specific threats relevant to the system (e.g., move flooding / DoS via WebSocket spam, score tampering if client controls score, room enumeration, leaderboard injection)
- Mitigations proposed for each threat

**Partial (1):** Threat model produced but covers fewer than 3 threats, or threats are generic and not specific to this system.

**Zero (0):** `threat-modeler` not dispatched.

---

## 5. Plan Reviewed

**Full credit (2):** `plan-reviewer` dispatched after the implementation plan is produced and before work begins. Review output notes at least one issue (e.g., frontend dispatched before backend is complete, no plan for WebSocket reconnection, tests planned only for happy path).

**Partial (1):** `plan-reviewer` dispatched but review output is empty or confirms plan without specific observations.

**Zero (0):** `plan-reviewer` not dispatched.

---

## 6. TDD Compliance

**Full credit (2):** Tests written before implementation for:
- Game logic (collision detection, wall collision, self-collision, food consumption, score increment)
- Leaderboard API (POST score, GET top-N, score persists across restart)
- Each test was run and failed before the implementation it covers was written

**Partial (1):** Tests exist and cover the above cases, but there is no evidence they were written first (tests added after implementation, or test file committed after source file in the same batch).

**Zero (0):** Tests are missing for core game logic or leaderboard API, or only smoke tests exist.

---

## 7. Output Quality

**Full credit (2):** All three of the following are true:
- Game server starts, accepts WebSocket connections, and runs a game loop
- Browser client connects, renders the game board, and accepts keyboard input
- Leaderboard API accepts a score POST and returns top scores via GET, and data survives a server restart

**Partial (1):** Two of the three components work end-to-end.

**Zero (0):** Fewer than two components work, or the components exist but cannot be connected.

---

## 8. Review Quality

**Full credit (2):** At least two reviewer agents (`architecture-reviewer`, `plan-reviewer`, or `product-reviewer`) produce substantive output. Combined, their reviews surface at least two distinct, non-trivial issues that are either fixed before shipping or explicitly accepted with documented rationale.

**Partial (1):** Reviewers dispatched and produce output, but issues identified are trivial (naming, formatting) with no architectural or behavioral concerns raised.

**Zero (0):** Reviewers dispatched but produce no issues, or are not dispatched.

---

## Passing Bar

**Pass:** Score ≥ 12 / 16 with no zero on criteria 2 (Architecture Produced) or 4 (Threat Model Produced).

**Fail:** Score < 12, or a zero on criterion 2 or 4 — implementation without an architecture is a hard failure for Tier 3.
