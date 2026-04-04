# VAST Methodology

VAST (Visual, Agile, and Simple Threat) modeling is designed for modern DevOps — automated, integrated, and scalable.

## Core Principles

- **Visual**: Map threats using diagrams so teams can see attack vectors clearly
- **Agile**: Integrates into sprints and CI/CD — a continuous practice, not a one-time event
- **Simple**: Reduces complexity so developers (not just security teams) can participate

## The VAST Process

### Step 1: System Mapping

Create a visual representation of the system:

```
[User Browser] → [CDN/WAF] → [API Gateway] → [Application Server] → [Database]
                                    ↓                    ↓
                              [Auth Service]     [External APIs]
                                    ↓
                              [Token Store]
```

Mark trust boundaries with `||`:

```
[User] || [API Gateway] || [App Server] || [Database]
 Public     DMZ            Internal        Data Layer
```

Every boundary crossing is a potential attack point.

### Step 2: Threat Identification (STRIDE per Element)

For each component and data flow, apply STRIDE:

| Threat | Question | Example |
|---|---|---|
| **S**poofing | Can someone impersonate a legitimate user/service? | Stolen JWT, forged API key |
| **T**ampering | Can data be modified without detection? | Man-in-the-middle, parameter manipulation |
| **R**epudiation | Can actions be performed without audit trail? | Missing logging on admin actions |
| **I**nformation Disclosure | Can sensitive data leak? | Error messages with stack traces, unencrypted PII |
| **D**enial of Service | Can the system be overwhelmed? | Missing rate limiting, unbounded queries |
| **E**levation of Privilege | Can users gain unauthorized access? | IDOR, broken function-level auth |

### Step 3: Severity Scoring

| Severity | Criteria | Response |
|---|---|---|
| **Critical** | Exploitable remotely, leads to data breach or full system compromise | Fix immediately, block release |
| **High** | Exploitable with some conditions, significant data exposure | Fix before next release |
| **Medium** | Requires internal access or specific conditions | Schedule for upcoming sprint |
| **Low** | Theoretical risk, minimal impact | Add to backlog |

### Step 4: Mitigation Mapping

For each threat, document:
```
Threat: [description]
Severity: [Critical/High/Medium/Low]
Component: [which component is affected]
Mitigation: [specific technical fix]
Validation: [how to verify the fix works]
Owner: [who implements it]
Status: [Open/In Progress/Mitigated/Accepted]
```

## Threat Model Document Template

```markdown
# Threat Model: [System Name]
**Date:** YYYY-MM-DD
**Version:** 1.0
**Author:** [name]
**Status:** Draft | In Review | Approved

## System Overview
[1-2 paragraphs: what the system does, who uses it]

## System Diagram
[Visual diagram with trust boundaries marked]

## Assets
| Asset | Sensitivity | Location |
|---|---|---|
| User credentials | Critical | Auth service + token store |
| Customer PII | High | Database |
| API keys | Critical | Secrets Manager |

## Trust Boundaries
| Boundary | From | To | Controls |
|---|---|---|---|
| Public → DMZ | User browser | API Gateway | WAF, rate limiting |
| DMZ → Internal | API Gateway | App Server | Auth, input validation |
| Internal → Data | App Server | Database | Parameterized queries, least privilege |

## Threats and Mitigations
| ID | Threat | STRIDE | Severity | Component | Mitigation | Status |
|---|---|---|---|---|---|---|
| T-001 | [description] | [S/T/R/I/D/E] | [severity] | [component] | [fix] | [status] |

## Accepted Risks
[Threats acknowledged but not mitigated, with justification]

## Review Schedule
- Next review: [date]
- Trigger events: major architecture changes, new external integrations, security incidents
```

## Continuous Integration

VAST is not a one-time exercise:
- **New feature**: update threat model during architecture review
- **New integration**: assess trust boundaries with external system
- **Security incident**: review if existing threats were underrated
- **Quarterly**: review full threat model for staleness
- **Pre-release**: validate all Critical/High mitigations are implemented
