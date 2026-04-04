---
name: APIsec Dev Report Generation Flow
description: Full request lifecycle for developer report generation in ApisecCommunicationsService, including auth identity handling and the SSO bug root cause
type: project
---

## Dev Report Flow

**Service**: ApisecCommunicationsService (separate from port 8080/9080 — ApplicationsService and ScanService)

**Entry point**: `DevReportController` — `/v1/communications/applications/{appId}/instances/{instanceId}/dev-report`
- POST = trigger generation
- GET = poll status
- GET /download = download PDF

**Async generation**: `DevReportOrchestrationService.requestGeneration` saves GENERATING status to DynamoDB then fires `CompletableFuture.runAsync`. Status is polled by frontend via GET.

**Status storage**: `DevReportStatusRepository` uses DynamoDB table `CommunicationsDetails` with partition key = `tenant_id`, sort key = `app~~entity~~instance~~entity~~devreport~~latest`.

**S3 key pattern**: `{tenantId}/{appId}/{instanceId}/dev-report/report.pdf`

## Root Cause of SSO Infinite Loading Bug

The async `generateAndUpload` method calls `ApplicationsService` methods which call `InternalTokenService.createUserToken(tenantId, userId)`. This mints a `USER_SCOPE` internal JWT.

When that token reaches the ApplicationsService's `JwtAuthFilter` (INTERNAL_ISSUER branch), it calls `InternalTokenService.getTenantUserFromToken` → `getRepresentedUser` → `idpService.getUserRole(userId)` → `CognitoService.adminGetUser(userId)`.

**The SSO bug**: For SSO (federated) Cognito users, the `username` (= JWT `sub`) is a Cognito-managed identifier like `OktaSSO_user@company.com` or a UUID-format sub. However, `adminGetUser` is called with that value as the `username` parameter. If the SSO user's Cognito username does not match what `adminGetUser` expects (e.g., it's a provider-attributed sub, not the actual pool username), Cognito throws `CognitoIdentityProviderException` → `getUserRole` returns `Optional.empty()` → `getRepresentedUser` returns `Optional.empty()` → the internal token is rejected → ApplicationsService returns 401/403 → the async `generateAndUpload` throws an exception → the status is set to FAILED.

BUT: the error is caught silently in `generateAndUpload` and status is saved as FAILED. The frontend polls the status but the issue is that:
1. `requestGeneration` returns "ACCEPTED" (HTTP 202) 
2. status transitions to GENERATING briefly  
3. async task fails → status set to FAILED
4. `getStatus` returns "FAILED" but DevReportController still returns HTTP 200 with `{"status":"FAILED"}` — the frontend may not handle this state and stays in loading indefinitely

**Why**: The `createUserToken` call does NOT embed the role in the token for USER_SCOPE — it relies on a live Cognito lookup at the ApplicationsService. SSO users may not be findable by `adminGetUser` using their `sub`/userId as the username.

## Key Files
- CommunicationsService DevReportController: controller/DevReportController.java:20
- CommunicationsService DevReportOrchestrationService: service/DevReportOrchestrationService.java
- CommunicationsService InternalTokenService: service/InternalTokenService.java:107-133 (USER_SCOPE path calls getUserRole)
- CommunicationsService CognitoService: service/CognitoService.java:30 (adminGetUser)
- ApplicationsService JwtAuthFilter: auth/JwtAuthFilter.java:109 (INTERNAL_ISSUER branch)
- ApplicationsService InternalTokenService: auth/InternalTokenService.java:113-139 (same USER_SCOPE → getUserRole path)
- ApplicationsService CognitoService: auth/CognitoService.java:30 (adminGetUser with userId as username)
- DevReportStatusRepository: repository/DevReportStatusRepository.java

**Why:** Recorded because SSO failure is silent in async path — status goes FAILED but frontend has no clear error state handling.
**How to apply:** When debugging report generation failures for SSO tenants, check: 1) if status is FAILED in DynamoDB, 2) if Cognito adminGetUser is failing for SSO usernames, 3) fix = embed role in USER_SCOPE tokens rather than re-fetching from Cognito.
