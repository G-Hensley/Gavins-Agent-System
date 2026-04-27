#!/usr/bin/env bash
set -euo pipefail

# Back up locally-only files in the agent system (gitignored agent-memory
# contents + untracked files anywhere in the repo) to a timestamped tarball.
#
# These files would be lost in a fresh `git clone` of the repo, so run this
# before any "reinstall from scratch" workflow (new machine, repo deletion,
# disk wipe, etc).
#
# Default output: ~/.claude/backups/agent-system-local-YYYYMMDD-HHMMSS.tar.gz

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
BACKUP_DIR="$HOME/.claude/backups"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
DEFAULT_OUTPUT="$BACKUP_DIR/agent-system-local-$TIMESTAMP.tar.gz"

DRY_RUN=false
OUTPUT="$DEFAULT_OUTPUT"

usage() {
  cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Back up locally-only files (gitignored agent-memory contents + any
untracked files in the repo) to a timestamped tarball. Run this before
deleting the repo or cloning fresh on another machine.

Options:
  --dry-run         List the files that would be archived without writing
                    anything. Each candidate is prefixed with [DRY RUN].
  --output PATH     Write the tarball to PATH instead of the default
                    $DEFAULT_OUTPUT
  --help            Show this help text and exit.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    --output)
      OUTPUT="$2"
      shift 2
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

cd "$REPO_DIR"

# ---------------------------------------------------------------------------
# Collect candidates
# ---------------------------------------------------------------------------
# 1. Everything under agent-memory/ except README.md (the * is gitignored).
# 2. Every untracked file the repo's gitignore rules would let through —
#    `git ls-files --others --exclude-standard` is the source of truth here.
#    This catches improvements/system/*.md drafts, scratch files, etc.
#
# Files are stored as repo-relative paths so the archive extracts cleanly
# from the repo root.

mapfile -t MEMORY_FILES < <(
  if [ -d agent-memory ]; then
    find agent-memory -type f ! -name README.md | sort
  fi
)

mapfile -t UNTRACKED_FILES < <(git ls-files --others --exclude-standard | sort)

# De-dupe: anything in agent-memory/ that's also untracked would be listed
# twice. Keep one copy.
mapfile -t ALL_FILES < <(printf '%s\n' "${MEMORY_FILES[@]}" "${UNTRACKED_FILES[@]}" | awk 'NF' | sort -u)

if [ "${#ALL_FILES[@]}" -eq 0 ]; then
  echo "Nothing to back up — no gitignored agent-memory files and no untracked files in the repo."
  exit 0
fi

memory_count=0
untracked_only_count=0
for f in "${ALL_FILES[@]}"; do
  if [[ "$f" == agent-memory/* ]]; then
    memory_count=$((memory_count + 1))
  else
    untracked_only_count=$((untracked_only_count + 1))
  fi
done

# ---------------------------------------------------------------------------
# Dry run
# ---------------------------------------------------------------------------
if $DRY_RUN; then
  echo "[DRY RUN] Backup of locally-only files (no archive written)"
  echo "  Repo:   $REPO_DIR"
  echo "  Output: $OUTPUT"
  echo ""
  echo "  Would archive ${#ALL_FILES[@]} file(s):"
  echo "    $memory_count from agent-memory/ (gitignored)"
  echo "    $untracked_only_count untracked elsewhere in the repo"
  echo ""
  for f in "${ALL_FILES[@]}"; do
    echo "[DRY RUN]   $f"
  done
  exit 0
fi

# ---------------------------------------------------------------------------
# Real run
# ---------------------------------------------------------------------------
mkdir -p "$(dirname "$OUTPUT")"

# Feed the file list to tar via -T so we don't trip the command-line length
# limit on large memory dirs.
TMP_LIST="$(mktemp)"
trap 'rm -f "$TMP_LIST"' EXIT
printf '%s\n' "${ALL_FILES[@]}" > "$TMP_LIST"

echo "Backing up ${#ALL_FILES[@]} file(s) ($memory_count from agent-memory/, $untracked_only_count untracked) ..."
tar -czf "$OUTPUT" -T "$TMP_LIST"

# tar always succeeds quietly; show size + path so the user has receipts.
size="$(du -h "$OUTPUT" | cut -f1)"
echo ""
echo "Done. Backup written:"
echo "  $OUTPUT  ($size)"
echo ""
echo "Restore later with:"
echo "  tar -xzf \"$OUTPUT\" -C \"$REPO_DIR\""
