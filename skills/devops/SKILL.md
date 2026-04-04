---
name: devops
description: DevOps and DevSecOps — CI/CD pipelines, Docker, AWS infrastructure, monitoring, deployment strategies, and infrastructure as code. Use when setting up pipelines, containerizing applications, managing AWS infrastructure, configuring monitoring, or automating deployments. Also use when the user says "CI/CD", "Docker", "deploy", "infrastructure", "monitoring", "pipeline", "CloudFormation", "CDK", or "Terraform".
---

# DevOps

Build reliable infrastructure and deployment pipelines. Shift security left (DevSecOps) — security checks in every pipeline stage.

## Process

### 1. Identify the Concern
- **CI/CD** — build, test, deploy pipelines → `references/cicd-patterns.md`
- **Containers** — Docker images, compose, orchestration → `references/docker.md`
- **Infrastructure** — AWS resources, IaC, networking → `references/aws-infrastructure.md`
- **Observability** — monitoring, logging, alerting → `references/monitoring.md`

### 2. Design for Reliability
- Automate everything repeatable
- Make deployments reversible (rollback strategy for every deploy)
- Monitor what matters (not everything — focus on SLIs/SLOs)
- Fail fast in CI — run cheapest checks first (lint → unit → integration → E2E)

### 3. Review
Dispatch the devops-reviewer agent (`devops-engineer` subagent) for infrastructure and pipeline reviews.

## What NOT to Do

- Do not deploy without a rollback plan
- Do not store secrets in code, Dockerfiles, or CI config — use secret managers
- Do not skip CI — every change goes through the pipeline
- Do not use `latest` tags in production — pin versions
- Do not give overly broad IAM permissions — least privilege always
- Do not monitor everything — focus on user-facing SLIs

## Reference Files

- `references/cicd-patterns.md` — Pipeline design, stage ordering, caching, artifact management, GitHub Actions patterns.
- `references/docker.md` — Dockerfile best practices, multi-stage builds, security, compose patterns.
- `references/aws-infrastructure.md` — CDK/CloudFormation patterns, Lambda, S3, DynamoDB, VPC, IAM.
- `references/monitoring.md` — Observability strategy, logging, metrics, alerting, SLIs/SLOs.
- `devops-engineer` subagent (in `~/.claude/agents/`) — Subagent for reviewing infrastructure and pipeline configurations.
