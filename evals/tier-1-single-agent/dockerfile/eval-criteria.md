# Eval Criteria: Dockerfile

## 1. Dispatch Correctness

- [ ] `devops-engineer` agent was dispatched (primary — owns Docker, CI/CD, and infrastructure)
- [ ] No other agent unnecessarily involved for this scope of work

**Fail condition:** Main thread wrote the Dockerfile without dispatching `devops-engineer`. Backend agent dispatched instead of devops.

---

## 2. TDD Compliance

Note: Dockerfile tasks are primarily infrastructure, not logic-heavy code. TDD applies in a modified form — verification steps replace unit tests.

- [ ] The build command was run and confirmed working before declaring done
- [ ] The container was started and `/health` was probed to verify the app responds
- [ ] Any failure during build or run was diagnosed and fixed, not glossed over
- [ ] If shell scripts or entrypoint scripts were written, those have tests or are verified to run correctly

**Partial credit:** Providing a `docker-compose.yml` or `Makefile` with a `test` target that validates the container counts as structured verification.

**Fail condition:** Dockerfile written but never built or run. Agent claims it "should work" without running it.

---

## 3. Output Quality

- [ ] Multi-stage build: at least two `FROM` stages present
- [ ] Final stage based on a slim/alpine image (not the full build image)
- [ ] Non-root user created and `USER` directive set in the final stage
- [ ] `HEALTHCHECK` instruction present with appropriate interval and start-period
- [ ] `requirements.txt` is present and includes Flask (pinned version preferred)
- [ ] Flask app file is present with a `/health` endpoint returning `{"status": "ok"}`
- [ ] `docker build -t flask-health .` completes successfully
- [ ] `curl http://localhost:5000/health` returns `{"status": "ok"}` with HTTP 200
- [ ] `docker inspect flask-health` shows `User` is not root (not `""` or `"root"`)

**Fail condition:** Single-stage build. App runs as root. No HEALTHCHECK. Build fails. `/health` returns non-200 or wrong body.

---

## 4. Agent-Specific Rules (devops-engineer)

- [ ] Build artifacts and dev dependencies do not appear in the final image
- [ ] `COPY` is scoped — only necessary files copied, not the entire context
- [ ] `.dockerignore` included or noted to exclude `__pycache__`, `.env`, etc.
- [ ] Port exposed via `EXPOSE` instruction
- [ ] No hardcoded secrets or environment values baked into the image — use `ENV` with defaults or expect runtime injection
- [ ] Layer caching respected: `requirements.txt` copied and installed before application code is copied

**Fail condition:** `requirements.txt` copied after app code (breaks layer caching). Dev tools like pip or gcc present in final image. Entire project directory copied with no `.dockerignore`.

---

## Scoring

| Category | Weight | Pass |
|---|---|---|
| Dispatch correctness | 25% | devops-engineer dispatched |
| TDD compliance | 20% | Build and run verified, not just written |
| Output quality | 35% | Multi-stage, non-root, healthcheck, builds and runs |
| Agent-specific rules | 20% | Layer caching, .dockerignore, no baked secrets |

**Overall pass threshold: 80%**
