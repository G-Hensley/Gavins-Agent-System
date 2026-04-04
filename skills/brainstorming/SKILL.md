---
name: brainstorming
description: Collaborative ideation for features, components, or entire projects. Use before any creative work — new features, new projects, new components, major changes, or when the user says "let's think about", "I want to build", "how should we approach", or describes a new idea. Do NOT use for implementation — hand off to product-management or architecture skills after.
---

# Brainstorming

Turn rough ideas into clear decisions through collaborative dialogue. This skill is about exploring possibilities and converging on a direction — not writing specs or code.

## Scope

Brainstorming works at any level:
- **Feature/component**: "We need a better auth flow" → explore approaches → hand off to architecture
- **Whole project/application**: "I want to build X" → explore what it is, who it's for, what it does → hand off to product-management

## Process

### 1. Understand Context
- Check project files, docs, recent commits if working in an existing codebase
- Assess scope: is this a feature within a project, or a new project entirely?

### 2. Explore the Idea
- Ask questions one at a time — do not overwhelm
- Prefer multiple choice when possible
- Focus on: what problem does this solve, who is it for, what does success look like
- If the idea spans multiple independent systems, flag it and help decompose before going deeper

### 3. Diverge — Generate Options
- Propose 2-3 different approaches with trade-offs
- Include unconventional options, not just the obvious path
- For each option: what's the upside, what's the risk, what's the effort

### 4. Converge — Pick a Direction
- Lead with your recommendation and explain why
- Apply YAGNI — cut anything that isn't essential to the core idea
- Get explicit user agreement on the direction before moving on

### 5. Hand Off
Based on what was brainstormed:
- **New project or product-level scope** → invoke `product-management` skill to create PRD, user stories, and requirements
- **Feature or technical component** → invoke `architecture` skill to create technical design
- **Small/contained change** → invoke `writing-plans` skill directly if no design is needed

## What NOT to Do

- Do not write specs, PRDs, or design docs — that's the job of downstream skills
- Do not start implementing or writing code
- Do not ask multiple questions in one message
- Do not skip exploring alternatives — always propose 2-3 options
- Do not let scope creep — if new ideas emerge, note them for later and stay focused

## Key Principles

- One question at a time
- YAGNI ruthlessly
- Always propose alternatives before settling
- The output of brainstorming is a **decision**, not a document
- Large projects decompose into sub-projects, each getting its own brainstorm → PM → architecture → plan cycle
