#!/usr/bin/env bash
# Clone temporalio/samples-python into a demo repo as references/temporal-samples/.
#
# Three of this plugin's agents are told to consult that directory before
# inventing a pattern. Nothing created it, so the instruction silently no-opped
# in the first repo that used the plugin. Call this from the demo repo's own
# install script, or run it once by hand from the repo root.
#
# Safe to re-run: refreshes an existing clone instead of failing.
set -euo pipefail

REPO_ROOT="${1:-$PWD}"
DEST="$REPO_ROOT/references/temporal-samples"

if [ -d "$DEST/.git" ]; then
  echo "Refreshing temporal samples..."
  git -C "$DEST" pull --ff-only --quiet ||
    echo "Could not refresh samples; keeping the existing clone" >&2
  exit 0
fi

echo "Cloning temporalio/samples-python for agent reference..."
mkdir -p "$(dirname "$DEST")"
git clone --depth 1 --quiet \
  https://github.com/temporalio/samples-python.git "$DEST" || {
    echo "Sample clone failed; agents will fall back to the temporal-docs MCP server" >&2
    exit 0
  }

grep -qxF 'references/' "$REPO_ROOT/.gitignore" 2>/dev/null ||
  echo "Add 'references/' to .gitignore — the clone should not be committed." >&2
