#!/usr/bin/env bash
# Tests for gh-account-guard PreToolUse hook.
# Verifies the genericized config-driven behavior: env var, config file,
# no-op when neither is set, and remote-owner matching.
#
# Exit 0 if all assertions pass, 1 otherwise.

set -uo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
HOOKS_DIR="$REPO_DIR/scripts/hooks"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

PASS=0
FAIL=0

assert_exit() {
  local label="$1" expected_code="$2" actual_code="$3"
  if [ "$expected_code" = "$actual_code" ]; then
    echo "PASS: $label"
    PASS=$((PASS+1))
  else
    echo "FAIL: $label"
    echo "  expected exit=$expected_code, got exit=$actual_code"
    FAIL=$((FAIL+1))
  fi
}

# Test setup: build a synthetic git repo with a remote, then drive the hook
# with synthetic stdin while overriding the config file path via env var.
GUARD_REPO="$TMP/guardrepo"
mkdir -p "$GUARD_REPO"
(
  cd "$GUARD_REPO"
  git init -q
  git config user.email t@t
  git config user.name t
  git remote add origin https://github.com/example-owner/example-repo.git
  git checkout -q -b feat/x 2>/dev/null || git checkout -q feat/x
  echo a > a.txt && git add a.txt && git commit -q -m a
)

# Test: no config file -> hook is no-op (allow), exit 0
GH_ACCOUNT_GUARD_CONFIG="$TMP/nonexistent.conf" GH_ACCOUNT_GUARD_USER="" \
  bash -c "cd '$GUARD_REPO' && echo '{\"tool_input\":{\"command\":\"git push origin feat/x\"}}' | bash '$HOOKS_DIR/gh-account-guard.sh'" >/dev/null 2>&1
assert_exit "gh-account-guard: no config + no env -> allow" 0 $?

# Test: env var set, push to a non-matching owner -> allow (different owner)
GH_ACCOUNT_GUARD_CONFIG="$TMP/nonexistent.conf" GH_ACCOUNT_GUARD_USER="some-other-user" \
  bash -c "cd '$GUARD_REPO' && echo '{\"tool_input\":{\"command\":\"git push origin feat/x\"}}' | bash '$HOOKS_DIR/gh-account-guard.sh'" >/dev/null 2>&1
assert_exit "gh-account-guard: env user != remote owner -> allow" 0 $?

# Test: config file present with USERNAME matching remote owner; gh active is different -> block (exit 2)
# We can only assert this if `gh api user` returns a value AND it's not 'example-owner'.
# Skip if gh is unauthed (active is empty -> hook exits 0).
echo 'USERNAME=example-owner' > "$TMP/match.conf"
ACTIVE_USER=$(gh api user --jq .login 2>/dev/null || echo "")
if [ -n "$ACTIVE_USER" ] && [ "$(echo $ACTIVE_USER | tr '[:upper:]' '[:lower:]')" != "example-owner" ]; then
  GH_ACCOUNT_GUARD_CONFIG="$TMP/match.conf" \
    bash -c "cd '$GUARD_REPO' && echo '{\"tool_input\":{\"command\":\"git push origin feat/x\"}}' | bash '$HOOKS_DIR/gh-account-guard.sh'" >/dev/null 2>&1
  assert_exit "gh-account-guard: config matches remote owner, active user differs -> block" 2 $?
else
  echo "SKIP: gh-account-guard block test (gh unauthed or active user == example-owner)"
fi

# Test: config file present with USERNAME, push to non-matching owner -> allow
GH_ACCOUNT_GUARD_CONFIG="$TMP/match.conf" \
  bash -c "cd '$GUARD_REPO' && git remote set-url origin https://github.com/other-owner/repo.git && echo '{\"tool_input\":{\"command\":\"git push origin feat/x\"}}' | bash '$HOOKS_DIR/gh-account-guard.sh'" >/dev/null 2>&1
assert_exit "gh-account-guard: config user differs from remote owner -> allow" 0 $?

echo ""
echo "Results: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
