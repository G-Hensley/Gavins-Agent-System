# OpenAPI / Swagger Patterns

## Basic Structure
```yaml
openapi: 3.0.3
info:
  title: My API
  version: 1.0.0
paths:
  /users:
    get:
      summary: List users
      parameters:
        - $ref: '#/components/parameters/PageParam'
        - $ref: '#/components/parameters/LimitParam'
      responses:
        '200':
          description: List of users
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/UserListResponse'
    post:
      summary: Create user
      requestBody:
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/CreateUserRequest'
      responses:
        '201':
          description: User created
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/User'
```

## Schema Reuse with $ref
Define schemas once in `components/schemas`, reference everywhere:
```yaml
components:
  schemas:
    User:
      type: object
      required: [id, name, email]
      properties:
        id: { type: string, format: uuid }
        name: { type: string, maxLength: 100 }
        email: { type: string, format: email }
    CreateUserRequest:
      type: object
      required: [name, email]
      properties:
        name: { type: string, maxLength: 100 }
        email: { type: string, format: email }
```

## Reusable Parameters
```yaml
components:
  parameters:
    PageParam:
      name: page
      in: query
      schema: { type: integer, minimum: 1, default: 1 }
    LimitParam:
      name: limit
      in: query
      schema: { type: integer, minimum: 1, maximum: 100, default: 20 }
```

## Error Schema
```yaml
components:
  schemas:
    Error:
      type: object
      required: [error]
      properties:
        error:
          type: object
          required: [code, message]
          properties:
            code: { type: string }
            message: { type: string }
            details:
              type: array
              items:
                type: object
                properties:
                  field: { type: string }
                  message: { type: string }
```

## Versioning
- URL path: `/api/v1/users` (simplest, most common)
- Increment for breaking changes only
- Document migration path for each version bump

## Documentation Generation
- Use `description` fields on every operation, parameter, and schema
- Add `example` values for request/response bodies
- Generate docs with Swagger UI, Redoc, or Stoplight
