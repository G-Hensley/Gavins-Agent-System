#!/usr/bin/env bash
# PostToolUse hook — nudges the user to run /pr-check after any command that
# either creates a PR or pushes to a branch that already has an open PR.
# Fail-open (exit 0 always), never blocks.
set -uo pipefail

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('tool_input',{}).get('command',''))" 2>/dev/null || echo "")

fire=0
case "$COMMAND" in
  *"gh pr create"*)
    fire=1
    ;;
  *"git push"*)
    # Only fire if the current branch has an open PR.
    # gh pr view exits non-zero if no PR exists, which short-circuits correctly.
    if gh pr view --json state -q .state 2>/dev/null | grep -q OPEN; then
      fire=1
    fi
    ;;
esac

if [ "$fire" = "1" ]; then
  echo ""
  echo "PR activity detected. Copilot reviews typically land in ~60-90s."
  echo "Run /pr-check when ready to triage comments, CI status, and merge state."
fi

exit 0
