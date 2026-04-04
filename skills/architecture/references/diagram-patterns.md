# Architecture Diagram Patterns

Reference for creating clear, useful architecture documentation. Read when writing the technical design doc (Step 6).

## System Context Diagram

Shows the system as a whole and its external interactions. Start here — before diving into internals.

```
[User] → [Your System] → [External API]
                       → [Database]
                       → [Third-party Service]
```

Include: system name, all external actors (users, services, APIs), direction of data flow, protocol/transport (REST, WebSocket, queue).

## Component Diagram

Shows internal components and how they communicate. One level deeper than context.

```
┌─────────────────────────────────────────┐
│                  System                  │
│  ┌──────────┐  ┌──────────┐  ┌───────┐ │
│  │ API Layer │→│ Service  │→│  Data  │ │
│  │          │  │  Layer   │  │ Layer  │ │
│  └──────────┘  └──────────┘  └───────┘ │
└─────────────────────────────────────────┘
```

Include: component names, responsibilities (one sentence each), dependencies between components, interfaces/contracts at boundaries.

## Data Flow Diagram

Traces how data moves through the system from entry to storage.

```
User Input → Validation → Transform → Business Logic → Persist → Response
                ↓                          ↓
            Error Response            Side Effects
                                    (notifications, logs)
```

Include: data entry points, each transformation step, where data is stored, where errors are handled, side effects triggered.

## Entity Relationship Diagram

Shows data entities, their attributes, and relationships.

```
[User] 1──* [Project] 1──* [Task]
  │                          │
  └────────* [Comment] *─────┘
```

Include: entity names, key attributes, relationship types (1:1, 1:many, many:many), foreign keys, required vs optional fields.

## Sequence Diagram

Shows the order of operations between components for a specific workflow.

```
User → API → Auth → Service → DB
  │     │     │       │       │
  │────→│     │       │       │   POST /resource
  │     │────→│       │       │   Validate token
  │     │←────│       │       │   Token valid
  │     │─────────────→│       │   Create resource
  │     │              │──────→│   INSERT
  │     │              │←──────│   OK
  │←────│              │       │   201 Created
```

Include: all participating components, request/response pairs, error paths, async operations noted.

## API Contract Table

Structured format for defining interfaces.

```
| Endpoint        | Method | Input              | Output           | Errors           |
|-----------------|--------|--------------------|------------------|------------------|
| /api/users      | POST   | {name, email}      | {id, name, email}| 400, 409, 500    |
| /api/users/:id  | GET    | id (path param)    | {id, name, email}| 404, 500         |
| /api/users/:id  | DELETE | id (path param)    | 204 No Content   | 404, 403, 500    |
```

Include: all endpoints/functions, HTTP method or call type, input parameters with types, output shape, all possible error states.

## When to Use Each

| Diagram | Use When |
|---------|----------|
| System Context | Starting a new project — show the big picture first |
| Component | Defining internal structure and boundaries |
| Data Flow | Complex data transformations or multi-step pipelines |
| Entity Relationship | Designing database schema or data models |
| Sequence | Multi-component workflows with specific ordering |
| API Contract | Defining interfaces between components or services |

Start with System Context, then Component, then detail from there. Not every project needs all diagram types — use what clarifies the design.
