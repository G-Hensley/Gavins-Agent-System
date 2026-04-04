---
name: frontend-engineering
description: Frontend development with React, Next.js, TypeScript — component architecture, state management, performance, and implementation. Use when building React components, pages, or applications. Also use when the user says "React", "Next.js", "component", "state management", "frontend performance", "SSR", "client-side", or when implementing designs from the UI/UX design system. Works FROM architecture decisions and frontend-design's design system docs.
---

# Frontend Engineering

Implement frontend features using React/Next.js with TypeScript. This skill handles the *engineering* — component architecture, state, performance, data fetching. For visual design decisions (colors, typography, spacing, hierarchy), refer to the `frontend-design` skill which creates the design system this skill implements from.

## Process

### 1. Check Design System
Before implementing, check if `frontend-design` has created design docs for this project:
- Color palette, typography scale, spacing system
- Component patterns (cards, forms, buttons, nav)
- Layout decisions

Implement FROM those decisions. Do not override the design system.

### 2. Plan Component Architecture
Read `references/react-patterns.md` for component design:
- Break the UI into components with clear boundaries
- Identify shared vs. page-specific components
- Plan prop interfaces and data flow
- Determine server vs. client components (Next.js)

### 3. Implement
Read the relevant reference for the framework and concern. Follow TDD — write component tests alongside implementation.

### 4. Review
Dispatch the `frontend-engineer` subagent for implementation.

## What NOT to Do

- Do not override design system decisions (colors, spacing, typography) — those come from `frontend-design`
- Do not put business logic in components — extract to hooks or service modules
- Do not use `useEffect` for data that can be fetched server-side (Next.js)
- Do not skip TypeScript types — define Props interfaces for every component
- Do not create god components — split when a component exceeds ~150 lines
- Do not fetch data in deeply nested components — lift data fetching up

## Reference Files

- `references/react-patterns.md` — Component patterns, hooks, state management, TypeScript with React. Read when building React components.
- `references/nextjs-patterns.md` — App Router, server/client components, data fetching, routing, middleware. Read when building Next.js apps.
- `references/performance.md` — Code splitting, lazy loading, memoization, bundle optimization, Core Web Vitals. Read when optimizing frontend performance.
**Subagent:** `frontend-engineer` — implements React/Next.js from architecture + design system. Located at `~/.claude/agents/frontend-engineer.md`.
