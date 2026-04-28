# New skill reference: LLM security (prompt injection + OWASP LLM Top 10)

## What I Observed

LLM-specific security is missing from both the security skill and the AI engineering skill. The general security work covers traditional appsec (SQL injection, XSS, etc.) but not the attack surface that's specific to LLM applications. Prompt injection is the #1 vulnerability in OWASP's Top 10 for LLM Applications (2025); none of the operator's agents currently know what to look for.

Missing topics:

**Prompt injection types**

- Direct injection (user input contains override instructions)
- Indirect injection (malicious instructions embedded in content the LLM processes — web pages, documents, tool outputs). The dangerous one — the user is not the attacker.

**Defense layers** (no single defense suffices)

- Input filtering (regex + classifier-based: PromptGuard, LlamaGuard) with false-positive caveat
- System prompt hardening (critical instructions at start AND end, explicit anti-injection clause, delimiter tags around user content)
- Output filtering (scan for system-prompt leakage, PII, policy violations)
- Privilege separation (LLM proposes, deterministic code disposes — never let an LLM directly execute irreversible actions)
- Tool permission boundaries (least privilege on tool definitions, not just user permissions)

**OWASP Top 10 for LLM (2025)** — entire list

1. Prompt Injection
2. Sensitive Information Disclosure
3. Supply Chain Vulnerabilities
4. Data and Model Poisoning
5. Improper Output Handling
6. Excessive Agency
7. System Prompt Leakage
8. Vector and Embedding Weaknesses (RAG-specific attacks)
9. Misinformation
10. Unbounded Consumption (token DoS, cost explosion)

## Why It Would Help

- LLM apps are now the dominant new attack surface in many products; reviewers without explicit guidance default to "the LLM will probably handle it" which is the wrong default
- Indirect prompt injection via tool outputs is genuinely subtle — even experienced engineers miss it because the malicious instruction never appears in the user's input
- "Excessive Agency" is the operator's own concern given multi-agent work — the reference should make the principle of "LLM proposes, deterministic code disposes" a default
- Unbounded Consumption maps directly to the iteration-cap and cost-ceiling rules in the agentic-design-patterns ref — they reinforce each other

## Proposal

Create `skills/ai-engineering/references/llm-security.md` with sections:

- Direct vs. indirect prompt injection — examples and why indirect is the dangerous one
- Defense layers (5 layers, none sufficient alone) with concrete examples per layer
- System prompt hardening template (instructions at start + end, delimiter tags, explicit anti-injection clause)
- Privilege separation pattern — propose/dispose split, with a worked example (e.g., LLM drafts a DELETE; non-LLM validator confirms; only validator can execute)
- OWASP LLM Top 10 — one-paragraph entry each, with one defense or detection per item
- RAG-specific attacks (vector poisoning, adversarial documents) — link to rag-engineering ref

Cross-link from `skills/security/SKILL.md` so general security reviewers can find it. Update `agents/ai-engineer.md`, `agents/backend-security-reviewer.md`, and `agents/appsec-reviewer.md` to load this when LLM/agent code is detected.

## Open questions for review

- Should this ref live under `security/` or `ai-engineering/`? Lean ai-engineering — the audience is people building LLM apps, not general appsec — but cross-referenced so security reviewers find it.
- Is there value in a detection-rule sketch (Semgrep / regex patterns for common injection signatures)? Yes, brief, as a starting point — false positives are real and should be acknowledged.
