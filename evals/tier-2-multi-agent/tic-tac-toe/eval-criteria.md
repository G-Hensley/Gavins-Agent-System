# Eval Criteria: Tic-Tac-Toe (Tier 2 — Multi-Agent Handoff)

Target agents: `uiux-designer` → `frontend-engineer`, `code-explorer`
Max score: 12 (6 dimensions × 0–2)

---

## 1. Dispatch Correctness (0–2)

**What to check:**
- `uiux-designer` is dispatched before any frontend code is written
- `frontend-engineer` is dispatched to implement the React web UI
- `code-explorer` is dispatched to audit shared game logic or cross-cutting structure before implementation begins
- No frontend code is written by the orchestrator directly

**Scoring:**
- 2 — All three agents dispatched in correct order; no implementation before design
- 1 — At least two of the three agents dispatched, or order is slightly off but design precedes implementation
- 0 — `frontend-engineer` dispatched first (skipping design), or agents not used at all

---

## 2. Handoff Quality (0–2)

**What to check:**
- `uiux-designer` produces a design system artifact (component names, color tokens, layout description, or Figma-equivalent spec) before `frontend-engineer` begins
- `frontend-engineer` references the design system in its implementation — components, tokens, or layout match what was designed
- If `code-explorer` audits the shared logic, its findings (module structure, interface, exports) are passed to the implementing agents

**Scoring:**
- 2 — Design artifact is explicit and referenced by the implementing agent; handoff context is visible in the conversation
- 1 — Design is done first but the implementing agent does not clearly reference it, or the artifact is incomplete
- 0 — No design artifact produced; `frontend-engineer` invents the UI from scratch without design input

---

## 3. Design-First Compliance (0–2)

**What to check:**
- A design system or UI spec is produced before any React component code is written
- The design includes at minimum: board layout, component hierarchy, winning state visualization, turn indicator, and color/type decisions
- No "let me just scaffold the components" shortcuts taken before design is complete

**Scoring:**
- 2 — Full design spec precedes all implementation; includes layout, states, and visual tokens
- 1 — Some design done first but it is incomplete (e.g., missing states like win/draw)
- 0 — Implementation starts with no design phase

---

## 4. TDD Compliance (0–2)

**What to check:**
- Tests for the game logic module (`game.py` or equivalent) are written before the logic is implemented
- Test file exists and covers: win detection (rows, columns, diagonals), draw detection, turn alternation, invalid move rejection
- Tests are run and confirmed passing before UI work begins
- Terminal and web UIs are not tested at this stage (unit scope is the logic module only)

**Scoring:**
- 2 — Tests written first, cover all four logic behaviors, confirmed passing before implementation
- 1 — Tests exist but were written after implementation, or coverage is partial (missing 1–2 behaviors)
- 0 — No tests, or tests written only for the UI layer

---

## 5. Output Quality (0–2)

**What to check:**
- `tictactoe.py` runs, renders a labeled ASCII board, accepts player input, and detects win/draw
- React web UI renders the board, indicates current player, highlights the winning line, and includes a "Play Again" button
- Game logic is in a shared module — not duplicated between the two interfaces
- Both interfaces import/use the shared logic module

**Scoring:**
- 2 — Both interfaces functional, logic is shared, winning line highlighted, "Play Again" works
- 1 — One interface is complete but the other is missing or broken; or logic is duplicated instead of shared
- 0 — Neither interface is functional, or game logic is hardcoded into both interfaces separately

---

## 6. Agent-Specific Rules (0–2)

**What to check:**
- `uiux-designer`: produces a design system before any component code; does not write React code itself
- `frontend-engineer`: implements from the design system, uses function components with typed props interfaces, no `any` in TypeScript
- `code-explorer`: stays in a read/audit role; does not implement features
- All agent files stay under 200 lines

**Scoring:**
- 2 — Each agent stays in its lane; no crossover; agent-specific rules followed
- 1 — Minor crossover (e.g., designer sketches a component, engineer invents a color token); no egregious violations
- 0 — Designer writes React code, or engineer makes design decisions without input from the designer
