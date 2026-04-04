---
name: APIsec DynamoDB ApplicationDetails — Endpoint Query Reference
description: Exact key structure, endpointId formula, field names, and AWS CLI query for fetching an endpoint record from the ApplicationDetails DynamoDB table
type: reference
---

## Table: `ApplicationDetails`

Region: `us-east-1` (confirmed in ApisecApplicationsService/src/main/resources/application.properties)

### Key Schema

- **PK** (`tenant_id`): the tenant identifier string
- **SK** (`entity`): a compound sort key built from entity segments joined by `~~`

### Sort Key Formula for an Endpoint Record

```
instance##<instanceId>~~endpoint##<endpointId>~~changeset##<uuid>
```

Where:
- `##` is the entity formatter (within a single entity component)
- `~~` is the entity separator (between entity tiers)
- `endpointId` = `Base64.getUrlEncoder().encodeToString("METHOD:/path".getBytes(UTF_8))`
  - Example: `POST:/controlAccounts` → `UE9TVDovY29udHJvbEFjY291bnRz`
  - Source: `InstanceService.java:1991-1993`

Since endpoints are append-only (event sourcing), multiple items exist per endpoint.
The sort key **prefix** is `instance##<instanceId>~~endpoint##<endpointId>` and the
`changeset##<uuid>` suffix is the time-ordered changeset version.

### DynamoDB Item Attributes

| Attribute | Column Constant | Content |
|-----------|----------------|---------|
| `tenant_id` | ATTR_PARTITION_KEY | tenant identifier (PK) |
| `entity` | ATTR_SORT_KEY | compound sort key (SK) |
| `payload` | ATTR_PAYLOAD | JSON string of `APIEndpointInfo` |
| `payload_bytes` | ATTR_PAYLOAD_BYTES | GZIP-compressed binary of payload (used when > 400KB threshold) |
| `changeset_event` | ATTR_CHANGESET | `CREATE_ENDPOINT` or `EDIT_ENDPOINT` |
| `entity_name` | ATTR_ENTITY | `endpoint` |
| `entity_id` | ATTR_ENTITY_ID | the base64url endpointId |
| `updated_by` | ATTR_UPDATED_BY | creator/updater identity |
| `updated_at` | ATTR_UPDATED_AT | ISO timestamp |
| `version_chain` | ATTR_CONCURRENCY_CONTROL_VERSION | concurrency control |

Source: `ApplicationDetailsColumns.java`

### `APIEndpointInfo` Record Fields

```java
record APIEndpointInfo(
    String resource,                          // path, e.g., "/controlAccounts"
    String method,                            // HTTP method, e.g., "POST"
    Map<String, List<AttributeInfo>> attributes,  // endpoint parameters/attributes
    Map<String, String> requestSchema,        // request body schema (null for manually-added POST)
    Map<String, String> responseSchemas,      // response schemas by status code
    String function,                          // function identifier
    Map<String, ParamVariable> variables,     // instance-level variable overrides
    boolean requiresAuthorization,            // auth required flag
    double sensitivity,                       // sensitivity score
    String sensitivityQualifier,              // qualifier string
    Map<String, String> metadata              // arbitrary metadata
)
```

Source: `APIsecDataPersistenceLibrary/src/main/java/ai/apisec/datapersistence/model/entity/APIEndpointInfo.java`

### AWS CLI Query (prefix scan for all changesets of an endpoint)

```bash
aws dynamodb query \
  --region us-east-1 \
  --table-name ApplicationDetails \
  --key-condition-expression "tenant_id = :pk AND begins_with(entity, :sk_prefix)" \
  --expression-attribute-values '{
    ":pk": {"S": "<tenant_id>"},
    ":sk_prefix": {"S": "instance##<instanceId>~~endpoint##UE9TVDovY29udHJvbEFjY291bnRz"}
  }' \
  --output json
```

To get the payload (accounting for possible binary/GZIP):
- If item has `payload_bytes` (binary attribute `B`), it is GZIP-compressed JSON — decompress before reading
- If item has `payload` (string attribute `S`), it is raw JSON of `APIEndpointInfo`

Multiple items are returned (one per changeset). The effective state is the merge
of all items starting from the latest `CREATE_ENDPOINT` changeset forward, with
later `EDIT_ENDPOINT` items shallow-merging over it.

### Computing the endpointId

```python
import base64
endpoint_str = "POST:/controlAccounts"
endpoint_id = base64.urlsafe_b64encode(endpoint_str.encode()).decode()
# → "UE9TVDovY29udHJvbEFjY291bnRz"
```

Note: Java uses `Base64.getUrlEncoder()` (URL-safe, no padding stripping by default),
Python `urlsafe_b64encode` adds `=` padding. If the ID in the table doesn't include
padding, strip with `.rstrip('=')`.

### Existing Tooling

- **apisec-toolkit-v2** (`/Users/gavinhensley/Desktop/Projects/APIsec/apisec-toolkit-v2/`)
  - Uses APIsec REST API, NOT direct DynamoDB — goes through `GET /applications/{appId}/instances/{instanceId}/endpoints`
  - No existing DynamoDB direct query scripts
- **SheepDog client** (`/Users/gavinhensley/Desktop/Projects/APIsec/docs/toph/src/tools/sheepdog/client.py`)
  - Uses boto3 against a *different* DynamoDB table set (SheepDog tables with prefix, not `ApplicationDetails`)
  - Not useful for direct ApplicationDetails endpoint queries
- **No existing AWS CLI wrapper** targeting ApplicationDetails for endpoint record inspection

### AWS Profile for Local Dev

Use profile `dev-account-profile` or set `APISEC_AWS_PROFILE` env var.
Current default region in `~/.aws/config` is `us-east-2` but the ApplicationDetails
table is in `us-east-1` — must specify `--region us-east-1` explicitly.
