---
name: APIsec Scan — Endpoint Selection and Execution Pipeline
description: How scans select endpoints to test, what makes an endpoint scannable, and how manually-added POST endpoints can stall a scan
type: project
---

## Scan Execution Pipeline (high level)

1. `ScannerService.scan()` → starts an AWS Step Functions execution with `ScanExecutionInput` (includes tenantId, instanceId, scanId, `ScanParams.endpoints` list)
2. SFN state machine iterates endpoints, dispatching `ScanEndpointEvent` per endpoint to `VulnerabilityScanProcessor.process()`
3. `VulnerabilityScanProcessor` calls `BaseScanProcessor.getEndpointDetails()` → `InstanceService.getEndpoint()` → `InstanceRepository.getInstanceEndpoint()` (DynamoDB read)
4. Runs a BFS over the recipe graph (built by `RecipeBuilder`), executing each security test in dependency order
5. First test always: `recon.dryRun`. All other tests gate on its result via `needs_context_and_dry_run`

## Endpoint Data Model (DynamoDB)

`APIEndpointInfo` record (shared between ApplicationsService and ScanService via APIsecDataPersistenceLibrary):
- `resource`, `method` — path and HTTP method
- `attributes` — map of in → List<AttributeInfo> (headers, query, path, body params)
- `requestSchema` — Map<String,String> keyed by content-type, value is JSON schema string
- `responseSchemas` — similar
- `variables` — resolved param values
- `requiresAuthorization`

`requestSchema` is the JSON schema of the request body. It comes from the spec parser (OASProcessor) when the spec is loaded. **If null, multiple tests mark the endpoint INELIGIBLE.**

## What Makes an Endpoint "Scannable"

No explicit enabled/disabled flag. All endpoints in the instance are scannable by default. `ScanParams.endpoints` is a list that can restrict to specific endpoint IDs; if empty/null the SFN iterates all endpoints in the instance.

## Manually Added Endpoint Flow

API: `POST /applications/{id}/instances/{instanceId}/endpoints`  
→ `InstancesController.addEndpoints()` (ApplicationsService:2547)  
→ `ApplicationsService.addEndpoints()` (:763)  
→ `SpecResolverService.addEndpoints()` (HTTP POST to ApisecOpenAPISpecResolver `/add-endpoints`)  
→ `OASResolverController.addEndpoints()` → `ReloadSpecProcessor.processAddEndpoints()` (:881)  
→ `AddEndpointUtil.generatePaths()` — builds a spec fragment for the new endpoints  
→ `oasProcessor.processOpenAPI()` — re-runs spec processing to persist endpoint info to DynamoDB

`AddEndpointInput` has 3 fields: `endpoint` (path), `method`, `payload` (optional JSON string of body example).

**Critical behavior in `AddEndpointUtil.generatePaths()`:**
- For POST/PUT/PATCH: always adds a `requestBody` reference to a schema component
- The schema component is ONLY created if `payload` is non-blank (`:222`)
- If `payload` is blank/null: the requestBody reference in the spec points to a schema component that **does not exist** in the components map

**What this means for `OASProcessor.buildEndpointInfoWithSensitivity()`**: when it processes that spec fragment, the referenced schema component is absent, so `requestSchema` on the persisted `APIEndpointInfo` will be null.

## What Causes Tests to Stall on the Endpoint

In `APIsecSecurityTests`, the `EndpointDetail` model constructs `oas_endpoint` from `oas_spec` (a per-endpoint OAS sub-spec fetched from S3 by `ApplicationSpecsRepository.getEndpointSubSpec()`).

`EndpointDetail.request_body_schema` is a computed property: returns `None` if `parsed_oas_spec` is None or if the first endpoint in the parsed spec has no request_body.

Multiple tests immediately return `StateEnum.ineligible` when this is None:
- `mass.massAssignment` (`:1512`): "Endpoints without request body schemas do not qualify for this test."
- `ssrf.url` (`:97-100`): same check
- Likely others in `injection`, `discovery`, etc.

The dryRun test itself (`recon.dryRun`) does NOT check request body schema — it just fires the endpoint as-is with whatever body is available. So dryRun succeeds or fails based on actual HTTP response.

**The actual stall**: The test doesn't stall in an infinite loop. "Tests stall" likely means the scan worker on the SFN side waits indefinitely for the `VulnerabilityScanProcessor` Lambda to return a result. If `endpointDetails.getBody()` returns null for a POST endpoint without a stored requestBody, the dryRun fires `POST /controlAccounts` with a null body. The real endpoint may return 4xx. If dryRun gets a non-2xx, ALL downstream tests are skipped (they all depend on `recon.dryRun` in the recipe graph). The scan itself completes but shows all tests skipped.

## Fresh App vs Existing App Difference

A fresh app imports a full spec where `requestSchema` is populated from the OAS requestBody definition. A manually added endpoint has `requestSchema = null` in DynamoDB unless the user supplied a `payload` in `AddEndpointInput`.

The sub-spec is generated in `processAddEndpoints` via `persistSubSpecsSafely()` using the merged spec, so `oas_spec` may actually be present in S3 for the manually-added endpoint. However, if the schema component was missing when the spec was written (because `payload` was blank), the sub-spec will reference a missing `$ref`, causing `OpenAPI3Parser` to fail or return no request_body, meaning `request_body_schema` is still None.

**Why:** `AddEndpointUtil.generateParameter()` always sets `requestBody` with a `$ref` to `#/components/schemas/{ModelName}` for POST (:309-323). But `generateSchema()` is only called when `payload` is non-blank (:222). If blank, the schema component is never added to `components`. The spec is syntactically valid JSON but has a dangling `$ref`. When the SecurityTests parser reads this sub-spec, it may silently skip the request body, leaving `request_body_schema = None`.

## Essential Files

- `ApisecOpenAPISpecResolver/.../service/AddEndpointUtil.java` — THE BUG SOURCE: dangling $ref when payload is blank
- `ApisecApplicationsService/.../models/AddEndpoint/AddEndpointInput.java` — input model (payload is @Nullable)
- `ApisecApplicationsService/.../service/InstanceService.java:720` — addAdditionalEndpointInfo / updateExistingEndpointInfo (requestSchema handling)
- `ApisecScanService/.../processor/BaseScanProcessor.java:48` — getEndpointDetails: builds EndpointDetails from APIEndpointInfo.requestSchema
- `ApisecScanService/.../processor/VulnerabilityScanProcessor.java:175` — processRecipe: BFS scan loop
- `APIsecSecurityTests/categories/mass/mass_assignment_endpoint.py:1512` — ineligible when request_body_schema is None
- `APIsecSecurityTests/categories/core_models.py:64` — EndpointDetail.request_body_schema property
- `APIsecSecurityTests/categories/recon/dryRun.py` — dryRun test (no body schema check, fires as-is)
- `ApisecScanService/.../service/SecurityTestsService.java` — bridges ScanService → SecurityTests HTTP calls

**Why:** How to apply: when a manually added POST endpoint shows "tests stall/skip", check whether the endpoint's `requestSchema` is null in DynamoDB, and whether the sub-spec in S3 has a dangling $ref for the requestBody. The fix is to either (1) force an empty object schema when payload is blank, or (2) omit the requestBody entirely from the spec fragment when no payload is supplied.
