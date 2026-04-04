---
name: ApisecApplicationsService + ApisecOpenAPISpecResolver — Spec Upload & Endpoint Lifecycle
description: Full lifecycle of spec upload → endpoint extraction → DynamoDB storage; manual add-endpoint path; deduplication and silent failure risks
type: project
---

Key files and entry points for spec upload and endpoint management:

**Entry points:**
- ApplicationsController.registerOas — POST /v1/applications/oas (multipart)
- OASResolverController.uploadSpec — POST /v1/uploadSpec
- OASResolverController.resolveSpec — POST /v1/resolveSpec (async after upload)
- OASResolverController.addEndpoints — POST /v1/add-endpoints (manual add)
- OASResolverController.reloadSpec — POST /v1/reload-spec

**Core processors:**
- OASProcessor.processOAS — calls sensitivity svc, then resolveOpenAPI → processOpenAPI → instanceRepository.addEndpoints
- ReloadSpecProcessor.processAddEndpoints — manual endpoint add path, uses AddEndpointUtil.generatePaths with deduplication
- ReloadSpecProcessor.processReloadSpec — async, diff-based reload

**DynamoDB key structure (ApplicationDetails table, single-table design):**
- PK: tenant_id
- SK: instance##<instanceId>~~endpoint##<endpointId>~~<changesetKey>
- endpointId: Base64-URL of "METHOD:path" (e.g. "POST:/controlAccounts")
- Append-only; pruneToLatestReplaceEvent handles coalescing

**Critical deduplication in AddEndpointUtil.generatePaths:**
- Line 59: `if (pathHasMethod(null, existingPath, method)) { continue; }` — skips if path+method already present in existing spec
- Line 206: same check for OAS 3.x path
- processAddEndpoints sends only the "new paths" subset to the sensitivity service

**Silent failure risks:**
- processReloadSpec is @Async; caller gets HTTP 200 immediately; failures logged but not surfaced to caller
- processAddEndpoints wraps everything in try/catch RuntimeException — exceptions are swallowed at controller level
- sensitivity service failure throws SpecResolutionException which terminates endpoint processing for all endpoints
- If sensitivity service returns no resources for a path, it simply isn't processed (no error logged)

Why: investigates bug where POST /controlAccounts doesn't appear after spec upload or manual add.
