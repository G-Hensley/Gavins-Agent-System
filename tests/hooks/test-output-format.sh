#!/usr/bin/env bash
# Tests that PostToolUse hooks emit JSON with hookSpecificOutput.additionalContext
# rather than plain stdout — the only reliable channel for hook output to reach
# Claude on this Claude Code build.
#
# Exit 0 if all assertions pass, 1 otherwise.

set -uo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
HOOKS_DIR="$REPO_DIR/scripts/hooks"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

PASS=0
FAIL=0

assert_json_with_context() {
  local label="$1" output="$2" must_contain="$3"
  local hookEvent ctx
  hookEvent=$(echo "$output" | python3 -c "import sys,json
try:
    d = json.load(sys.stdin)
    print(d.get('hookSpecificOutput',{}).get('hookEventName',''))
except Exception:
    print('')" 2>/dev/null)
  ctx=$(echo "$output" | python3 -c "import sys,json
try:
    d = json.load(sys.stdin)
    print(d.get('hookSpecificOutput',{}).get('additionalContext',''))
except Exception:
    print('')" 2>/dev/null)
  if [ "$hookEvent" = "PostToolUse" ] && echo "$ctx" | grep -q "$must_contain"; then
    echo "PASS: $label"
    PASS=$((PASS+1))
  else
    echo "FAIL: $label"
    echo "  expected: hookEventName=PostToolUse, additionalContext containing '$must_contain'"
    echo "  got hookEventName=$hookEvent"
    echo "  got additionalContext=$ctx"
    FAIL=$((FAIL+1))
  fi
}

assert_empty() {
  local label="$1" output="$2"
  if [ -z "$output" ]; then
    echo "PASS: $label"
    PASS=$((PASS+1))
  else
    echo "FAIL: $label"
    echo "  expected empty stdout"
    echo "  got: $output"
    FAIL=$((FAIL+1))
  fi
}

# -----------------------------------------------------------------
# lint-on-save tests
# -----------------------------------------------------------------

# Test 1: Python file with lint errors -> JSON with additionalContext containing F401
cat > "$TMP/dirty.py" <<'PY'
import os
import sys

x = 1
PY
out=$(echo "{\"tool_input\":{\"file_path\":\"$TMP/dirty.py\"}}" | bash "$HOOKS_DIR/lint-on-save.sh")
assert_json_with_context "lint-on-save: dirty .py emits JSON additionalContext with F401" "$out" "F401"

# Test 2: clean Python file -> empty stdout
cat > "$TMP/clean.py" <<'PY'
x = 1
print(x)
PY
out=$(echo "{\"tool_input\":{\"file_path\":\"$TMP/clean.py\"}}" | bash "$HOOKS_DIR/lint-on-save.sh")
assert_empty "lint-on-save: clean .py emits no stdout" "$out"

# Test 3: non-Python file -> empty stdout
cat > "$TMP/notpython.md" <<'MD'
# Just some markdown
MD
out=$(echo "{\"tool_input\":{\"file_path\":\"$TMP/notpython.md\"}}" | bash "$HOOKS_DIR/lint-on-save.sh")
assert_empty "lint-on-save: non-.py emits no stdout" "$out"

# -----------------------------------------------------------------
# doc-drift-check tests
# -----------------------------------------------------------------

# Build a synthetic git repo where check 1 fires (3+ commits since last .md)
GIT_REPO="$TMP/repo"
mkdir -p "$GIT_REPO"
(
  cd "$GIT_REPO"
  git init -q
  git config user.email t@t
  git config user.name t
  echo a > README.md && git add README.md && git commit -q -m "doc"
  for i in 1 2 3 4; do
    echo "$i" > "code$i.txt" && git add "code$i.txt" && git commit -q -m "code $i"
  done
)
out=$(cd "$GIT_REPO" && echo '{"tool_input":{"command":"git commit -m next"},"tool_result":{"exit_code":0}}' | bash "$HOOKS_DIR/doc-drift-check.sh")
assert_json_with_context "doc-drift-check: 3+ commits since .md emits JSON additionalContext" "$out" "drift"

# Non-commit command -> empty stdout
out=$(cd "$GIT_REPO" && echo '{"tool_input":{"command":"git status"},"tool_result":{"exit_code":0}}' | bash "$HOOKS_DIR/doc-drift-check.sh")
assert_empty "doc-drift-check: non-commit command emits no stdout" "$out"

# Failed commit -> empty stdout
out=$(cd "$GIT_REPO" && echo '{"tool_input":{"command":"git commit -m next"},"tool_result":{"exit_code":1}}' | bash "$HOOKS_DIR/doc-drift-check.sh")
assert_empty "doc-drift-check: failed commit emits no stdout" "$out"

echo ""
echo "Results: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
