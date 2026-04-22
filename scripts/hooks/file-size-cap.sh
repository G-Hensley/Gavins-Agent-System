#!/usr/bin/env bash
# PostToolUse hook for Edit|Write — warns when a file exceeds 200 lines.
# Enforces the Code Standards cap from CLAUDE.md. Fail-open (exit 0 always).
#
# Applies to:
#   - .md files under skills/, agents/, rules/, commands/
#   - .py / .ts / .tsx / .rs / .sh production code anywhere
# Excludes:
#   - docs/, coaching/, evals/, node_modules/, .venv/, .git/ (allowed long)
set -uo pipefail

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('tool_input',{}).get('file_path',''))" 2>/dev/null || echo "")

if [ -z "$FILE_PATH" ] || [ ! -f "$FILE_PATH" ]; then
  exit 0
fi

# Skip if the edit itself failed — don't warn on broken state
EXIT_CODE=$(echo "$INPUT" | python3 -c "import sys,json; r=json.load(sys.stdin).get('tool_result',{}); print(r.get('exit_code','') if isinstance(r,dict) else '')" 2>/dev/null || echo "")
if [ -n "$EXIT_CODE" ] && [ "$EXIT_CODE" != "0" ]; then
  exit 0
fi

# Exclude directories explicitly allowed to hold long files
case "$FILE_PATH" in
  */docs/*|*/coaching/*|*/evals/*|*/node_modules/*|*/.venv/*|*/.git/*|*/agent-memory/*)
    exit 0 ;;
esac

# Check extension + path
CHECK=0
case "$FILE_PATH" in
  *.md)
    case "$FILE_PATH" in
      */skills/*|*/agents/*|*/rules/*|*/commands/*) CHECK=1 ;;
    esac
    ;;
  *.py|*.ts|*.tsx|*.rs|*.sh) CHECK=1 ;;
esac

if [ "$CHECK" = "0" ]; then
  exit 0
fi

LINES=$(wc -l < "$FILE_PATH" 2>/dev/null | tr -d ' ')
if [ -z "$LINES" ]; then exit 0; fi

if [ "$LINES" -gt 200 ]; then
  echo ""
  echo "File-size warning: $FILE_PATH is $LINES lines (>200)."
  echo "Per CLAUDE.md Code Standards, SKILL.md / agent / reference files should stay under 200."
  echo "If it's production code, consider whether it's doing too much — refactor into smaller units."
fi

exit 0
