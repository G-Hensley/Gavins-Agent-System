# Expected Findings

Reference answers for scoring the appsec-reviewer agent on the dependency-vuln challenge.

## Critical Findings

### lodash 4.17.20 -- Prototype Pollution

- **CVE:** CVE-2021-23337
- **Severity:** Critical
- **Vector:** Command injection via template function when attacker controls the `variable` option. Prototype pollution in `setWith` and `set` functions.
- **Also relevant:** CVE-2020-28500 (ReDoS in `toNumber`, `trim`, `trimEnd`)
- **Fixed in:** 4.17.21
- **Recommendation:** Upgrade to lodash >=4.17.21

### PyYAML 5.3.1 -- Arbitrary Code Execution

- **CVE:** CVE-2020-14343
- **Severity:** Critical
- **Vector:** `yaml.load()` without a safe Loader allows arbitrary Python object instantiation and code execution via crafted YAML input. Incomplete fix from prior CVE-2017-18342.
- **Fixed in:** 5.4
- **Recommendation:** Upgrade to PyYAML >=6.0.1 and ensure all `yaml.load()` calls use `Loader=yaml.SafeLoader`

## High Findings

### jsonwebtoken 8.5.1 -- Algorithm Confusion / Insecure Key Handling

- **CVE:** CVE-2022-23529
- **Severity:** High
- **Vector:** When the `secretOrPublicKey` parameter is a string or Buffer and the attacker controls the `algorithms` option or the JWT header `alg` field, it is possible to craft tokens that pass verification. Allows authentication bypass in applications that do not explicitly restrict allowed algorithms.
- **Fixed in:** 9.0.0
- **Recommendation:** Upgrade to jsonwebtoken >=9.0.0. Always pass an explicit `algorithms` array to `jwt.verify()`.

### minimist 1.2.5 -- Prototype Pollution

- **CVE:** CVE-2021-44906
- **Severity:** High
- **Vector:** Passing crafted CLI arguments (e.g., `--__proto__.polluted=true`) allows an attacker to inject properties into `Object.prototype`, which can lead to denial of service or remote code execution depending on how downstream code uses the polluted object.
- **Fixed in:** 1.2.6
- **Recommendation:** Upgrade to minimist >=1.2.6

### Jinja2 2.11.3 -- Sandbox Escape

- **CVE:** CVE-2024-34064
- **Severity:** High
- **Vector:** The `xmlattr` filter in Jinja2 allows injection of arbitrary HTML attributes including event handlers, enabling sandbox escape and XSS when rendering attacker-controlled data in HTML attribute contexts.
- **Also relevant:** CVE-2024-22195 (XSS via `xmlattr` filter in earlier versions)
- **Fixed in:** 3.1.4
- **Recommendation:** Upgrade to Jinja2 >=3.1.4

## Medium Findings

### express 4.17.1 -- Multiple Issues in Older 4.x

- **Severity:** Medium
- **Vector:** Express 4.17.1 depends on older versions of `qs` (prototype pollution), `path-to-regexp` (ReDoS via CVE-2024-45296), and `send`/`serve-static` (path traversal on Windows via CVE-2024-43796). While not all are directly exploitable in every deployment, the transitive dependency surface is significantly wider than current releases.
- **Fixed in:** 4.21.x (latest 4.x) or 5.x
- **Recommendation:** Upgrade to express >=4.21.0 to pull in patched transitive dependencies

## Safe Controls (Should NOT Be Flagged)

The reviewer should not flag any of the following as vulnerable. Each false positive incurs a -1 scoring penalty.

### Node.js
| Dependency | Version | Status |
|---|---|---|
| helmet | 7.1.0 | Safe |
| zod | 3.22.4 | Safe |
| winston | 3.11.0 | Safe |
| uuid | 9.0.1 | Safe |

### Python
| Dependency | Version | Status |
|---|---|---|
| requests | 2.31.0 | Safe |
| pydantic | 2.5.3 | Safe |
| python-dotenv | 1.2.2 | Safe |
| uvicorn | 0.25.0 | Safe |

## Scoring Summary

| Finding | Points |
|---|---|
| lodash CVE-2021-23337 identified | +2 |
| PyYAML CVE-2020-14343 identified | +2 |
| jsonwebtoken CVE-2022-23529 identified | +2 |
| Jinja2 CVE-2024-34064 identified | +2 |
| minimist CVE-2021-44906 identified | +1 |
| express transitive dep issues identified | +1 |
| Clean pass on each safe control (8 total) | +0.5 each, max +4 |
| **Maximum possible score** | **14** |

### Deductions

| Issue | Penalty |
|---|---|
| False positive on a safe dependency | -1 each |
| Missed Critical finding | -3 each |
| Missed High finding | -2 each |
| Missed Medium finding | -1 each |
