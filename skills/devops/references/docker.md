# Docker Patterns

## Dockerfile Best Practices
```dockerfile
# Multi-stage build
FROM node:20-alpine AS builder
WORKDIR /app
COPY package.json pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile
COPY . .
RUN pnpm build

FROM node:20-alpine AS runtime
WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
USER node
EXPOSE 3000
CMD ["node", "dist/server.js"]
```

Key principles:
- Multi-stage builds — small production images
- Pin base image versions (not `latest`)
- Copy lock files first for better layer caching
- Run as non-root user (`USER node`)
- Use `.dockerignore` to exclude node_modules, .git, .env

## Image Security
- Use minimal base images (alpine, distroless)
- Don't install dev dependencies in production image
- Don't copy secrets into images — use runtime env vars
- Scan images for vulnerabilities: `docker scout`, `trivy`

## Docker Compose (Development)
```yaml
services:
  app:
    build: .
    ports: ["3000:3000"]
    environment:
      - DATABASE_URL=postgres://...
    depends_on:
      db: { condition: service_healthy }
  db:
    image: postgres:16-alpine
    healthcheck:
      test: ["CMD-SHELL", "pg_isready"]
```

## Python Images
```dockerfile
FROM python:3.11-slim AS base
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
USER nobody
CMD ["python", "-m", "src.main"]
```
