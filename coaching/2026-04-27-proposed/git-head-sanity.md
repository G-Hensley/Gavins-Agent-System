# Proposed: git-head-sanity (PreToolUse hook)

Auto-detects `.git/HEAD` corruption — the same NUL-padded truncation pattern observed in `gavins-agent-system` (twice in 8 days) and now in `cockpit` (once). Runs before every `Bash(git *)` invocation, fail-warns (exit 0) so it never blocks investigation.

## Why this beats the current setup

`skills/git-health-check/SKILL.md` exists and contains the diagnostic logic, but it requires manual invocation via `/git-health-check`. The recurrence pattern shows that "user notices" lags real corruption by ~5 days. A PreToolUse hook closes that gap to one tool call.

## Files to add

### `scripts/hooks/git-head-sanity.sh` (new)

```bash
#!/usr/bin/env bash
# PreToolUse hook — sanity-check .git/HEAD before any git command.
# Detects the NUL-padded HEAD truncation observed 2026-04-19, 2026-04-26 (gavins-agent-system),
# and 2026-04-26 (cockpit) — all correlated with `.git/gk/` (GitKraken).
#
# Fail-warn only (exit 0, message to stderr). Never blocks — a broken HEAD
# shouldn't stop the user from running `git status` to investigate.
set -uo pipefail

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('tool_input',{}).get('command',''))" 2>/dev/null || echo "")

# Only act on commands that look like git operations.
case "$COMMAND" in
  *"git "*|*"git"|"git "*) ;;
  *) exit 0 ;;
esac

# Find the git repo root for the cwd of the upcoming command. We can't easily
# extract cwd from the hook input on all platforms, so trust $PWD as set by
# Claude Code and walk up to find .git/.
find_git_dir() {
  local d="$PWD"
  while [ "$d" != "/" ] && [ "$d" != "" ]; do
    if [ -d "$d/.git" ] || [ -f "$d/.git" ]; then
      echo "$d/.git"
      return 0
    fi
    d=$(dirname "$d")
  done
  return 1
}

GIT_DIR=$(find_git_dir) || exit 0  # not in a git repo, nothing to check

HEAD_FILE="$GIT_DIR/HEAD"
[ -f "$HEAD_FILE" ] || exit 0       # bare/missing HEAD — let git itself complain

SIZE=$(wc -c < "$HEAD_FILE" | tr -d ' ')
LINE1=$(head -1 "$HEAD_FILE")

# Healthy patterns:
#   "ref: refs/heads/<name>\n"  (size = strlen + 1)
#   "<40-char-hex-sha>\n"       (detached HEAD, size = 41)

# Detect NUL-pad corruption: file size > line1 length + 1.
EXPECTED=$(( ${#LINE1} + 1 ))
if [ "$SIZE" -gt "$EXPECTED" ]; then
  EXTRA=$(( SIZE - EXPECTED ))
  echo "WARN: $HEAD_FILE has $EXTRA trailing junk byte(s) after '$LINE1' (size=$SIZE, expected=$EXPECTED)." >&2
  echo "      This is the NUL-pad corruption pattern correlated with .git/gk/ (GitKraken)." >&2
  echo "      Repair: printf 'ref: refs/heads/<branch>\\n' > '$HEAD_FILE'" >&2
  echo "      Or run: /git-health-check --fix" >&2
fi

# Detect trailing-slash truncation (the 2026-04-19 pattern).
case "$LINE1" in
  "ref: refs/heads/"*"/")
    echo "WARN: $HEAD_FILE is truncated — '$LINE1' has trailing slash with no branch name." >&2
    echo "      Run: /git-health-check --fix" >&2
    ;;
esac

# Detect ref-target-missing.
case "$LINE1" in
  "ref: refs/heads/"*)
    REF_NAME="${LINE1#ref: refs/heads/}"
    REF_FILE="$GIT_DIR/refs/heads/$REF_NAME"
    if [ ! -f "$REF_FILE" ]; then
      # Could be packed — check that too.
      if [ -f "$GIT_DIR/packed-refs" ] && grep -q "refs/heads/$REF_NAME$" "$GIT_DIR/packed-refs"; then
        :  # packed, fine
      else
        echo "WARN: HEAD points to refs/heads/$REF_NAME but no ref file exists and not in packed-refs." >&2
        echo "      Run: /git-health-check --fix" >&2
      fi
    fi
    ;;
esac

exit 0
```

### `config/hooks.json` (edit — add to PreToolUse array)

```json
{
  "matcher": "Bash",
  "hooks": [
    {
      "type": "command",
      "command": "'REPO_DIR/scripts/hooks/git-head-sanity.sh'",
      "timeout": 3
    }
  ]
}
```

Add this entry alongside the existing `Bash` PreToolUse entries (block-destructive, gh-account-guard). The 3s timeout is generous — the script reads one file and runs a few `case` statements.

## Test plan

1. From Git Bash in a clean repo, run any git command — no warning expected.
2. Manually corrupt: `printf 'ref: refs/heads/main\n\0\0\0' > .git/HEAD`. Run `git status`. Expected: hook prints WARN to stderr, then `git` runs and returns its own "broken branch" message. Both fire — neither blocks.
3. Repair: `printf 'ref: refs/heads/main\n' > .git/HEAD`. Run `git status`. Expected: clean output, no hook warning.

## Followup (after this hook lands)

Add a similar check for `.git/ORIG_HEAD` and `.git/REBASE_HEAD` if those keep accumulating NUL-pad corruption (gavins-agent-system has both right now). Lower priority — those don't break operations, just clutter the repo.
