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

# -----------------------------------------------------------------
# pr-push-nudge tests
# -----------------------------------------------------------------

# gh pr create -> JSON (no external gh call needed for this path)
out=$(echo '{"tool_input":{"command":"gh pr create --title x --body y"},"tool_result":{"exit_code":0}}' | bash "$HOOKS_DIR/pr-push-nudge.sh")
assert_json_with_context "pr-push-nudge: gh pr create emits JSON additionalContext" "$out" "/pr-check"

# Unrelated command -> empty stdout
out=$(echo '{"tool_input":{"command":"ls"},"tool_result":{"exit_code":0}}' | bash "$HOOKS_DIR/pr-push-nudge.sh")
assert_empty "pr-push-nudge: unrelated command emits no stdout" "$out"

# Failed gh pr create -> empty stdout
out=$(echo '{"tool_input":{"command":"gh pr create --title x"},"tool_result":{"exit_code":1}}' | bash "$HOOKS_DIR/pr-push-nudge.sh")
assert_empty "pr-push-nudge: failed gh pr create emits no stdout" "$out"

# -----------------------------------------------------------------
# file-size-cap tests
# -----------------------------------------------------------------

# Synthesize a large .py file (>200 lines) -> JSON
LARGE_PY="$TMP/large.py"
yes 'pass' | head -250 > "$LARGE_PY"
out=$(echo "{\"tool_input\":{\"file_path\":\"$LARGE_PY\"},\"tool_result\":{\"exit_code\":0}}" | bash "$HOOKS_DIR/file-size-cap.sh")
assert_json_with_context "file-size-cap: 250-line .py emits JSON additionalContext" "$out" "lines"

# Small .py file -> empty stdout
SMALL_PY="$TMP/small.py"
echo "x = 1" > "$SMALL_PY"
out=$(echo "{\"tool_input\":{\"file_path\":\"$SMALL_PY\"},\"tool_result\":{\"exit_code\":0}}" | bash "$HOOKS_DIR/file-size-cap.sh")
assert_empty "file-size-cap: small .py emits no stdout" "$out"

# Large .md outside skills/agents/rules/commands -> empty stdout
LARGE_MD="$TMP/large.md"
yes 'line' | head -250 > "$LARGE_MD"
out=$(echo "{\"tool_input\":{\"file_path\":\"$LARGE_MD\"},\"tool_result\":{\"exit_code\":0}}" | bash "$HOOKS_DIR/file-size-cap.sh")
assert_empty "file-size-cap: large .md outside scoped dirs emits no stdout" "$out"

# -----------------------------------------------------------------
# verify-tests tests
# -----------------------------------------------------------------

# Failing pytest -> JSON
out=$(echo '{"tool_input":{"command":"uv run pytest"},"tool_result":{"exit_code":1}}' | bash "$HOOKS_DIR/verify-tests.sh")
assert_json_with_context "verify-tests: failing pytest emits JSON additionalContext" "$out" "exited with code 1"

# Passing pytest -> empty stdout
out=$(echo '{"tool_input":{"command":"uv run pytest"},"tool_result":{"exit_code":0}}' | bash "$HOOKS_DIR/verify-tests.sh")
assert_empty "verify-tests: passing pytest emits no stdout" "$out"

# Non-test command -> empty stdout
out=$(echo '{"tool_input":{"command":"ls"},"tool_result":{"exit_code":0}}' | bash "$HOOKS_DIR/verify-tests.sh")
assert_empty "verify-tests: non-test command emits no stdout" "$out"

# Pytest with no exit_code, FAILED in stdout -> JSON
out=$(echo '{"tool_input":{"command":"pytest"},"tool_result":{"stdout":"3 passed, 2 FAILED"}}' | bash "$HOOKS_DIR/verify-tests.sh")
assert_json_with_context "verify-tests: pytest FAILED in stdout (no exit_code) emits JSON additionalContext" "$out" "appears to have failed"

echo ""
echo "Results: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
