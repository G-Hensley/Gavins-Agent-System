#!/usr/bin/env bash
# PostToolUse hook for Bash(git commit*) — checks if docs are drifting behind code.
# Two checks, both fail-open:
#   (1) warn after 3+ commits since any .md file was last modified
#   (2) warn if commit touches structural paths (skills/|agents/|commands/|rules/|scripts/hooks/|config/)
#       and docs/STATUS.md "Last updated:" is >14 days old
# Never blocks (exit 0 always).
set -uo pipefail

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('tool_input',{}).get('command',''))" 2>/dev/null || echo "")

# Only trigger on git commit commands
case "$COMMAND" in
  git\ commit*) ;;
  *) exit 0 ;;
esac

# Skip if the commit itself failed — otherwise we'd report drift against the
# previous commit instead of the attempted one.
EXIT_CODE=$(echo "$INPUT" | python3 -c "import sys,json; r=json.load(sys.stdin).get('tool_result',{}); print(r.get('exit_code','') if isinstance(r,dict) else '')" 2>/dev/null || echo "")
if [ -n "$EXIT_CODE" ] && [ "$EXIT_CODE" != "0" ]; then
  exit 0
fi

WARNINGS=""

# --- Check 1: generic doc drift (3+ commits since last .md change) ---
LAST_DOC_COMMIT=$(git log -1 --format=%H -- '*.md' 2>/dev/null)
if [ -n "$LAST_DOC_COMMIT" ]; then
  COMMITS_SINCE=$(git rev-list --count "$LAST_DOC_COMMIT"..HEAD 2>/dev/null || echo "0")
  if [ "$COMMITS_SINCE" -ge 3 ]; then
    CHANGED_FILES=$(git diff --name-only "$LAST_DOC_COMMIT"..HEAD 2>/dev/null | grep -v '\.md$' | head -10)
    if [ -n "$CHANGED_FILES" ]; then
      WARNINGS+="Doc drift warning: $COMMITS_SINCE commits since docs were last updated."$'\n'
      WARNINGS+="Changed files since last doc update:"$'\n'
      WARNINGS+=$(echo "$CHANGED_FILES" | sed 's/^/  /')$'\n\n'
      WARNINGS+="Consider running /doc-sync to check for stale documentation."$'\n'
    fi
  fi
fi

# --- Check 2: STATUS.md staleness on structural commits ---
if [ -f docs/STATUS.md ]; then
  STRUCTURAL_HIT=$(git log -1 --name-only --pretty= HEAD 2>/dev/null \
    | grep -E '^(skills|agents|commands|rules|scripts/hooks|config)/' | head -5)
  if [ -n "$STRUCTURAL_HIT" ]; then
    STATUS_DATE=$(grep -m 1 '^Last updated:' docs/STATUS.md 2>/dev/null | awk '{print $NF}')
    if [ -n "$STATUS_DATE" ]; then
      DAYS_OLD=$(python3 -c "
import datetime, sys
try:
    d = datetime.datetime.strptime('$STATUS_DATE', '%Y-%m-%d').date()
    print((datetime.date.today() - d).days)
except Exception:
    sys.exit(1)
" 2>/dev/null)
      case "$DAYS_OLD" in
        ''|*[!0-9]*) ;;
        *)
          if [ "$DAYS_OLD" -gt 14 ]; then
            [ -n "$WARNINGS" ] && WARNINGS+=$'\n'
            WARNINGS+="STATUS.md drift warning: structural change committed but docs/STATUS.md is $DAYS_OLD days old (Last updated: $STATUS_DATE)."$'\n'
            WARNINGS+="Structural paths in this commit:"$'\n'
            WARNINGS+=$(echo "$STRUCTURAL_HIT" | sed 's/^/  /')$'\n\n'
            WARNINGS+="Fix: bump 'Last updated:' and add an Improvements Roadmap row. Run /doc-sync for full drift check."$'\n'
          fi
          ;;
      esac
    fi
  fi
fi

if [ -n "$WARNINGS" ]; then
  ADDITIONAL_CONTEXT="$WARNINGS" python3 -c "
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
