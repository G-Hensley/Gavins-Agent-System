---
name: APIsec Spec Storage, Parsing, and POST requestBody Flow
description: S3 key format for uploaded specs, downloadSpecFile API endpoint, OAS 3.0 vs Swagger 2.0 requestBody parsing, and what fields must be present for a POST endpoint's body to be fully parsed
type: reference
---

## S3 Storage

**Bucket**: `APPLICATION_SPECS_BUCKET` env var. Dev/on-prem default: `apisec-application-spec-dev`. Production bucket name resolved at runtime from environment.

**Key format** (set in `ApplicationSpecsRepository.putObject`):
```
s3://<APPLICATION_SPECS_BUCKET>/<tenantId>/<applicationId>/openapi-<epochMillis>.json
```

The full S3 URI is the `specPath` stored in DynamoDB on the Application item.

Sub-specs (per endpoint) are stored at:
```
s3://<APPLICATION_SPECS_BUCKET>/<tenantId>/<applicationId>/subspecs/<base64UrlEncodedEndpointId>.json
```

## retrieving the Stored Spec

**REST API** (the correct way to retrieve it):
```
GET /applications/{applicationId}/downloadSpecFile
```
- Defined in `ApisecApplicationsService/.../ApplicationsController.java:837`
- Reads `appInfo.specPath()` from DynamoDB, calls `specResolverService.downloadSpecFile(specFilePath)` which POSTs to OASResolverController `/downloadSpecFile`, which calls `oasProcessor.getSpecFromPath(s3Path)` → `specsRepository.getSpecFromPath(s3Path)` → S3 GetObject.
- Returns the raw spec as a file download (octet-stream).

**Direct S3** (for support/admin):
- Use the `specPath` stored in DynamoDB (on the Application's `:app` item) to construct the S3 key.
- `specPath` is a full S3 URI: `s3://<bucket>/<tenantId>/<appId>/openapi-<timestamp>.json`

## What Fields Must Be Present for POST requestBody Parsing (OAS 3.0)

Parsed in `OASProcessor.buildEndpointInfoWithSensitivityInternal()`:

```java
if (operation.getRequestBody() != null && operation.getRequestBody().getContent() != null) {
  Map<String, MediaType> contentMap = operation.getRequestBody().getContent();
  // Prefers "application/json", falls back to first available
  // Requires: content entry has a non-null Schema
  if (content.getSchema() != null) {
    // schema is processed into requestSchema map
    requestSchema.put(contentType, objectMapper.writeValueAsString(bodyAsJsonNode));
  }
}
```

**Minimum required fields in an OAS 3.0 spec for POST /controlAccounts to have a parsed requestSchema:**
```yaml
/controlAccounts:
  post:
    requestBody:
      content:
        application/json:
          schema:
            type: object
            properties:
              fieldName:
                type: string
```

If `requestBody` is absent, `requestBody.content` is absent, or `content["application/json"].schema` is null, `requestSchema` will be empty and the endpoint has no body params.

## Swagger 2.0 `in: body` Handling

The system uses `io.swagger.parser.OpenAPIParser` (swagger-parser v3). This library **automatically converts** Swagger 2.0 documents into the OpenAPI 3.0 object model. A Swagger 2.0 parameter with `"in": "body"` and a `"schema"` is converted to `operation.requestBody.content["application/json"].schema`.

No separate Swagger 2.0 code path exists for body extraction. The same `OASProcessor.buildEndpointInfoWithSensitivityInternal()` method handles both.

**Minimum Swagger 2.0 structure required:**
```json
{
  "parameters": [
    {
      "in": "body",
      "name": "body",
      "schema": {
        "type": "object",
        "properties": {
          "fieldName": { "type": "string" }
        }
      }
    }
  ]
}
```

Without `schema` under the body parameter, the converted `requestBody` will have no schema and `requestSchema` stays empty.

## Key Files

- `ApisecOpenAPISpecResolver/.../repository/ApplicationSpecsRepository.java` — S3 read/write, key construction
- `ApisecOpenAPISpecResolver/.../processor/OASProcessor.java` — requestBody extraction logic (line ~492)
- `ApisecOpenAPISpecResolver/.../controller/OASResolverController.java` — `/downloadSpecFile` endpoint (line 162)
- `ApisecApplicationsService/.../controller/ApplicationsController.java` — `GET /{id}/downloadSpecFile` (line 837)
- `ApisecApplicationsService/.../service/ApplicationsService.java` — `downloadSpecFile()` (line 1074)
- `APIsecDataPersistenceLibrary/.../storage/S3StoragePathHelper.java` — S3 URI format
