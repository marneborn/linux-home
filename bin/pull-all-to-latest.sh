#!/usr/bin/env bash
# pull-all-to-latest.sh
# For each repo in core/ and utility/:
#   - Reports dirty repos (unstaged or uncommitted changes)
#   - For clean repos: checks out main, pulls latest, runs pruneBranches

set -euo pipefail

GLADE="$HOME/dev/glade"
DIRTY=()
UPDATED=()
FAILED=()

# Collect all repos
REPOS=()
for base in "$GLADE/core" "$GLADE/utility"; do
  for d in "$base"/*/; do
    if [ -d "$d/.git" ] || [ -f "$d/.git" ]; then
      REPOS+=("$d")
    fi
  done
done

echo "Checking ${#REPOS[@]} repos..."
echo ""

for repo in "${REPOS[@]}"; do
  name=$(basename "$repo")

  # Check for unstaged or uncommitted changes
  status=$(git -C "$repo" status --porcelain 2>/dev/null)
  if [ -n "$status" ]; then
    DIRTY+=("$name")
    continue
  fi

  # Clean — update it
  (
    git -C "$repo" checkout main 2>/dev/null
    git -C "$repo" pull 2>/dev/null
    # pruneBranches is a shell alias; expand it inline
    git -C "$repo" fetch origin --prune 2>&1 \
      | grep '\[deleted\]' \
      | perl -p -e 's/.* origin\///' \
      | xargs -r git -C "$repo" branch -D
  ) && UPDATED+=("$name") || FAILED+=("$name")
done

# Report
echo "========================================"

if [ ${#DIRTY[@]} -gt 0 ]; then
  echo ""
  echo "DIRTY (skipped):"
  for r in "${DIRTY[@]}"; do
    echo "  ⚠  $r"
  done
fi

if [ ${#UPDATED[@]} -gt 0 ]; then
  echo ""
  echo "UPDATED:"
  for r in "${UPDATED[@]}"; do
    echo "  ✓  $r"
  done
fi

if [ ${#FAILED[@]} -gt 0 ]; then
  echo ""
  echo "FAILED:"
  for r in "${FAILED[@]}"; do
    echo "  ✗  $r"
  done
fi

echo ""
echo "Done. ${#UPDATED[@]} updated, ${#DIRTY[@]} skipped (dirty), ${#FAILED[@]} failed."
