Set up Claude Code for a new or existing project. This is a full onboarding workflow.

## For Existing Projects

1. **Explore the codebase** — Dispatch 2-3 `code-explorer` agents in parallel targeting:
   - High-level architecture and directory structure
   - Key patterns, conventions, and frameworks used
   - Testing setup, CI/CD, and deployment patterns

2. **Create project CLAUDE.md** — Based on exploration findings, create a `.claude/CLAUDE.md` in the project root with:
   - Quick start commands (install, build, test, run)
   - Architecture overview (key directories, entry points, how things connect)
   - Conventions (naming, patterns, imports, error handling)
   - Common tasks (how to add a feature, run tests, deploy)
   - What NOT to do (anti-patterns, files to avoid, known gotchas)

3. **Recommend agents and skills** — Based on the tech stack found, suggest which agents and skills are most relevant for this project.

4. **Kickoff brainstorm** — Ask: "The project is set up. What are we working on?" Then start the `brainstorming` skill to begin the first task.

## For New Projects

1. **Brainstorm** — Use the `brainstorming` skill. Explore what we're building, who it's for, what the constraints are.

2. **Product requirements** — Dispatch `product-manager` agent to create a PRD from the brainstorm.

3. **Architecture** — Dispatch `architect` agent to create the technical design.

4. **Scaffold** — Based on the architecture, create the project structure, install dependencies, set up testing, and create the initial CLAUDE.md.

5. **Plan** — Use `writing-plans` skill to create the implementation plan from the architecture.

6. **Build** — Offer subagent-driven or inline execution.

Start by asking: "Is this an existing project or are we starting fresh?"
