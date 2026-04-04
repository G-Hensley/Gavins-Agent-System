---
name: APIsec Endpoint Data Model and Spec Resolution Flow
description: Endpoint DynamoDB schema, ID generation, spec upload vs reload logic, ghost-state failure modes
type: project
---

# Endpoint Data Model & Spec Flow

**Why:** Bug where POST /controlAccounts appears in UI but tests don't execute. Needed to trace the full endpoint lifecycle.

## DynamoDB Table: ApplicationDetails (single-table design)

Partition key: `tenant_id`
Sort key: `entity` — compound, e.g. `instance##<instanceId>~~endpoint##<endpointId>~~changeset##<uuid>`

Other columns: `payload` (JSON), `payload_bytes` (GZIP binary for endpoints/variables), `changeset_event`, `entity_name`, `entity_id`, `updated_by`, `updated_at`

Entity name values: `app`, `instance`, `model`, `variables`, `headers`, `member`, `endpoint`, `group`, `scanConfig`, `schedule`, `instanceconfig`, `scan`, `rbac`, `auth`, `scanProfile`

## Endpoint ID Generation

`OASProcessor.generateEndpointId()` at OASProcessor.java:431:
```
Base64.getUrlEncoder().encodeToString("METHOD:path".getBytes(UTF_8))
```
Example: POST + /controlAccounts → Base64URL("POST:/controlAccounts")

## Endpoint Data Model

`APIEndpointInfo` record (APIEndpointInfo.java):
- `resource` (path string)
- `method`
- `attributes` (Map<String, List<AttributeInfo>>) — keyed by param location: path, query, header, body
- `requestSchema` (Map<String, String>) — keyed by content-type e.g. "application/json"
- `responseSchemas`
- `function`
- `variables` (Map<String, ParamVariable>)
- `requiresAuthorization`
- `sensitivity` (double)
- `sensitivityQualifier`
- `metadata` (Map<String, String>)

NO `status`, `isActive`, `source`, `operationId`, or `specVersion` fields — the model is lean.

## Append-Only Semantics (Event Sourcing)

Endpoints use append-only writes. ChangesetEvent values: CREATE_ENDPOINT, EDIT_ENDPOINT, DELETE_ENDPOINT.

On read: `pruneToLatestReplaceEvent(items, CREATE_ENDPOINT)` discards all records before the latest CREATE_ENDPOINT, then `coalescePayloads` JSON-merges EDIT_ENDPOINT patches on top.

There is NO soft-delete or tombstone — DELETE_ENDPOINT removes the DynamoDB rows.

## Spec Upload vs Reload Paths

### First upload: POST /v1/resolveSpec (OASResolverController.java:48)
→ `OASProcessor.processOAS()` → `resolveOpenAPI()` → `processOpenAPI()`
→ calls `SensitivityService.deriveSensitivityFromSpec()` (external HTTP call)
→ iterates `specSensitivity.getResources()` only — endpoints NOT in sensitivity response are silently skipped
→ `instanceRepository.addEndpoints()` batch writes

### Spec reload: POST /v1/reload-spec → `ReloadSpecProcessor.processReloadSpec()`
Three modes controlled by flags (overwriteVal, overwriteEndConfig, deleteEndpoints):
1. All three true: full delete + reloadSpec (treated as new upload)
2. Partial combos: OpenApiCompare diff → only `newEndpoints` from diff get reloaded
   - Existing endpoints are SKIPPED by the diff (they're not in `newEndpoints`)
   - `addEndpoints()` appends a new CREATE_ENDPOINT record — does NOT replace existing

### Manual add: POST /v1/add-endpoints → `processAddEndpoints()` (ReloadSpecProcessor.java:881)
1. Loads current spec from S3
2. `AddEndpointUtil.generatePaths()` builds minimal Swagger/OAS with only new endpoints
   - If path+method already exists in spec → `pathHasMethod` check → **silently skips with `continue`**
3. Calls `SensitivityService.deriveSensitivityFromSpec(addedEpSpec)` on the new-endpoints-only spec
4. `processOpenAPI()` → `addEndpoints()` → writes CREATE_ENDPOINT records

## Key Failure Modes ("Ghost State")

### Failure Mode 1: Sensitivity service silently omits the endpoint
Both paths rely on `specSensitivity.getResources()` as the iteration driver. If the sensitivity service doesn't include POST /controlAccounts in its response, the endpoint is never written to DynamoDB. No error is thrown. This is the most likely cause of the "silently failed to add" during spec upload.

### Failure Mode 2: Spec reload diff sees it as "existing"
If the spec already contained POST /controlAccounts (even with no DynamoDB record), OpenApiCompare would not include it in `newEndpoints` → the `reloadSpec()` path never fires for it. Result: no CREATE_ENDPOINT is written.

### Failure Mode 3: Manual add — path already in spec
`AddEndpointUtil.generatePaths()` at line 59/206 checks `pathHasMethod` — if the method already exists on that path in the stored spec, it does a `continue` silently. If the spec was updated from the failed upload attempt, this check would skip it.

### Failure Mode 4: Item size exceeds 400KB
`InstanceRepository.addEndpoints()` at line 879 skips storing the endpoint with only a `log.warn` if serialized size > 400KB (POST bodies with large schemas can hit this).

## How to Apply
When debugging why an endpoint appears in UI but doesn't get tested:
- Check if there's a DynamoDB record (query by endpointId = Base64URL("POST:/controlAccounts"))
- If no record: sensitivity service likely didn't include it → check its response for that spec
- If record exists: check if `requestSchema` is empty/null → test runner may need the schema
- Check the stored spec in S3 — if it already has the path+method, manual add will silently skip it
