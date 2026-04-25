#!/usr/bin/env bash
# PostToolUse hook for Edit|Write — runs ruff on Python files after edits.
# Surfaces ruff findings to Claude via hookSpecificOutput.additionalContext JSON.
# Plain stdout is unreliable on this Claude Code build; the JSON channel is.
# Never blocks (exit 0 always).

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('tool_input',{}).get('file_path',''))" 2>/dev/null)

case "$FILE_PATH" in
  *.py) ;;
  *) exit 0 ;;
esac

if ! command -v ruff &>/dev/null; then
  exit 0
fi

OUTPUT=$(ruff check "$FILE_PATH" 2>&1)
if [ $? -eq 0 ]; then
  exit 0
fi

ADDITIONAL_CONTEXT="ruff found issues in $FILE_PATH:
$OUTPUT" python3 -c "
import json, os
print(json.dumps({
    'hookSpecificOutput': {
        'hookEventName': 'PostToolUse',
        'additionalContext': os.environ['ADDITIONAL_CONTEXT'],
    }
}))
"
exit 0
