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
# Use read -r -a for word-splitting WITHOUT pathname expansion. Plain
# `args=($COMMAND)` would expand any `*` in the command against cwd.
read -r -a args <<<"$COMMAND"
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

# Resolve the URL we'll actually push to. Handle three cases:
#   1. PUSH_REMOTE is a literal URL (`git push https://... main`) — use as-is.
#   2. PUSH_REMOTE is a registered remote with a pushurl override — prefer
#      `git remote get-url --push` so we see the actual push destination.
#   3. PUSH_REMOTE is a registered remote with no pushurl — fall back to
#      the fetch URL.
case "$PUSH_REMOTE" in
  http://*|https://*|git@*|ssh://*|*://*)
    REMOTE_URL="$PUSH_REMOTE"
    ;;
  *)
    REMOTE_URL=$(git remote get-url --push "$PUSH_REMOTE" 2>/dev/null \
                 || git remote get-url "$PUSH_REMOTE" 2>/dev/null \
                 || echo "")
    ;;
esac

if [ -z "$REMOTE_URL" ]; then
  exit 0
fi

# GitHub usernames are case-insensitive; remote URLs and auth logins can use
# either case. Compare everything in lowercase. Keep a display-case version
# for user-facing messages.
TARGET_LOWER="g-hensley"
TARGET_DISPLAY="G-Hensley"

REMOTE_OWNER=$(echo "$REMOTE_URL" | sed -E 's|.*[:/]([^/]+)/[^/]+(\.git)?$|\1|')
REMOTE_OWNER_LOWER=$(echo "$REMOTE_OWNER" | tr '[:upper:]' '[:lower:]')

# Only enforce for G-Hensley repos — other owners (APIsec, Tampertantrum, etc.)
# might legitimately use a different active account.
if [ "$REMOTE_OWNER_LOWER" != "$TARGET_LOWER" ]; then
  exit 0
fi

# Resolve active account via `gh api user`. If gh isn't authed or is offline,
# don't block — let the push fail naturally rather than blocking on a
# transient auth check.
ACTIVE=$(gh api user --jq .login 2>/dev/null || echo "")
if [ -z "$ACTIVE" ]; then
  exit 0
fi
ACTIVE_LOWER=$(echo "$ACTIVE" | tr '[:upper:]' '[:lower:]')

if [ "$ACTIVE_LOWER" != "$TARGET_LOWER" ]; then
  echo "BLOCKED: git push to $REMOTE_OWNER/... but active GH account is '$ACTIVE'." >&2
  echo "Run: gh auth switch --user $TARGET_DISPLAY" >&2
  echo "Then re-run your push." >&2
  exit 2
fi

exit 0
