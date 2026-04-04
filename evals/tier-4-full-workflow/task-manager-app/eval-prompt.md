# Eval Prompt: Full-Stack Task Manager App

## Objective

Build a production-ready, full-stack Task Manager application using the complete agent pipeline. This task is designed to exercise the full breadth of the agent system — from ideation through implementation, review, and documentation.

Do not skip or shortcut any stage of the pipeline. Each stage feeds the next.

---

## What to Build

A multi-user Task Manager application with the following capabilities:

### Features

**Authentication & Authorization**
- User sign-up and sign-in via AWS Cognito (hosted UI or custom form)
- Two roles: `admin` and `member`
- Admins can create/edit/delete any task and manage users
- Members can only create and manage their own tasks

**Task Management**
- Create, read, update, and delete tasks
- Each task has: title, description, status (`todo` / `in-progress` / `done`), due date, priority (`low` / `medium` / `high`), and assignee
- Admins can assign tasks to any user; members can only self-assign
- Filter tasks by status, priority, assignee, and due date range
- Overdue tasks should be visually flagged

**Storage**
- DynamoDB single-table design
- Access patterns must be defined before implementation begins

**Frontend**
- Next.js App Router with TypeScript
- Server components for data fetching; client components pushed to leaves
- Tailwind CSS with a design system established before coding starts
- Responsive layout, accessible markup

**Backend / API**
- REST API (Next.js API routes or a separate Lambda-backed API)
- Input validation on every endpoint
- Proper HTTP status codes and error shapes
- Cognito JWT verification on all protected routes

---

## Pipeline Instructions

Work through the following stages in order. Do not begin a stage until the prior stage's output exists.

### Stage 1 — Brainstorm
Use the `brainstorming` skill to explore scope, edge cases, and open questions before any planning begins.

### Stage 2 — Product Requirements
Dispatch the `product-manager` agent to produce a Product Requirements Document (PRD) from the brainstorm output. The PRD must include user stories, acceptance criteria, and a prioritized feature list (MVP vs. future).

### Stage 3 — Architecture
Dispatch the `architect` agent to produce an Architecture Decision Record (ADR) and system diagram. The ADR must cover: data model (DynamoDB access patterns), API surface, auth flow, deployment topology, and component boundaries.

### Stage 4 — Threat Model
Dispatch the `threat-modeler` agent to review the architecture and produce a threat model. Cover at minimum: auth bypass, privilege escalation, data exposure, injection, and rate limiting gaps.

### Stage 5 — Implementation Plan
Using the PRD and ADR, produce a detailed implementation plan (tasks broken into implementable units). Each unit should be independently testable.

### Stage 6 — Spec Review
Dispatch the `spec-reviewer` agent to review the implementation plan against the PRD. Flag any gaps or deviations before a single line of code is written.

### Stage 7 — Implementation
Dispatch one `implementer` agent per implementation unit. Each implementer must follow TDD: write the test first, watch it fail, implement, verify. No exceptions.

### Stage 8 — Code Quality Review
Dispatch the `code-quality-reviewer` agent across all implemented code. Issues must be resolved before security review begins.

### Stage 9 — Security Review
Dispatch all four security reviewers in parallel:
- `frontend-security-reviewer` — XSS, CSP, client-side data exposure
- `backend-security-reviewer` — injection, auth, input validation, error leakage
- `cloud-security-reviewer` — IAM policies, DynamoDB permissions, Cognito config, S3 if used
- `appsec-reviewer` — end-to-end security posture, threat model coverage

All findings must be addressed and re-reviewed before marking the eval complete.

### Stage 10 — Documentation
Dispatch the `doc-writer` agent to produce:
- README with setup, environment variables, and run instructions
- API reference (endpoints, request/response shapes, auth requirements)
- Architecture overview (prose summary of the ADR)

---

## Constraints

- No hardcoded credentials, regions, table names, or API URLs — all via environment variables
- IAM policies must be least-privilege — no wildcard actions or resources
- All inputs validated at API boundaries using Zod (TypeScript) or Pydantic (Python)
- Test coverage must be verifiable — each implementer runs their tests and reports pass/fail
- No dead code, no commented-out blocks
