---
name: APIsec INELIGIBLE Log Patterns and Skip Reasons
description: Exact log messages, return values, and structured fields emitted when an endpoint/test is marked INELIGIBLE across APIsecSecurityTests, ApisecScanService, and ApisecHostedAgent
type: project
---

## Where INELIGIBLE decisions happen and what gets logged

### APIsecSecurityTests (Python/FastAPI) — the decision point

The `StateEnum.ineligible` value is returned inside `TestOutput` objects from `get_request()`.
No logger call is made at the point of the ineligible decision — these are **return values only**, not log lines.
The ineligible reason string surfaces in the `reason` field of the JSON response body.

**Key ineligible reason strings per test:**

#### mass/mass_assignment_endpoint.py — `get_request()` (line 1512)
- No request body schema:
  `"Endpoints without request body schemas do not qualify for this test."`
- No parsed OAS spec:
  `"Could not parse the OpenAPI specification for this endpoint."`
- No success response schema:
  `"This endpoint has no success response schema for mass assignment."`
- No successful dry run with JSON object response:
  `"No successful recon dry-run with a JSON object response is available for this endpoint; mass assignment requires that probe."`
- No drift found:
  `"No drift was found for this endpoint (no response fields to exercise against the write contract). ..."`
- No auth settings but endpoint is authenticated:
  `"Running this test requires authentication configuration. ..."`

#### injection/tech_broken_down.py — `get_request()`
- No parameters, no body, no request_body_schema (line ~138):
  `"The endpoint doesn't have URL query or path parameters or request body, hence it doesn't have attack vectors for technical injection and is not vulnerable."`
- All 502/504 during dry run:
  `"The endpoint responded with 502 or 504 status codes during the dry run,indicating that the endpoint is not ready to receive requests."`
- Inconclusive (get_results, line ~344):
  `"The endpoint responded with a {status} status code. During the dry run, the API responded with a similar status code, indicating that we don't have enough information to send successful requests to this endpoint..."`

#### ssrf/url.py — `get_request()`
- No parameters, no body, no request_body_schema (line ~99):
  `"The endpoint doesn't have URL query or path parameters or request body, hence it doesn't have attack vectors of SSRF URL and is not vulnerable."`
- All 502/504 during dry run:
  `"The endpoint responded with 502 or 504 status codes during the dry run,indicating that the endpoint is not ready to receive requests."`
- Temp restriction on private API:
  `"SSRF tests are temporarily unavailable for private APIs."`

#### recon/dryRun.py — `get_results()` (line ~111)
When status >= 300, returns `StateEnum.ineligible` with the reason from `get_dry_reason()`:
  `"Dry run assesses the testability of the endpoint. A successful response is necessary for running deep security category tests, although it is not required for assessing server configurations and response headers. Please review the request and response logs to investigate the dry run results..."`

#### test_requirements.py — decorators (applied to most get_request/get_results)
- `has_successful_dry_run` (line ~36):
  `"None of the dry run responses were successful, which means this test does not meet the necessary preconditions to be executed. Please check the dry run logs and add the necessary configuration to ensure dry runs run successfully."`
- `at_least_one_non_null_response`:
  `"All responses from the dry run came empty. If that's the typical behaviour of this endpoint, then this test doesn't qualify for excessive data analysis..."`
- `is_authenticated` (line ~103):
  `"This test checks whether authenticated endpoints enforce authentication. This is not an authenticated endpoint, hence we don't need to run this test."`
- `enforces_authentication`:
  `"A previous test discovered that this endpoint is accepting unauthenticated requests, hence this test doesn't qualify..."`
- `has_jwt`:
  `"This category tests whether the API is vulnerable to tampered JSON Web Tokens (JWTs). We did not identify JWTs in the credentials, hence this category doesn't apply."`
- `at_least_two_credentials`:
  `"We need at least two credentials to run this test."`

**Log level for ineligible decisions: NONE in Python tests** — the reason is only in the returned JSON, not emitted to the logger. The `main.py` route handler does log `getTest: test_id=...` at INFO before calling into the test provider, but does not log the ineligible result.

---

### ApisecScanService (Java/Micronaut) — where INELIGIBLE is recorded

**No dedicated log line for INELIGIBLE decisions.** The ineligible outcome is silently added to `endpointScanResults` and persisted via `scanDetailsService.persistTestLog()`.

Key code path in `VulnerabilityScanProcessor.processRecipe()` (line ~276):
```
if (testExecutionDetails.executionState() != null &&
        testExecutionDetails.executionState().equals(ExecutionState.INELIGIBLE)) {
    // → buildTestExecutionOutcome → persistTestLog
    // NO log.warn/info/debug here
    endpointScanResults.add(ineligibleTestOutcome);
    categoryScanStats.incrementSkippedTestCount(...);
    continue;
}
```

In `CategoryTestResultInterpreter.processTestResultsV2()` (line ~172):
```
case INELIGIBLE:
    // → persistTestLog
    // NO log line
    categoryScanStats.incrementSkippedTestCount(...);
    break;
```

**There is NO log.warn/info/debug emitted specifically for INELIGIBLE tests in ScanService.**

Closest observable log entries in ScanService:
- `log.debug("Executing recipe for {}", vertex)` — logs the test vertex (e.g. `mass.massAssignment`) before attempting
- `log.info("Endpoint call executed for {}. Response {}", vertex, executeCallResponses)` — logged after execution, NOT for ineligible (which exits before execution)
- `log.warn("SecurityTests returned error on /getTest => Category: {}, Test: {}, error: {}", categoryId, categoryTestId, error)` — only when getTest response has an error field

---

### Structured Log Fields (what to search in CloudWatch/log aggregator)

**ApisecScanService MDC context** (set at message processing start, attached to every log line):
- `tenantId`
- `applicationId`
- `instanceId`
- `scanId`
- `requestId`
- `traceId`
- `service` = `"scanservice"`

**APIsecSecurityTests JSON log context** (from `log_context.py`, merged into every log record):
- `requestId`
- `taskId`
- `applicationId`
- `instanceId`
- `phase`
- `service` = `"apisec_tests"`
- `logger` — e.g. `"apisec_tests.api"` for the main route handler

**Key searchable log messages in APIsecSecurityTests (INFO level):**
- `"getTest: test_id=mass.massAssignment, payload=..."` — logged before every get_request call, includes the full payload JSON
- `"Request completed: POST /getTest status=200 duration_ms=..."` — logged by middleware after every request

**Searching for POST /controlAccounts INELIGIBLE in CloudWatch:**
1. Search for `getTest` + the endpoint path or test ID
2. The reason string itself is NOT logged — it's returned in the HTTP response body which ScanService receives
3. ScanService logs `log.debug("Request /getTest => ...")` at DEBUG level with the full endpointDetails — only visible if DEBUG is enabled
4. The reason ends up in the persisted test log (S3/blob), not in CloudWatch structured logs

**Conclusion: INELIGIBLE skip reasons for POST /controlAccounts will NOT appear in CloudWatch at default INFO log level.** They are persisted to the scan test log blob store by `scanDetailsService.persistTestLog()`.

---

### Essential files
- `/APIsecSecurityTests/categories/mass/mass_assignment_endpoint.py` — `get_request()` line 1512 — the `request_body_schema` check
- `/APIsecSecurityTests/categories/injection/tech_broken_down.py` — `_is_eligible()` line 86
- `/APIsecSecurityTests/categories/ssrf/url.py` — ineligible check line 94
- `/APIsecSecurityTests/categories/test_requirements.py` — all decorator-based ineligible returns
- `/APIsecSecurityTests/categories/recon/dryRun.py` — dry run ineligible on 3xx+
- `/APIsecSecurityTests/categories/recon/dry_run_reason.py` — reason string builder
- `/APIsecSecurityTests/categories/core_models.py` — `request_body_schema` property line 64
- `/APIsecSecurityTests/main.py` — `/getTest` route, INFO log at entry line 156
- `/APIsecSecurityTests/log_context.py` — structured log fields
- `/ApisecScanService/src/main/java/ai/apisec/scanservice/processor/VulnerabilityScanProcessor.java` — INELIGIBLE handling line 276
- `/ApisecScanService/src/main/java/ai/apisec/scanservice/helper/CategoryTestResultInterpreter.java` — INELIGIBLE case line 172
- `/ApisecScanService/src/main/java/ai/apisec/scanservice/logging/MdcContext.java` — MDC field names
