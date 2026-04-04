Build a REST API for managing bookmarks using Express and better-sqlite3.

The API should expose a single `/api/bookmarks` resource with full CRUD:
- `GET /api/bookmarks` — list all bookmarks
- `GET /api/bookmarks/:id` — get a single bookmark
- `POST /api/bookmarks` — create a bookmark (requires `url` and `title`)
- `PUT /api/bookmarks/:id` — update a bookmark
- `DELETE /api/bookmarks/:id` — delete a bookmark

Requirements:
- Validate that `url` is a valid URL and `title` is non-empty on create/update
- Return 400 with a descriptive error body for invalid input
- Return 404 when a bookmark is not found
- Use better-sqlite3 for persistence — schema should be created on startup if it doesn't exist
- Include tests using a test database (not the production db file)
- Write tests first
