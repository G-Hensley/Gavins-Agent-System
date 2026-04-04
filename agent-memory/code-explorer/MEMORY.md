# Memory Index

- [APIsec Toolkit — Programmatic Tool Interface](apisec-toolkit-tool-interface.md) — minimal interface to invoke tools programmatically, collector function signatures, input/output contracts
- [ApisecWebsite — Developer Report Button Flow](apisec-website-report-flow.md) — entry points, polling logic, SSO auth token bug location for developer report page
- [APIsec Dev Report Generation — Backend Flow](apisec-dev-report-flow.md) — CommunicationsService report lifecycle, SSO Cognito adminGetUser failure root cause, DynamoDB/S3 patterns
- [ApisecApplicationsService — Spec Upload & Endpoint Lifecycle](apisec-spec-upload-endpoint-flow.md) — Full spec-to-endpoint flow, DynamoDB key structure, deduplication logic, silent failure risks in add-endpoint path
- [APIsec Endpoint Data Model and Spec Resolution Flow](apisec-endpoint-model-and-spec-flow.md) — Full DynamoDB schema, endpointId formula, ghost-state failure modes (sensitivity omission, diff skip, pathHasMethod skip, 400KB limit)
- [APIsec Scan — Endpoint Selection and Execution Pipeline](apisec-scan-endpoint-selection.md) — How scans pick endpoints, requestSchema null bug for manually-added POST endpoints, INELIGIBLE conditions in SecurityTests
- [APIsec INELIGIBLE Log Patterns](apisec-scan-ineligible-log-patterns.md) — Exact reason strings per test, MDC/JSON log fields, why INELIGIBLE reasons do NOT appear in CloudWatch at INFO level
- [APIsec Spec Storage, Parsing, and POST requestBody Flow](apisec-spec-storage-and-parsing.md) — S3 key format, downloadSpecFile API, exact OAS 3.0 and Swagger 2.0 fields required for POST requestBody to be parsed
- [APIsec DynamoDB ApplicationDetails — Endpoint Query Reference](apisec-dynamodb-endpoint-query.md) — Exact key structure, endpointId base64url formula, AWS CLI query, APIEndpointInfo fields, payload/payload_bytes GZIP note
- [APIsec Sensitivity Service — Full Flow and Filtering Logic](apisec-sensitivity-service-flow.md) — Where service lives (ApisecParamHydrationAgent), 3 sklearn models, threshold=0.70, all endpoints returned regardless of score, silent drop causes, debug logging gap
