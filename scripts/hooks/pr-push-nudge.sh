#!/usr/bin/env bash
# PostToolUse hook — nudges the user to run /pr-check after any command that
# either creates a PR or pushes to a branch that already has an open PR.
# Fail-open (exit 0 always), never blocks.
set -uo pipefail

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('tool_input',{}).get('command',''))" 2>/dev/null || echo "")

# Skip if the command itself failed — a failed push or create shouldn't trigger
# a "go run /pr-check" nudge since there's nothing new to check.
EXIT_CODE=$(echo "$INPUT" | python3 -c "import sys,json; r=json.load(sys.stdin).get('tool_result',{}); print(r.get('exit_code','') if isinstance(r,dict) else '')" 2>/dev/null || echo "")
if [ -n "$EXIT_CODE" ] && [ "$EXIT_CODE" != "0" ]; then
  exit 0
fi

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
  ADDITIONAL_CONTEXT="PR activity detected. Copilot reviews typically land in ~60-90s.
Run /pr-check when ready to triage comments, CI status, and merge state." python3 -c "
import json, os
print(json.dumps({
    'hookSpecificOutput': {
        'hookEventName': 'PostToolUse',
        'additionalContext': os.environ['ADDITIONAL_CONTEXT'],
    }
}))
"
fi

exit 0
