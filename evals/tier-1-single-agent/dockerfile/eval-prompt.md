Write a Dockerfile for a Python Flask application.

The Flask app is a simple health-check server — create the minimal app code needed to containerize it. It should expose a single `GET /health` endpoint that returns `{"status": "ok"}`.

Dockerfile requirements:
- Multi-stage build: a build stage and a lean runtime stage
- Non-root user — the app should not run as root inside the container
- Health check instruction so Docker knows when the container is healthy
- Dependencies installed from a `requirements.txt`
- Image should be as small as reasonable — avoid bloating the final stage with build tools

Include a `requirements.txt` and the minimal Flask app code. The image should build and run with:

```
docker build -t flask-health .
docker run -p 5000:5000 flask-health
curl http://localhost:5000/health
```
