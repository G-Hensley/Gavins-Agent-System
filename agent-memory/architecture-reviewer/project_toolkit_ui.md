---
name: APIsec Toolkit UI — Project Context
description: Web UI for the apisec-toolkit-v2 Python CLI tools; Phase 1 design reviewed 2026-04-02
type: project
---

Web UI wrapping 22 Python CLI tools (Phase 1: 6 tools). Frontend on Vercel (Next.js App Router), backend on Railway (FastAPI). 3 internal users only, email allowlist access control. Tools spawned as subprocesses, stdout streamed via SSE. No database — ephemeral state.

Design doc: /Users/gavinhensley/Desktop/Projects/APIsec/docs/architecture/2026-04-02-toolkit-ui-design.md
PRD: /Users/gavinhensley/Desktop/Projects/APIsec/docs/prd/2026-04-02-apisec-toolkit-ui-prd.md
Toolkit: /Users/gavinhensley/Desktop/Projects/APIsec/apisec-toolkit-v2/

**Why:** Jesse and Dave can't run tools today — requires terminal + Python + YAML knowledge. UI removes the bottleneck.

**Key open issues at design review (2026-04-02):**
- Output file routing to run_id temp dir is unspecified in subprocess spawn args
- File upload API contract is missing from the contracts section
- No concurrency guard for duplicate submissions
- configure-auth lacks --yes flag (design incorrectly implies all mutating tools do)
- scan-profile-export missing output_format field in registry
- YAML preview has two independent serializers (client and server)

**How to apply:** When implementing or reviewing runner.py, validator.py, or registry.py, verify these gaps were addressed before proceeding.
