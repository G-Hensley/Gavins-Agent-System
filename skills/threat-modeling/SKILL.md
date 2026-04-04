---
name: threat-modeling
description: Build threat models using the VAST (Visual, Agile, Simple Threat) methodology. Use when designing new systems, reviewing architecture for security, assessing attack surfaces, or when the user says "threat model", "attack surface", "security assessment", "VAST", "threat analysis", or "what could go wrong". Also use before major releases or after significant architecture changes.
---

# Threat Modeling (VAST)

Build actionable threat models using VAST — Visual, Agile, and Simple Threat modeling. Designed for DevOps environments, continuous integration, and real-world development velocity.

## Process

### 1. Define the System
Map what you're protecting:
- System boundaries — what's in scope, what's external
- Data flows — where data enters, moves, transforms, exits
- Trust boundaries — where privilege levels change (user → API → database → external service)
- Assets — what's valuable (user data, credentials, financial info, business logic)

### 2. Identify Threats
For each data flow crossing a trust boundary, ask:
- **Spoofing**: can an attacker pretend to be someone else?
- **Tampering**: can data be modified in transit or at rest?
- **Repudiation**: can actions be denied without audit trail?
- **Information Disclosure**: can sensitive data leak?
- **Denial of Service**: can the system be overwhelmed?
- **Elevation of Privilege**: can a user gain unauthorized access?

Use `references/vast-methodology.md` for the full VAST process and threat categorization.

### 3. Devise Mitigations
For each identified threat:
- Assign severity (Critical / High / Medium / Low)
- Propose specific mitigation (not generic advice)
- Map mitigation to implementation (which component, what change)
- Assign to a sprint or backlog

### 4. Validate Outcomes
- Verify mitigations are implemented (code review, security tests)
- Dispatch specialist security reviewers for each domain:
  - Frontend threats → `frontend-security-reviewer` agent
  - Backend/API threats → `backend-security-reviewer` agent
  - Cloud/infra threats → `cloud-security-reviewer` agent
  - Auth/session/supply chain → `appsec-reviewer` agent
- Update the threat model when architecture changes

## What NOT to Do

- Do not create a threat model once and forget it — update continuously
- Do not list threats without mitigations — every threat needs a response
- Do not use generic mitigations ("add security") — be specific (what, where, how)
- Do not skip trust boundaries — they're where most vulnerabilities occur
- Do not model in isolation — include developers, architects, and security team

## Reference Files

- `references/vast-methodology.md` — Full VAST process, threat categories, severity scoring, mitigation patterns, and template for threat model documents.

**Subagents:** Dispatch domain-specific security reviewers to validate mitigations:
- `frontend-security-reviewer` — validates frontend mitigations
- `backend-security-reviewer` — validates backend/API mitigations
- `cloud-security-reviewer` — validates infrastructure mitigations
- `appsec-reviewer` — validates auth, session, and supply chain mitigations
