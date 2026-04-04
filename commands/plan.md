Start the full planning pipeline for a new feature or project.

Run these phases in order, getting user approval between each:

1. **Brainstorm** — Use the `brainstorming` skill. Explore the idea, ask clarifying questions one at a time, propose 2-3 approaches, converge on a direction.

2. **Decide scope** — Based on the brainstorm:
   - If this is a whole project/product → dispatch `product-manager` agent to create a PRD
   - If this is a feature/component → skip to architecture

3. **Architecture** — Dispatch the `architect` agent. For existing codebases, dispatch `code-explorer` agents first to understand current patterns. Create the technical design doc.

4. **Implementation plan** — Use the `writing-plans` skill to break the architecture into bite-sized tasks with TDD steps.

5. **Offer execution** — Ask the user: subagent-driven (recommended) or inline execution?

Each phase produces a document. Each document gets reviewed by its specialist reviewer (product-reviewer, architecture-reviewer, plan-reviewer) before proceeding.

Start with: "What are we building?"
