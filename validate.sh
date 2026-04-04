#!/usr/bin/env bash
# validate.sh — validates the portable Claude Code agent system
# Usage: ./validate.sh [--fix]
# Exit 0 if all checks pass, 1 if any fail.
# Compatible with bash 3 (macOS default).

set -uo pipefail

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENTS_DIR="$REPO_DIR/agents"
SKILLS_DIR="$REPO_DIR/skills"
AGENT_MEMORY_DIR="$REPO_DIR/agent-memory"
PLUGINS_JSON="$REPO_DIR/plugins/plugins.json"
CLAUDE_MD="$REPO_DIR/CLAUDE.md"
MAX_LINES=200
FIX_MODE=false

# ---------------------------------------------------------------------------
# Argument parsing
# ---------------------------------------------------------------------------
for arg in "$@"; do
  case "$arg" in
    --fix) FIX_MODE=true ;;
    --help|-h)
      echo "Usage: $(basename "$0") [--fix]"
      echo ""
      echo "Validates the Claude Code agent system repo structure."
      echo ""
      echo "Options:"
      echo "  --fix    Auto-create missing agent-memory directories"
      exit 0
      ;;
    *)
      echo "Unknown argument: $arg" >&2
      echo "Run with --help for usage." >&2
      exit 1
      ;;
  esac
done

# ---------------------------------------------------------------------------
# Counters (bash 3 compatible — no declare -i or (( )) with set -e)
# ---------------------------------------------------------------------------
PASS=0
FAIL=0

pass() {
  echo "  [+] $1"
  PASS=$((PASS + 1))
}

fail() {
  echo "  [X] $1"
  FAIL=$((FAIL + 1))
}

section() {
  echo ""
  echo "==> $1"
}

# ---------------------------------------------------------------------------
# Check 1: Every agent in CLAUDE.md dispatch table has a file in agents/
# ---------------------------------------------------------------------------
section "Dispatch table -> agents/ file coverage"

# Extract agent names from dispatch table rows that mention "agent"
# Table rows look like: | situation | `agent-name` agent ... |
# or the multi-agent security line: `x-reviewer`, `y-reviewer`, ...
while IFS= read -r agent; do
  agent_file="$AGENTS_DIR/${agent}.md"
  if [ -f "$agent_file" ]; then
    pass "Dispatch agent '$agent' -> agents/${agent}.md exists"
  else
    fail "Dispatch agent '$agent' -> agents/${agent}.md MISSING"
  fi
done < <(
  # Extract names followed immediately by " agent" (not " skill") in dispatch table rows.
  # Handles: `name` agent, `name` agent (Opus), and comma-separated multi-agent lines.
  grep -E '^\|' "$CLAUDE_MD" \
  | grep -oE '`[a-z][a-z0-9-]+`[[:space:]]+agent' \
  | grep -oE '`[a-z][a-z0-9-]+`' \
  | tr -d '`' \
  | sort -u
)

# ---------------------------------------------------------------------------
# Check 2: Every skill directory has a SKILL.md
# ---------------------------------------------------------------------------
section "Skill directories have SKILL.md"

for skill_dir in "$SKILLS_DIR"/*/; do
  [ -d "$skill_dir" ] || continue
  skill_name="$(basename "$skill_dir")"
  if [ -f "$skill_dir/SKILL.md" ]; then
    pass "Skill '$skill_name' has SKILL.md"
  else
    fail "Skill '$skill_name' is missing SKILL.md"
  fi
done

# ---------------------------------------------------------------------------
# Check 3: All SKILL.md files are under MAX_LINES lines
# ---------------------------------------------------------------------------
section "SKILL.md files under $MAX_LINES lines"

while IFS= read -r skill_md; do
  line_count=$(wc -l < "$skill_md")
  # strip leading spaces from wc -l output
  line_count="${line_count// /}"
  skill_rel="${skill_md#$REPO_DIR/}"
  if [ "$line_count" -le "$MAX_LINES" ]; then
    pass "$skill_rel ($line_count lines)"
  else
    fail "$skill_rel ($line_count lines -- exceeds $MAX_LINES)"
  fi
done < <(find "$SKILLS_DIR" -name "SKILL.md")

# ---------------------------------------------------------------------------
# Check 4: All agent .md files are under MAX_LINES lines
# ---------------------------------------------------------------------------
section "Agent .md files under $MAX_LINES lines"

while IFS= read -r agent_file; do
  line_count=$(wc -l < "$agent_file")
  line_count="${line_count// /}"
  agent_rel="${agent_file#$REPO_DIR/}"
  if [ "$line_count" -le "$MAX_LINES" ]; then
    pass "$agent_rel ($line_count lines)"
  else
    fail "$agent_rel ($line_count lines -- exceeds $MAX_LINES)"
  fi
done < <(find "$AGENTS_DIR" -name "*.md")

# ---------------------------------------------------------------------------
# Check 5: All reference files (skills/*/references/*.md) under MAX_LINES
# ---------------------------------------------------------------------------
section "Reference files under $MAX_LINES lines"

ref_count=0
while IFS= read -r ref_file; do
  ref_count=$((ref_count + 1))
  line_count=$(wc -l < "$ref_file")
  line_count="${line_count// /}"
  ref_rel="${ref_file#$REPO_DIR/}"
  if [ "$line_count" -le "$MAX_LINES" ]; then
    pass "$ref_rel ($line_count lines)"
  else
    fail "$ref_rel ($line_count lines -- exceeds $MAX_LINES)"
  fi
done < <(find "$SKILLS_DIR" -path "*/references/*.md")

if [ "$ref_count" -eq 0 ]; then
  pass "No reference files found (nothing to check)"
fi

# ---------------------------------------------------------------------------
# Check 6: plugins/plugins.json is valid JSON
# ---------------------------------------------------------------------------
section "plugins/plugins.json is valid JSON"

if [ ! -f "$PLUGINS_JSON" ]; then
  fail "plugins/plugins.json does not exist"
else
  err_msg=$(python3 -c "import json, sys; json.load(open(sys.argv[1]))" "$PLUGINS_JSON" 2>&1)
  if [ $? -eq 0 ]; then
    pass "plugins/plugins.json is valid JSON"
  else
    fail "plugins/plugins.json is invalid JSON: $err_msg"
  fi
fi

# ---------------------------------------------------------------------------
# Check 7: No broken skill cross-references in agent files
# Parses the frontmatter `skills:` list from each agent .md file
# ---------------------------------------------------------------------------
section "Agent skill references resolve to existing skill directories"

check_agent_skills() {
  local agent_file="$1"
  local agent_rel="${agent_file#$REPO_DIR/}"
  local in_skills=0
  local in_frontmatter=0
  local frontmatter_count=0

  while IFS= read -r line; do
    # Track frontmatter delimiters
    if [ "$line" = "---" ]; then
      frontmatter_count=$((frontmatter_count + 1))
      if [ "$frontmatter_count" -ge 2 ]; then
        # End of frontmatter
        break
      fi
      in_frontmatter=1
      continue
    fi

    [ "$in_frontmatter" -eq 0 ] && continue

    if echo "$line" | grep -qE '^skills:'; then
      in_skills=1
      continue
    fi

    # A new top-level key resets the skills block
    if [ "$in_skills" -eq 1 ] && echo "$line" | grep -qE '^[a-z]'; then
      in_skills=0
      continue
    fi

    if [ "$in_skills" -eq 1 ]; then
      # Extract skill name from `  - skill-name` lines
      skill_ref=$(echo "$line" | sed 's/^[[:space:]]*-[[:space:]]*//' | tr -d '[:space:]')
      if [ -n "$skill_ref" ]; then
        if [ -d "$SKILLS_DIR/$skill_ref" ]; then
          pass "$agent_rel references skill '$skill_ref' -- exists"
        else
          fail "$agent_rel references skill '$skill_ref' -- NOT FOUND in skills/"
        fi
      fi
    fi
  done < "$agent_file"
}

while IFS= read -r agent_file; do
  check_agent_skills "$agent_file"
done < <(find "$AGENTS_DIR" -name "*.md")

# ---------------------------------------------------------------------------
# Check 8: Every agent in agents/ has an agent-memory/ directory
# ---------------------------------------------------------------------------
section "Every agent has a corresponding agent-memory/ directory"

while IFS= read -r agent_file; do
  agent_name="$(basename "$agent_file" .md)"
  memory_dir="$AGENT_MEMORY_DIR/$agent_name"
  if [ -d "$memory_dir" ]; then
    pass "agent-memory/$agent_name/ exists"
  else
    if $FIX_MODE; then
      mkdir -p "$memory_dir"
      echo "  [+] FIXED: created agent-memory/$agent_name/"
      PASS=$((PASS + 1))
    else
      fail "agent-memory/$agent_name/ MISSING (run --fix to create)"
    fi
  fi
done < <(find "$AGENTS_DIR" -name "*.md")

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
echo ""
echo "=================================================="
TOTAL=$((PASS + FAIL))
echo "Results: $PASS/$TOTAL checks passed"
if [ "$FAIL" -gt 0 ]; then
  echo "FAIL: $FAIL issue(s) found"
  echo "=================================================="
  exit 1
else
  echo "PASS: All checks passed"
  echo "=================================================="
  exit 0
fi
