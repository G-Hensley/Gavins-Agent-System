#!/usr/bin/env bash
set -euo pipefail

# Install Gavin's Claude Code Agent System
# Symlinks or copies skills, agents, commands, and config into ~/.claude/

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"

echo "Installing Claude Code Agent System..."
echo "  Source: $REPO_DIR"
echo "  Target: $CLAUDE_DIR"
echo ""

# Create target if needed
mkdir -p "$CLAUDE_DIR"

# Portable directories to sync
DIRS=(skills agents commands improvements agent-memory plans)

for dir in "${DIRS[@]}"; do
  if [ -d "$REPO_DIR/$dir" ]; then
    # Remove existing target (symlink or dir)
    if [ -L "$CLAUDE_DIR/$dir" ]; then
      rm "$CLAUDE_DIR/$dir"
    elif [ -d "$CLAUDE_DIR/$dir" ]; then
      echo "  Backing up existing $dir -> $dir.bak"
      mv "$CLAUDE_DIR/$dir" "$CLAUDE_DIR/$dir.bak"
    fi
    ln -s "$REPO_DIR/$dir" "$CLAUDE_DIR/$dir"
    echo "  Linked: $dir"
  fi
done

# Config files — symlink individually
for file in CLAUDE.md settings.local.json; do
  if [ -f "$REPO_DIR/$file" ]; then
    if [ -f "$CLAUDE_DIR/$file" ] && [ ! -L "$CLAUDE_DIR/$file" ]; then
      echo "  Backing up existing $file -> $file.bak"
      mv "$CLAUDE_DIR/$file" "$CLAUDE_DIR/$file.bak"
    fi
    ln -sf "$REPO_DIR/$file" "$CLAUDE_DIR/$file"
    echo "  Linked: $file"
  fi
done

# Plugin config (just the list, not caches)
mkdir -p "$CLAUDE_DIR/plugins"
if [ -f "$REPO_DIR/plugins/installed_plugins.json" ]; then
  ln -sf "$REPO_DIR/plugins/installed_plugins.json" "$CLAUDE_DIR/plugins/installed_plugins.json"
  echo "  Linked: plugins/installed_plugins.json"
fi

# settings.json is NOT symlinked — it contains machine-specific permissions
# Copy it as a starting point if none exists
if [ ! -f "$CLAUDE_DIR/settings.json" ]; then
  cp "$REPO_DIR/settings.json" "$CLAUDE_DIR/settings.json"
  echo "  Copied: settings.json (template — edit machine-specific paths)"
else
  echo "  Skipped: settings.json (already exists, contains machine-specific config)"
fi

# Install plugins if claude CLI is available
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

echo ""
echo "Done! Your Claude Code agent system is installed."
echo ""
echo "Notes:"
echo "  - settings.json is machine-specific (permissions, paths) — not symlinked"
echo "  - Original files backed up as *.bak if they existed"
echo "  - Changes in ~/.claude/{skills,agents,commands,...} now reflect this repo"
echo "  - To see plugin list: cat plugins/plugins.json"
