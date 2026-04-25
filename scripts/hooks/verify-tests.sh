#!/usr/bin/env bash
# PostToolUse hook for Bash — warns when a test command exits non-zero
# Reads Claude hook JSON from stdin, extracts .tool_input.command and
# .tool_result.exit_code (or infers failure from .tool_result.stdout/stderr)
# Never blocks (exit 0 always), prints a warning to stdout on failure

set -uo pipefail

INPUT="$(cat)"

COMMAND="$(printf '%s' "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)"

if [[ -z "$COMMAND" ]]; then
  exit 0
fi

# Only act on test commands
if ! printf '%s' "$COMMAND" | grep -qE '\b(pytest|vitest|pnpm\s+test|pnpm\s+run\s+test|jest)\b'; then
  exit 0
fi

EXIT_CODE="$(printf '%s' "$INPUT" | jq -r '.tool_result.exit_code // empty' 2>/dev/null)"

# If exit_code field absent, check for common failure signals in output
if [[ -z "$EXIT_CODE" ]]; then
  STDOUT="$(printf '%s' "$INPUT" | jq -r '.tool_result.stdout // empty' 2>/dev/null)"
  STDERR="$(printf '%s' "$INPUT" | jq -r '.tool_result.stderr // empty' 2>/dev/null)"
  COMBINED="$STDOUT $STDERR"
  if printf '%s' "$COMBINED" | grep -qiE '\bFAILED\b|\bERROR\b|\bfailed\s+[0-9]+\b|[0-9]+\s+failed'; then
    ADDITIONAL_CONTEXT="WARNING: Test command appears to have failed.
  Command: $COMMAND
  Fix failing tests before continuing." python3 -c "
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
fi

if [[ "$EXIT_CODE" != "0" ]]; then
  ADDITIONAL_CONTEXT="WARNING: Test command exited with code $EXIT_CODE.
  Command: $COMMAND
  Fix failing tests before continuing." python3 -c "
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
