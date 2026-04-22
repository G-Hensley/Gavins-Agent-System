#!/usr/bin/env bash
# PreToolUse hook for Bash — blocks `git push` when pushing to a G-Hensley-
# owned remote while the active GH account is not G-Hensley. Prevents the
# wrong-account push failure mode called out in CLAUDE.md Git Workflow.
#
# Exits:
#   0 = allow
#   2 = block with message
set -uo pipefail

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('tool_input',{}).get('command',''))" 2>/dev/null || echo "")

# Only gate git push commands
case "$COMMAND" in
  *"git push"*) ;;
  *) exit 0 ;;
esac

# Determine the effective push remote. Priority:
#   1. Explicit remote in the push command: `git push <remote> ...`
#   2. branch.<current>.pushRemote (push-specific override)
#   3. branch.<current>.remote (upstream)
#   4. remote.pushDefault
#   5. origin (last resort)
PUSH_REMOTE=""
# shellcheck disable=SC2206
args=($COMMAND)
seen_push=0
for word in "${args[@]}"; do
  if [ "$seen_push" = "1" ]; then
    case "$word" in
      -*) continue ;;                 # skip flags like -u, --force
      *) PUSH_REMOTE="$word"; break ;;
    esac
  fi
  [ "$word" = "push" ] && seen_push=1
done

if [ -z "$PUSH_REMOTE" ]; then
  BRANCH=$(git symbolic-ref --short HEAD 2>/dev/null || echo "")
  if [ -n "$BRANCH" ]; then
    PUSH_REMOTE=$(git config --get "branch.$BRANCH.pushRemote" 2>/dev/null || echo "")
    [ -z "$PUSH_REMOTE" ] && PUSH_REMOTE=$(git config --get "branch.$BRANCH.remote" 2>/dev/null || echo "")
  fi
  [ -z "$PUSH_REMOTE" ] && PUSH_REMOTE=$(git config --get remote.pushDefault 2>/dev/null || echo "")
  [ -z "$PUSH_REMOTE" ] && PUSH_REMOTE="origin"
fi

REMOTE_URL=$(git remote get-url "$PUSH_REMOTE" 2>/dev/null || echo "")
if [ -z "$REMOTE_URL" ]; then
  exit 0
fi
REMOTE_OWNER=$(echo "$REMOTE_URL" | sed -E 's|.*[:/]([^/]+)/[^/]+(\.git)?$|\1|')

# Only enforce for G-Hensley repos — other owners (APIsec, Tampertantrum, etc.)
# might legitimately use a different active account.
if [ "$REMOTE_OWNER" != "G-Hensley" ]; then
  exit 0
fi

# Resolve active account via `gh api user`. If gh isn't authed or is offline,
# don't block — let the push fail naturally rather than blocking on a
# transient auth check.
ACTIVE=$(gh api user --jq .login 2>/dev/null || echo "")
if [ -z "$ACTIVE" ]; then
  exit 0
fi

if [ "$ACTIVE" != "G-Hensley" ]; then
  echo "BLOCKED: git push to $REMOTE_OWNER/... but active GH account is '$ACTIVE'." >&2
  echo "Run: gh auth switch --user G-Hensley" >&2
  echo "Then re-run your push." >&2
  exit 2
fi

exit 0
