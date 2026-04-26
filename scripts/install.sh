#!/usr/bin/env bash
set -euo pipefail

# Install Gavin's Claude Code Agent System
# Symlinks or copies skills, agents, commands, and config into ~/.claude/

# On Windows (Git Bash / MSYS), force `ln -s` to create real Windows symlinks
# and fail loudly if it can't. Without this, MSYS silently falls back to copying,
# which defeats the whole point of the install (edits don't flow back to the repo).
# Requires Developer Mode enabled, or running shell as Administrator.
export MSYS=winsymlinks:nativestrict
export MSYS2_ARG_CONV_EXCL="*"

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
CLAUDE_DIR="$HOME/.claude"
SETTINGS_FILE="$CLAUDE_DIR/settings.json"

# Translate a POSIX path (/c/Users/...) to a native Windows path (C:\Users\...)
# when running under MSYS/Cygwin. Windows-native Python can't open /c/... paths,
# so any path we pass to `python3 -c` must be converted first. No-op elsewhere.
to_native_path() {
  if command -v cygpath >/dev/null 2>&1; then
    cygpath -w "$1"
  else
    printf '%s' "$1"
  fi
}

REPO_DIR_NATIVE="$(to_native_path "$REPO_DIR")"
SETTINGS_FILE_NATIVE="$(to_native_path "$SETTINGS_FILE")"

DRY_RUN=false
VERIFY=false
CHECK_PREREQS_ONLY=false

# ---------------------------------------------------------------------------
# Flag parsing
# ---------------------------------------------------------------------------
usage() {
  cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Install the Claude Code Agent System by symlinking skills, agents, commands,
and config into ~/.claude/.

Options:
  --dry-run         Show what would be symlinked/copied without making any
                    changes. Each action is prefixed with [DRY RUN].
  --verify          Check that all expected symlinks exist, point to the
                    correct targets, and that those targets actually exist
                    on disk. Exits 0 if everything is intact, 1 if anything
                    is broken.
  --check-prereqs   Probe for required and optional tools used by install.sh
                    and the hooks. Exits 0 if all required tools are present,
                    1 if anything required is missing. Optional tools just
                    print a notice.
  --help            Show this help text and exit.

Default (no flags): runs prereq check, then performs the full install.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    --verify)
      VERIFY=true
      shift
      ;;
    --check-prereqs)
      CHECK_PREREQS_ONLY=true
      shift
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

# ---------------------------------------------------------------------------
# Prerequisite check
# ---------------------------------------------------------------------------
# Required tools: install.sh and the hooks all rely on these.
# Optional tools: hooks degrade silently if missing, but the system is more
# useful with them.
check_prereqs() {
  local missing_required=0
  local missing_optional=0

  echo "Checking prerequisites..."
  echo ""
  echo "Required:"
  for tool in bash python3 git gh jq claude; do
    if command -v "$tool" >/dev/null 2>&1; then
      echo "  [OK]      $tool"
    else
      echo "  [MISSING] $tool"
      missing_required=$((missing_required + 1))
    fi
  done

  echo ""
  echo "Optional (hooks degrade silently if missing):"
  for tool in ruff uv pnpm; do
    if command -v "$tool" >/dev/null 2>&1; then
      echo "  [OK]   $tool"
    else
      echo "  [SKIP] $tool"
      missing_optional=$((missing_optional + 1))
    fi
  done

  echo ""
  if [ "$missing_required" -gt 0 ]; then
    echo "$missing_required required tool(s) missing. Install them before proceeding:"
    echo "  bash, python3, git, gh, jq, claude (Claude Code CLI)"
    return 1
  fi

  if [ "$missing_optional" -gt 0 ]; then
    echo "$missing_optional optional tool(s) missing. Install when convenient:"
    echo "  ruff (uv tool install ruff) — needed by lint-on-save hook"
    echo "  uv  (https://github.com/astral-sh/uv) — referenced by Python skills"
    echo "  pnpm (https://pnpm.io/installation) — referenced by TS skills"
  fi

  return 0
}

if $CHECK_PREREQS_ONLY; then
  check_prereqs
  exit $?
fi

# ---------------------------------------------------------------------------
# Portable directories to sync
# ---------------------------------------------------------------------------
DIRS=(skills agents commands improvements agent-memory rules)

# ---------------------------------------------------------------------------
# --verify mode
# ---------------------------------------------------------------------------
if $VERIFY; then
  echo "Verifying Claude Code Agent System symlinks..."
  echo "  Source: $REPO_DIR"
  echo "  Target: $CLAUDE_DIR"
  echo ""

  ALL_OK=true

  check_symlink() {
    local link="$1"   # path where symlink should exist
    local target="$2" # path the symlink should point to
    local label="$3"  # human-readable name for output

    if [ ! -L "$link" ]; then
      echo "  [MISSING]  $label — no symlink at $link"
      ALL_OK=false
      return
    fi

    actual_target="$(readlink "$link")"
    if [ "$actual_target" != "$target" ]; then
      echo "  [WRONG TARGET]  $label — points to '$actual_target', expected '$target'"
      ALL_OK=false
      return
    fi

    if [ ! -e "$target" ]; then
      echo "  [DEAD LINK]  $label — target '$target' does not exist"
      ALL_OK=false
      return
    fi

    echo "  [OK]  $label"
  }

  for dir in "${DIRS[@]}"; do
    if [ -d "$REPO_DIR/$dir" ]; then
      check_symlink "$CLAUDE_DIR/$dir" "$REPO_DIR/$dir" "$dir"
    fi
  done

  # CLAUDE.md lives at repo root
  if [ -f "$REPO_DIR/CLAUDE.md" ]; then
    check_symlink "$CLAUDE_DIR/CLAUDE.md" "$REPO_DIR/CLAUDE.md" "CLAUDE.md"
  fi

  # settings.local.json lives in config/
  if [ -f "$REPO_DIR/config/settings.local.json" ]; then
    check_symlink "$CLAUDE_DIR/settings.local.json" "$REPO_DIR/config/settings.local.json" "settings.local.json"
  fi

  if [ -f "$REPO_DIR/config/plugins/installed_plugins.json" ]; then
    check_symlink \
      "$CLAUDE_DIR/plugins/installed_plugins.json" \
      "$REPO_DIR/config/plugins/installed_plugins.json" \
      "plugins/installed_plugins.json"
  fi

  echo ""
  if $ALL_OK; then
    echo "All symlinks are intact."
    exit 0
  else
    echo "One or more symlinks are broken or missing." >&2
    exit 1
  fi
fi

# ---------------------------------------------------------------------------
# Preflight: required tools must be present before we touch anything
# ---------------------------------------------------------------------------
if ! check_prereqs; then
  echo ""
  echo "Aborting install — required tools missing." >&2
  exit 1
fi
echo ""

# ---------------------------------------------------------------------------
# Preflight: can we actually create symlinks on this host?
# On Windows without Developer Mode or admin, `ln -s` fails silently and the
# install leaves ~/.claude/ in a half-broken state (backups made, no new links).
# ---------------------------------------------------------------------------
if ! $DRY_RUN; then
  preflight_tmp_target="$(mktemp -u 2>/dev/null || echo "/tmp/preflight-$$")"
  preflight_tmp_link="${preflight_tmp_target}.lnk"
  if ! ln -s "$preflight_tmp_target" "$preflight_tmp_link" 2>/dev/null; then
    echo "" >&2
    echo "ERROR: Cannot create symlinks on this host." >&2
    echo "  On Windows: enable Developer Mode" >&2
    echo "    Settings -> For developers -> Developer Mode -> On" >&2
    echo "  OR re-run this script from an Administrator Git Bash shell." >&2
    echo "" >&2
    echo "Aborting before any files are modified." >&2
    exit 1
  fi
  rm -f "$preflight_tmp_link" 2>/dev/null
fi

# ---------------------------------------------------------------------------
# Install (default) or dry-run
# ---------------------------------------------------------------------------
if $DRY_RUN; then
  echo "[DRY RUN] Claude Code Agent System install (no changes will be made)"
else
  echo "Installing Claude Code Agent System..."
fi
echo "  Source: $REPO_DIR"
echo "  Target: $CLAUDE_DIR"
echo ""

# Helper: run a command or print it in dry-run mode
run() {
  if $DRY_RUN; then
    echo "[DRY RUN] $*"
  else
    "$@"
  fi
}

# Create target if needed
run mkdir -p "$CLAUDE_DIR"

for dir in "${DIRS[@]}"; do
  if [ -d "$REPO_DIR/$dir" ]; then
    if $DRY_RUN; then
      if [ -L "$CLAUDE_DIR/$dir" ]; then
        echo "[DRY RUN] Remove existing symlink: $CLAUDE_DIR/$dir"
      elif [ -d "$CLAUDE_DIR/$dir" ]; then
        echo "[DRY RUN] Backup existing dir: $CLAUDE_DIR/$dir -> $CLAUDE_DIR/$dir.bak"
      fi
      echo "[DRY RUN] Symlink: $CLAUDE_DIR/$dir -> $REPO_DIR/$dir"
    else
      if [ -L "$CLAUDE_DIR/$dir" ]; then
        rm "$CLAUDE_DIR/$dir"
      elif [ -d "$CLAUDE_DIR/$dir" ]; then
        echo "  Backing up existing $dir -> $dir.bak"
        mv "$CLAUDE_DIR/$dir" "$CLAUDE_DIR/$dir.bak"
      fi
      ln -s "$REPO_DIR/$dir" "$CLAUDE_DIR/$dir"
      echo "  Linked: $dir"
    fi
  fi
done

# Config files — symlink individually
# Each entry: "target_name|source_path"
CONFIG_FILES="CLAUDE.md|$REPO_DIR/CLAUDE.md
settings.local.json|$REPO_DIR/config/settings.local.json"

echo "$CONFIG_FILES" | while IFS='|' read -r file src; do
  if [ -f "$src" ]; then
    if $DRY_RUN; then
      if [ -f "$CLAUDE_DIR/$file" ] && [ ! -L "$CLAUDE_DIR/$file" ]; then
        echo "[DRY RUN] Backup existing file: $CLAUDE_DIR/$file -> $CLAUDE_DIR/$file.bak"
      fi
      echo "[DRY RUN] Symlink: $CLAUDE_DIR/$file -> $src"
    else
      if [ -f "$CLAUDE_DIR/$file" ] && [ ! -L "$CLAUDE_DIR/$file" ]; then
        echo "  Backing up existing $file -> $file.bak"
        mv "$CLAUDE_DIR/$file" "$CLAUDE_DIR/$file.bak"
      fi
      ln -sf "$src" "$CLAUDE_DIR/$file"
      echo "  Linked: $file"
    fi
  fi
done

# Plugin config (just the list, not caches)
if $DRY_RUN; then
  echo "[DRY RUN] mkdir -p $CLAUDE_DIR/plugins"
  if [ -f "$REPO_DIR/config/plugins/installed_plugins.json" ]; then
    echo "[DRY RUN] Symlink: $CLAUDE_DIR/plugins/installed_plugins.json -> $REPO_DIR/config/plugins/installed_plugins.json"
  fi
else
  mkdir -p "$CLAUDE_DIR/plugins"
  if [ -f "$REPO_DIR/config/plugins/installed_plugins.json" ]; then
    ln -sf "$REPO_DIR/config/plugins/installed_plugins.json" "$CLAUDE_DIR/plugins/installed_plugins.json"
    echo "  Linked: plugins/installed_plugins.json"
  fi
fi

# settings.json is NOT symlinked — it contains machine-specific permissions
# Copy it as a starting point if none exists
if $DRY_RUN; then
  if [ ! -f "$CLAUDE_DIR/settings.json" ]; then
    echo "[DRY RUN] Copy: $REPO_DIR/config/settings.json -> $CLAUDE_DIR/settings.json (template)"
  else
    echo "[DRY RUN] Skip: settings.json (already exists, contains machine-specific config)"
  fi
else
  if [ ! -f "$CLAUDE_DIR/settings.json" ]; then
    cp "$REPO_DIR/config/settings.json" "$CLAUDE_DIR/settings.json"
    echo "  Copied: settings.json (template — edit machine-specific paths)"
  else
    echo "  Skipped: settings.json (already exists, contains machine-specific config)"
  fi
fi

# gh-account-guard.conf — ship the example next to ~/.claude/ so the user can
# rename + edit it to enable the hook. Never overwrite a real conf.
GUARD_EXAMPLE_SRC="$REPO_DIR/config/gh-account-guard.conf.example"
GUARD_EXAMPLE_DST="$CLAUDE_DIR/gh-account-guard.conf.example"
if [ -f "$GUARD_EXAMPLE_SRC" ]; then
  if $DRY_RUN; then
    echo "[DRY RUN] Copy: $GUARD_EXAMPLE_SRC -> $GUARD_EXAMPLE_DST"
    if [ ! -f "$CLAUDE_DIR/gh-account-guard.conf" ]; then
      echo "[DRY RUN] Notice: rename to gh-account-guard.conf and set USERNAME to enable the hook"
    fi
  else
    cp "$GUARD_EXAMPLE_SRC" "$GUARD_EXAMPLE_DST"
    echo "  Copied: gh-account-guard.conf.example"
    if [ ! -f "$CLAUDE_DIR/gh-account-guard.conf" ]; then
      echo "    -> rename to gh-account-guard.conf and set USERNAME to enable the hook"
    fi
  fi
fi

# Install plugins if claude CLI is available
if $DRY_RUN; then
  echo ""
  if command -v claude &> /dev/null && [ -f "$REPO_DIR/config/plugins/plugins.json" ]; then
    echo "[DRY RUN] Would install plugins from plugins/plugins.json"
  else
    echo "[DRY RUN] Would skip plugin install (claude CLI not found or plugins.json missing)"
  fi
else
  if command -v claude &> /dev/null && [ -f "$REPO_DIR/config/plugins/plugins.json" ]; then
    echo ""
    echo "Installing plugins..."
    PLUGINS_JSON_NATIVE="$(to_native_path "$REPO_DIR/config/plugins/plugins.json")" \
    python3 -c "
import json, os
with open(os.environ['PLUGINS_JSON_NATIVE']) as f:
    plugins = json.load(f)['plugins']
for p in plugins:
    print(p)
" | while read -r plugin; do
      echo "  Installing: $plugin"
      claude plugin install "$plugin" 2>/dev/null || echo "    (skipped — may already be installed)"
    done
  else
    echo ""
    echo "Skipped plugin install (claude CLI not found or plugins.json missing)"
    echo "  Install manually: claude plugin install <name>"
  fi
fi

# ---------------------------------------------------------------------------
# Hooks — merge config/hooks.json into ~/.claude/settings.json
# ---------------------------------------------------------------------------
HOOKS_TEMPLATE="$REPO_DIR/config/hooks.json"

if [ -f "$HOOKS_TEMPLATE" ]; then
  HOOKS_TEMPLATE_NATIVE="$(to_native_path "$HOOKS_TEMPLATE")"
  if $DRY_RUN; then
    echo ""
    if SETTINGS_FILE_NATIVE="$SETTINGS_FILE_NATIVE" python3 -c "
import json, os, sys
try:
    with open(os.environ['SETTINGS_FILE_NATIVE']) as f:
        s = json.load(f)
    sys.exit(0 if 'hooks' in s else 1)
except Exception:
    sys.exit(1)
" 2>/dev/null; then
      echo "[DRY RUN] Would replace hooks in $SETTINGS_FILE (prev -> ${SETTINGS_FILE}.hooks.bak)"
    else
      echo "[DRY RUN] Would merge hooks from config/hooks.json into $SETTINGS_FILE"
    fi
    echo "[DRY RUN] REPO_DIR placeholder would be replaced with: $REPO_DIR_NATIVE"
    HOOKS_TEMPLATE_NATIVE="$HOOKS_TEMPLATE_NATIVE" REPO_DIR_NATIVE="$REPO_DIR_NATIVE" python3 -c "
import json, os
with open(os.environ['HOOKS_TEMPLATE_NATIVE']) as f:
    raw = f.read()
rendered = raw.replace('REPO_DIR', os.environ['REPO_DIR_NATIVE'].replace('\\\\', '/'))
hooks = json.loads(rendered)
for event, matchers in hooks['hooks'].items():
    for entry in matchers:
        for h in entry.get('hooks', []):
            print(f'[DRY RUN]   [{event}] matcher={entry[\"matcher\"]} cmd={h[\"command\"]}')
" 2>/dev/null || echo "[DRY RUN]   (could not parse hooks template)"
  else
    export REPO_DIR_PY="$REPO_DIR_NATIVE"
    export SETTINGS_FILE_PY="$SETTINGS_FILE_NATIVE"
    python3 - <<'PYEOF'
import json, sys, os

repo_dir      = os.environ['REPO_DIR_PY']
settings_path = os.environ['SETTINGS_FILE_PY']
hooks_path    = os.path.join(repo_dir, 'config', 'hooks.json')

with open(hooks_path) as f:
    raw = f.read()

# Normalize to forward slashes so the substituted path is a valid JSON string
# on Windows (backslashes would need escaping and would break json.loads).
rendered = raw.replace('REPO_DIR', repo_dir.replace('\\', '/'))
hooks_config = json.loads(rendered)

try:
    with open(settings_path) as f:
        settings = json.load(f)
except (FileNotFoundError, json.JSONDecodeError):
    settings = {}

if 'hooks' in settings:
    backup_path = settings_path + '.hooks.bak'
    with open(backup_path, 'w') as f:
        json.dump({'hooks': settings['hooks']}, f, indent=2)
        f.write('\n')
    action, note = 'Replaced', f' (prev -> {os.path.basename(backup_path)})'
else:
    action, note = 'Merged', ''

settings['hooks'] = hooks_config['hooks']

with open(settings_path, 'w') as f:
    json.dump(settings, f, indent=2)
    f.write('\n')

print(f'  {action}: hooks config into settings.json{note}')
PYEOF
    if [ $? -ne 0 ]; then
      echo "  Warning: failed to merge hooks into settings.json" >&2
    fi
  fi
fi

echo ""
if $DRY_RUN; then
  echo "Dry run complete. No changes were made."
else
  echo "Done! Your Claude Code agent system is installed."
  echo ""
  echo "Notes:"
  echo "  - settings.json is machine-specific (permissions, paths) — not symlinked"
  echo "  - Original files backed up as *.bak if they existed"
  echo "  - Changes in ~/.claude/{skills,agents,commands,...} now reflect this repo"
  echo "  - To see plugin list: cat plugins/plugins.json"
fi
