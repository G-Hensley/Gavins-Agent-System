# Breaking: Change /customers/{id} Response Shape

**Goal:** Move nested `contact` object to top-level fields on the customer response.

## Task 1: Update API response

- Modify `api/src/schemas/customer.ts` to flatten the response shape
- Remove `contact` nested object; add `email`, `phone`, `name` at top level
- Bump OpenAPI spec version in `docs/openapi.yaml`
- Mark this as a breaking change in `CHANGELOG.md`
