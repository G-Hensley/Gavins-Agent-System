# Eval Criteria — Three.js Interactive Scene

Scoring: 0 = missed, 1 = partial, 2 = full credit. Maximum score: 16 points (8 criteria × 2).

---

## 1. Dispatch Correctness

**Full credit (2):** Agents dispatched in the correct order:
- `uiux-designer` → produces a design spec (layout, color palette, UI controls, interaction model) before any code is written
- `architect` → produces a technical design doc covering scene graph structure, module breakdown, and animation loop design
- `architecture-reviewer` → reviews the design doc before implementation
- `frontend-engineer` → implements the Three.js scene, dispatched only after design and architecture docs exist

**Partial (1):** At least 3 of the 4 agents dispatched, with `uiux-designer` and `architect` appearing before `frontend-engineer`.

**Zero (0):** `frontend-engineer` dispatched without a prior design spec or architecture doc, or `uiux-designer` skipped entirely.

---

## 2. Architecture Produced Before Implementation

**Full credit (2):** A design document exists and was produced before implementation code. It must include:
- Scene graph structure (how Sun, planets, orbits, and labels are organized as Three.js objects)
- Module breakdown (scene setup, planet config, animation loop, UI controls — separate concerns)
- Camera and controls strategy (OrbitControls, initial camera position)
- Lighting strategy (AmbientLight + PointLight at Sun position, or equivalent)
- Raycasting plan for click-to-select interaction
- Performance consideration (geometry reuse, disposal on teardown)

**Partial (1):** Design doc exists but is missing 2 or more of the above elements, or produced after implementation started.

**Zero (0):** No design doc, or a stub without architectural decisions.

---

## 3. Architecture Reviewed

**Full credit (2):** `architecture-reviewer` dispatched after the design doc exists and before implementation begins. Review output identifies at least one real concern (e.g., no strategy for label cleanup causing memory leaks, raycasting on every frame without throttle, camera controls conflicting with click detection, missing disposal on scene teardown).

**Partial (1):** Reviewer dispatched but output is superficial — no specific Three.js or performance concerns identified.

**Zero (0):** `architecture-reviewer` not dispatched.

---

## 4. Threat Model Produced

**Full credit (2):** Because this is a purely client-side visualization with no backend, a full `threat-modeler` dispatch is not required. Instead, the `architect` or `uiux-designer` should document client-side considerations such as: no external data loaded (no XSS vector), WebGL context loss handling, and no sensitive user data collected.

Award full credit if these considerations appear in the design doc or architecture review.

**Partial (1):** Only one of the above considerations is noted, or the point is acknowledged but not addressed.

**Zero (0):** No security or resilience considerations documented at all.

Note: `threat-modeler` dispatch is optional for this eval. If dispatched, it must produce at least one relevant finding (e.g., third-party CDN dependency risk for Three.js, WebGL fingerprinting) to count toward full credit here.

---

## 5. Plan Reviewed

**Full credit (2):** `plan-reviewer` (or equivalent review step in the architecture doc) evaluates the implementation plan and surfaces at least one concern (e.g., no plan for disposing Three.js objects when the demo reloads, speed slider not throttled causing jitter, click handler attached globally instead of to the canvas).

**Partial (1):** Plan review exists but raises no specific issues.

**Zero (0):** No plan review step.

---

## 6. TDD Compliance

**Full credit (2):** Tests exist for pure logic functions before they are implemented:
- Planet orbit position calculation (given elapsed time and orbital period, returns correct x/z coordinates)
- Speed multiplier application (slider value correctly scales delta time)
- Planet selection logic (raycasting returns correct planet object or null)

Note: Three.js scene setup and rendering are not testable via unit tests — only pure JS functions need TDD coverage.

**Partial (1):** Tests exist for at least one of the above functions, written before implementation.

**Zero (0):** No tests, or tests are only smoke tests that instantiate the scene without asserting behavior.

---

## 7. Output Quality

**Full credit (2):** All of the following are true when opened in a browser:
- Scene renders with the Sun, at least 6 planets, and a starfield background
- Planets orbit and rotate visibly
- Click-drag orbits the camera; scroll zooms
- Clicking a planet shows its name
- Speed slider changes orbit speed in real time
- Animation runs without visible frame drops on a modern laptop

**Partial (1):** Scene renders and planets move, but 1-2 interactive features are missing or broken.

**Zero (0):** Scene does not render, or fewer than 4 planets appear, or no interactivity works.

---

## 8. Review Quality

**Full credit (2):** `architecture-reviewer` (and optionally `plan-reviewer`) produce output that surfaces at least two distinct concerns relevant to a Three.js project — not generic feedback. Examples of qualifying findings: animation loop not paused when tab is hidden (`visibilitychange`), no call to `renderer.dispose()`, label sprites not removed from scene on deselect, OrbitControls not enabled after click detection check.

**Partial (1):** One relevant Three.js-specific concern identified.

**Zero (0):** Reviewer dispatched but output contains only generic observations, or not dispatched.

---

## Passing Bar

**Pass:** Score ≥ 12 / 16 with no zero on criterion 2 (Architecture Produced).

**Fail:** Score < 12, or a zero on criterion 2 — implementation without an architecture is a hard failure for Tier 3.
