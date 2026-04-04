---
name: APIsec Sensitivity Service — Full Implementation and Filtering Logic
description: Where the sensitivity service lives, how it scores endpoints, threshold logic, and why an endpoint like POST /controlAccounts could be dropped
type: project
---

## Where the service lives

The sensitivity service is **ApisecParamHydrationAgent** (Python/FastAPI), running on port 8888.
- Entry point: `/Users/gavinhensley/Desktop/Agentic-APIsec/ApisecParamHydrationAgent/app_endpoints_params_inference/api.py`
- Route handler: `/Users/gavinhensley/Desktop/Agentic-APIsec/ApisecParamHydrationAgent/app_endpoints_params_inference/sensitivity/router.py` — `POST /infer-sensitivity`
- Scorer: `/Users/gavinhensley/Desktop/Agentic-APIsec/ApisecParamHydrationAgent/app_endpoints_params_inference/sensitivity/scorer.py`
- Spec parser: `/Users/gavinhensley/Desktop/Agentic-APIsec/ApisecParamHydrationAgent/app_endpoints_params_inference/sensitivity/spec_parser.py`
- Text utils: `/Users/gavinhensley/Desktop/Agentic-APIsec/ApisecParamHydrationAgent/app_endpoints_params_inference/sensitivity/text_utils.py`

The Java client in OASProcessor calls it via:
`/Users/gavinhensley/Desktop/Agentic-APIsec/ApisecOpenAPISpecResolver/src/main/java/ai/apisec/openapispecresolver/service/SensitivityService.java`
Config: `api.aiagentsservice.url` = `$API_AIAGENTS_URL` default `http://ParamHydrationAgentService.apisec.local:8888`

## 3 sklearn models

Models live at `/Users/gavinhensley/Desktop/Agentic-APIsec/ApisecParamHydrationAgent/sensitivity_models/`:
- `SEnew_model` — endpoint model: `predict_proba([text_preprocess(path)])`, class[1] = sensitive probability
- `SEParameter_model` — parameter model: `predict_proba([text_preprocess(param_name)])`, class[1] = sensitive probability
- `FakerDtypemodel` — fake value type prediction (not used for filtering)

## Sensitivity threshold

Default: **0.70** (env var `SENSITIVITY_THRESHOLD`, set in Dockerfile).
No auth override is possible without redeploying the container.

## How an endpoint is scored (4 signals)

```
composite = (model_score * 0.35) + (security_signal * 0.25) + (method_signal * 0.15) + (response_signal * 0.25)
```

- `model_score`: SEnew_model.predict_proba on tokenized path
- `security_signal`: 0.0=secured endpoint, 0.8=open (no security defined), 1.0=auth endpoint itself
- `method_signal`: DELETE=0.9, PUT/PATCH=0.7, POST=0.5, GET=0.3
- `response_signal`: max param_model score over 2xx response schema properties (0.0 if no 2xx responses)

`is_sensitive = composite >= 0.70`

## What `SpecSensitivity.getResources()` contains

The service returns ALL endpoints grouped by resource tag — NOT a filtered subset. Every path/method combination in the spec is included in `resources[].operations[]`. The `is_sensitive` flag per endpoint only affects `ret["sensitivity"] = 1` at the resource level (set if any endpoint in the group scores >= threshold). It does NOT filter out endpoints from the response.

**Critical implication**: if `POST /controlAccounts` is missing from `getResources()`, the cause is NOT a sensitivity threshold filter. Every endpoint is returned regardless of score.

## Where an endpoint could be silently dropped (router.py)

In `router.py` lines 73-98, if `get_endpoint_details()` throws an exception:
- `endpnt_details` is set to a minimal fallback dict (path, method, "Error processing endpoint")
- `is_sensitive` is set to `False`
- The endpoint IS still appended to `ret["operations"]` and returned

So even error cases return the endpoint. The only way an endpoint is dropped is:

1. **It is not in `paths` dict** — `extract_endpoints()` iterates `api.get("paths", {})` and skips keys where `methods` is not a dict
2. **Its HTTP method is not in `_HTTP_METHODS`** — must be one of: get/post/put/delete/head/connect/options/trace/patch
3. **filter_methods="YES" and method is trace/head/options** — filtered out in router.py line 67-69
4. **The whole resource group exception** — if `get_resource_details()` throws, the resource gets `sensitivity=0, operations=[]` but IS still appended to skeleton (line 64, 104). So the resource appears but with zero operations.
5. **`extract_endpoints()` itself throws** — raises `InvalidSpecError` which aborts the whole request with HTTP 400. OASProcessor would then throw `SpecResolutionException(SENSITIVITY_SERVICE_FAILURE)`.

## Why `POST /controlAccounts` could be silently skipped

**Most likely cause**: The endpoint's path/method combination is in the spec BUT `get_endpoint_details()` returns `(None, False)` — meaning the path was found in `extract_endpoints()` but then in `get_endpoint_details()` the inner `for endpoint, methods in paths.items()` loop did NOT match `endpoint == endp`.

This happens if there is a **path normalization mismatch** — e.g., `extract_endpoints` iterates the raw dict key, but `get_endpoint_details` searches the same dict. They use the same `api["paths"]` dict, so this should be equivalent... unless the path string itself has trailing slashes or case differences that make the string comparison `endpoint != endp` fail.

**Second most likely cause**: The endpoint's tag is not matching any resource group. If the operation has no `tags` array, it is grouped under `"unknown"`. If `get_resource_details` then fails for the "unknown" group, all untagged endpoints lose their operations (but the fallback at line 64 sets operations=[] not None).

**Third cause — the `is_sensitive=False` path being misread by OASProcessor**: This is NOT the cause. OASProcessor iterates every operation in every resource and writes it to DynamoDB regardless of sensitivity score.

## text_preprocess for `/controlAccounts`

`text_preprocess("/controlAccounts")`:
- Strips `/api/v1`, `/v1`, etc. prefixes — `/controlAccounts` has no version prefix
- `re.sub(r"[^a-zA-Z\-_]", " ", "/controlAccounts")` → `" controlAccounts"`
- Split → `["controlAccounts"]`
- Final tokens: `["controlAccounts"]` (no split on camelCase — this is important)

The model receives a single token `"controlaccounts"`. Whether it scores >= 0.70 is entirely model-dependent. But this affects `is_sensitive` only, NOT inclusion in the response.

## How OASProcessor uses the response (critical)

`OASProcessor.processOAS()` at line 178 calls `deriveSensitivityFromSpec`. If null → exception.
`processOpenAPI()` at line 359: iterates `specSensitivity.getResources()` → for each resource → for each operation → looks up the path in `openAPI.getPaths()` → if path NOT found throws `SpecResolutionException(MISSING_PATH)` → propagates up and fails the whole spec resolution.

**This means**: if sensitivity service returns an operation whose path cannot be found in the parsed OpenAPI spec, the ENTIRE spec fails with MISSING_PATH error. It does NOT silently skip — it hard-fails.

The silent skip scenario is: the sensitivity service simply never includes the endpoint in any `operations[]` list in its response. OASProcessor only processes what the sensitivity service returns. If `/controlAccounts POST` is absent from the sensitivity response, it is never written to DynamoDB — and there is no log line about it being skipped.

## Logging

The sensitivity service logs:
- `logger.info("infer-sensitivity processed endpoints=%d filter=%s", total_processed, user_input)` — total count only, no per-endpoint list
- `logger.warning("Error processing endpoint=%s method=%s: %s", ...)` — per-endpoint on exception
- `logger.debug("Endpoint processed: %s %s sensitive=%s", ...)` — only at DEBUG level
- `logger.debug("Endpoint not found: %s %s", ...)` — only at DEBUG level (in get_endpoint_details when path/method not found)

Default log level is INFO (Dockerfile: `ENV LOG_LEVEL=INFO`). So the "Endpoint not found" debug log is invisible in production. This is the key gap — if an endpoint silently falls through as `(None, False)` in get_endpoint_details, there is no INFO-level log.

**Why:** `sensitivity_threshold` is the parameter sensitivity filter within `process_parameters`, used only to set `has_sensitive` flag — it does NOT filter endpoints from the response.
**How to apply:** When debugging a missing endpoint, enable DEBUG logging on the sensitivity service and re-upload the spec to see the per-endpoint "Endpoint not found" or "Endpoint processed" log lines. Also check if the endpoint has a `tags` array — untagged endpoints grouped under "unknown" may hit a resource-level exception silently.
