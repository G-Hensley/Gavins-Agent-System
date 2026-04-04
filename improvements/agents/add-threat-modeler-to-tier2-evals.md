# Add Threat Modeler to Tier 2 Evals

## What I Observed

The `threat-modeler` agent (proposed in `docs/IMPROVEMENTS.md` #14) is scoped for Tier 3+ in the current eval coverage matrix (`evals/agent-coverage.md`). However, the Tier 2 Secrets Scanning Pipeline eval (`tier-2-multi-agent/secrets-scanning`) already involves sensitive data flows — credentials, environment variables, CI secrets — that have obvious threat surface.

At Tier 2, a lightweight threat assessment after `devsecops-engineer` designs the pipeline would catch issues before the `devops-engineer` wires it into CI. Currently there's no step that does this.

## Why It Would Help

Tier 3 evals won't exist in volume for a while. If the `threat-modeler` agent only appears in Tier 3+, it won't be exercised during early system development, and its dispatch conditions in CLAUDE.md will be untested.

A Tier 2 exercise that invokes a scoped threat assessment would:
- Give the agent a real eval before Tier 3 is built
- Validate the handoff contract between `devsecops-engineer` and `threat-modeler`
- Catch design-time security gaps in the secrets scanning pipeline specifically (a pipeline that handles secrets is exactly the wrong place to skip threat modeling)

## Proposal

Add a lightweight threat assessment step to the Tier 2 secrets scanning eval:

1. After `devsecops-engineer` produces the pipeline design, dispatch `threat-modeler` with the design doc
2. Scope: data flows only — where do secrets travel, what processes touch them, what are the trust boundaries?
3. Expected output: a short threat summary (not a full VAST model) identifying at least two risks and their mitigations
4. Eval rubric: threat-modeler identifies secret-in-plaintext-log risk and least-privilege-on-secret-store risk

This is lighter than a full Tier 3 VAST run. Document the distinction as "lightweight threat assessment" vs. "full threat model" in the agent's instructions once the agent is built.

Also update `evals/agent-coverage.md` to mark `threat-modeler` as covered at Tier 2 once implemented.
