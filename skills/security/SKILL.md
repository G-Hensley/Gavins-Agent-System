---
name: security
description: Security review, hardening, and best practices across all layers — frontend, API, database, AWS, supply chain, and application security. Use when writing code that handles user input, authentication, authorization, data storage, API endpoints, infrastructure, or dependencies. Also use when the user says "security review", "harden this", "is this secure", "OWASP", or when reviewing code for vulnerabilities.
---

# Security

Comprehensive security guidance across all application layers. Apply the relevant domain based on what's being built or reviewed.

## Process

### 1. Identify the Attack Surface
Determine which security domains apply to the current work:
- User-facing code → frontend security
- API endpoints → API security
- Database operations → database security
- AWS infrastructure → cloud security
- Dependencies → supply chain security
- Application logic → application security

### 2. Apply Domain-Specific Guidance
Read the relevant reference file for the domain. Apply checks and patterns from that reference to the current code.

### 3. Dispatch Specialist Reviewers
Dispatch the right specialist based on what's being reviewed:
- Frontend code (React, DOM, cookies, client storage) → `frontend-security-reviewer`
- Backend code (APIs, auth, input handling, queries) → `backend-security-reviewer`
- Cloud/infrastructure (AWS, IAM, S3, Lambda, VPC) → `cloud-security-reviewer`
- Application-wide (auth flows, sessions, dependencies, CI/CD) → `appsec-reviewer`

Each loads this skill + their domain skill, uses confidence scoring (80+), and maintains persistent memory.

### 4. Threat Modeling
For new systems or major changes, use the `threat-modeling` skill to build a VAST threat model before implementation. The threat model identifies threats, and the specialist reviewers validate mitigations.

## What NOT to Do

- Do not assume code is secure because it "looks fine" — check against the domain reference
- Do not skip input validation at system boundaries (user input, API requests, file uploads)
- Do not store secrets in code, config files, or version control
- Do not trust client-side validation as the only defense — always validate server-side
- Do not ignore dependency vulnerabilities — check supply chain security
- Do not use overly broad IAM permissions — follow least privilege

## Reference Files

- `references/frontend-security.md` — XSS, CSRF, CSP, input sanitization, secure cookies, DOM manipulation. Read when writing or reviewing user-facing code.
- `references/api-security.md` — Authentication, authorization, rate limiting, input validation, OWASP API Top 10. Read when building or reviewing API endpoints.
- `references/database-security.md` — SQL injection, parameterized queries, access control, encryption at rest, backup security. Read when writing database operations.
- `references/cloud-security.md` — AWS IAM, least privilege, secrets management, VPC, S3 bucket policies, Lambda security. Read when working with AWS infrastructure.
- `references/supply-chain-security.md` — Dependency auditing, lock files, version pinning, known vulnerability scanning. Read when adding or updating dependencies.
- `references/appsec.md` — Authentication flows, session management, secrets handling, error disclosure, logging sensitive data. Read when implementing auth, sessions, or handling sensitive data.

**Subagents** (in `~/.claude/agents/`):
- `frontend-security-reviewer` — XSS, CSRF, CSP, DOM, cookies. Loads: security + frontend-engineering.
- `backend-security-reviewer` — injection, auth, input validation, error disclosure. Loads: security + backend-engineering.
- `cloud-security-reviewer` — IAM, secrets, S3, Lambda, VPC. Loads: security + devops.
- `appsec-reviewer` — auth flows, sessions, supply chain, CI/CD. Loads: security.

**Related skill:** `threat-modeling` — VAST methodology for proactive threat identification before implementation.
