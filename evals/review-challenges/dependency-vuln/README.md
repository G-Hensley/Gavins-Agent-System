# Dependency Vulnerability Review Challenge

Seeded-defect evaluation for the `appsec-reviewer` agent.

## What This Is

A dual-stack API service (Node.js + Python) for document processing. The Node.js layer handles HTTP routing, authentication, and request validation. The Python component handles document parsing, template rendering, and config management. Both `package.json.fixture` and `requirements.txt.fixture` contain intentionally pinned vulnerable dependency versions mixed with safe current versions as false-positive controls.

> **Why the `.fixture` suffix?** The manifests are renamed from the standard `package.json` / `requirements.txt` so GitHub Dependabot does not pick them up as live dependencies. They are content-identical to the standard formats — only the filename differs. The reviewer agent should still be able to read and analyze them.

## What the Reviewer Should Find

### Node.js (`package.json.fixture`)

| Dependency | Version | Vulnerability | Difficulty | Expected Severity |
|---|---|---|---|---|
| `lodash` | 4.17.20 | Prototype pollution (CVE-2021-23337) | Easy | Critical |
| `jsonwebtoken` | 8.5.1 | Algorithm confusion (CVE-2022-23529) | Medium | High |
| `express` | 4.17.1 | Open redirect / header injection in older 4.x | Medium | Medium |
| `minimist` | 1.2.5 | Prototype pollution (CVE-2021-44906) | Medium | High |
| `helmet` | 7.1.0 | Safe control | N/A | None |
| `zod` | 3.22.4 | Safe control | N/A | None |
| `winston` | 3.11.0 | Safe control | N/A | None |
| `uuid` | 9.0.1 | Safe control | N/A | None |

### Python (`requirements.txt.fixture`)

| Dependency | Version | Vulnerability | Difficulty | Expected Severity |
|---|---|---|---|---|
| `PyYAML` | 5.3.1 | Arbitrary code execution via `yaml.load()` (CVE-2020-14343) | Easy | Critical |
| `Jinja2` | 2.11.3 | Sandbox escape (CVE-2024-34064) | Medium | High |
| `requests` | 2.31.0 | Safe control | N/A | None |
| `pydantic` | 2.5.3 | Safe control | N/A | None |
| `python-dotenv` | 1.2.2 | Safe control | N/A | None |
| `uvicorn` | 0.25.0 | Safe control | N/A | None |

## Scoring

| Result | Points |
|---|---|
| Correctly identifies lodash prototype pollution | +2 |
| Correctly identifies jsonwebtoken algorithm confusion | +2 |
| Correctly identifies express vulnerability | +1 |
| Correctly identifies minimist prototype pollution | +1 |
| Correctly identifies PyYAML code execution | +2 |
| Correctly identifies Jinja2 sandbox escape | +2 |
| Does NOT flag safe controls (per clean dep) | +0.5 each (max +4) |
| False positive on safe dependency | -1 each |
| Missed Critical finding | -3 each |
| Missed High finding | -2 each |
| Missed Medium finding | -1 each |

**Max score: 14**

- 12-14: Excellent -- catches vulnerabilities across both ecosystems with no false positives
- 9-11: Good -- catches most issues, may miss a medium or have a minor false positive
- 5-8: Needs improvement -- missing significant vulnerabilities or too many false positives
- <5: Failing -- not suitable for supply chain review

## How to Run

Dispatch the appsec-reviewer using the prompt in `eval-prompt.md` and compare output against `expected-findings.md`.
