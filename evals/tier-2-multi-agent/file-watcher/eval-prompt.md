I need a file watcher script that monitors a directory for changes and automatically triggers a CI pipeline when files are added or modified.

The script should:
- Watch a target directory (passed as an argument) for file creation and modification events
- Debounce rapid successive changes so the pipeline isn't triggered multiple times for a single save
- Log each event with a timestamp — what file changed, what kind of change, and whether the trigger succeeded
- Support a `--dry-run` flag that logs what would happen without actually triggering anything
- Exit cleanly on SIGINT/SIGTERM

The CI integration should use GitHub Actions. When the watcher triggers, it should dispatch a `workflow_dispatch` event to a specified workflow in a specified repository. The repository, workflow file name, and GitHub token should come from environment variables — nothing hardcoded.

Write tests for the debounce logic and the event classification logic before implementing them.

The final deliverable is:
- `watcher.py` — the file watcher script
- `tests/` — pytest tests for the debounce and event classification logic
- `.github/workflows/on-file-change.yml` — the GitHub Actions workflow that gets triggered
- A `.env.example` showing the required environment variables
