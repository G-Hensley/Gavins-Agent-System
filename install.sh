#!/usr/bin/env bash
set -euo pipefail

# Install Gavin's Claude Code Agent System
# Symlinks or copies skills, agents, commands, and config into ~/.claude/

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"

DRY_RUN=false
VERIFY=false

# ---------------------------------------------------------------------------
# Flag parsing
# ---------------------------------------------------------------------------
usage() {
  cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Install the Claude Code Agent System by symlinking skills, agents, commands,
and config into ~/.claude/.

Options:
  --dry-run   Show what would be symlinked/copied without making any changes.
              Each action is prefixed with [DRY RUN].
  --verify    Check that all expected symlinks exist, point to the correct
              targets, and that those targets actually exist on disk.
              Exits 0 if everything is intact, 1 if anything is broken.
  --help      Show this help text and exit.

Default (no flags): perform the full install.
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
# Portable directories to sync
# ---------------------------------------------------------------------------
DIRS=(skills agents commands improvements agent-memory plans)

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

  for file in CLAUDE.md settings.local.json; do
    if [ -f "$REPO_DIR/$file" ]; then
      check_symlink "$CLAUDE_DIR/$file" "$REPO_DIR/$file" "$file"
    fi
  done

  if [ -f "$REPO_DIR/plugins/installed_plugins.json" ]; then
    check_symlink \
      "$CLAUDE_DIR/plugins/installed_plugins.json" \
      "$REPO_DIR/plugins/installed_plugins.json" \
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
for file in CLAUDE.md settings.local.json; do
  if [ -f "$REPO_DIR/$file" ]; then
    if $DRY_RUN; then
      if [ -f "$CLAUDE_DIR/$file" ] && [ ! -L "$CLAUDE_DIR/$file" ]; then
        echo "[DRY RUN] Backup existing file: $CLAUDE_DIR/$file -> $CLAUDE_DIR/$file.bak"
      fi
      echo "[DRY RUN] Symlink: $CLAUDE_DIR/$file -> $REPO_DIR/$file"
    else
      if [ -f "$CLAUDE_DIR/$file" ] && [ ! -L "$CLAUDE_DIR/$file" ]; then
        echo "  Backing up existing $file -> $file.bak"
        mv "$CLAUDE_DIR/$file" "$CLAUDE_DIR/$file.bak"
      fi
      ln -sf "$REPO_DIR/$file" "$CLAUDE_DIR/$file"
      echo "  Linked: $file"
    fi
  fi
done

# Plugin config (just the list, not caches)
if $DRY_RUN; then
  echo "[DRY RUN] mkdir -p $CLAUDE_DIR/plugins"
  if [ -f "$REPO_DIR/plugins/installed_plugins.json" ]; then
    echo "[DRY RUN] Symlink: $CLAUDE_DIR/plugins/installed_plugins.json -> $REPO_DIR/plugins/installed_plugins.json"
  fi
else
  mkdir -p "$CLAUDE_DIR/plugins"
  if [ -f "$REPO_DIR/plugins/installed_plugins.json" ]; then
    ln -sf "$REPO_DIR/plugins/installed_plugins.json" "$CLAUDE_DIR/plugins/installed_plugins.json"
    echo "  Linked: plugins/installed_plugins.json"
  fi
fi

# settings.json is NOT symlinked — it contains machine-specific permissions
# Copy it as a starting point if none exists
if $DRY_RUN; then
  if [ ! -f "$CLAUDE_DIR/settings.json" ]; then
    echo "[DRY RUN] Copy: $REPO_DIR/settings.json -> $CLAUDE_DIR/settings.json (template)"
  else
    echo "[DRY RUN] Skip: settings.json (already exists, contains machine-specific config)"
  fi
else
  if [ ! -f "$CLAUDE_DIR/settings.json" ]; then
    cp "$REPO_DIR/settings.json" "$CLAUDE_DIR/settings.json"
    echo "  Copied: settings.json (template — edit machine-specific paths)"
  else
    echo "  Skipped: settings.json (already exists, contains machine-specific config)"
  fi
fi

# Install plugins if claude CLI is available
if $DRY_RUN; then
  echo ""
  if command -v claude &> /dev/null && [ -f "$REPO_DIR/plugins/plugins.json" ]; then
    echo "[DRY RUN] Would install plugins from plugins/plugins.json"
  else
    echo "[DRY RUN] Would skip plugin install (claude CLI not found or plugins.json missing)"
  fi
else
  if command -v claude &> /dev/null && [ -f "$REPO_DIR/plugins/plugins.json" ]; then
    echo ""
    echo "Installing plugins..."
    python3 -c "
import json
with open('$REPO_DIR/plugins/plugins.json') as f:
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
