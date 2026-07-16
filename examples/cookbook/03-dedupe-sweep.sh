#!/usr/bin/env bash
# =============================================================================
# Recipe 03 — Dedupe sweep: report → plan → delete, keeping the newest copy
#
# Builds a folder with two duplicate groups (a text note copied twice, an image
# copied once), then walks carrel dedupe's three safety levels:
#   1. report only (default) — nothing can be deleted;
#   2. --delete oldest WITHOUT --apply — a plan, still nothing deleted;
#   3. --delete oldest --apply — older duplicates removed, newest of each
#      group kept (the kept member is never deleted).
#
# Requirements: carrel (hashing is stdlib BLAKE2).
# Usage (from anywhere): bash examples/cookbook/03-dedupe-sweep.sh
# Expected: 5 files before, 2 after (the newest member of each group), RECIPE OK.
# =============================================================================
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
FIXTURES="$REPO/tests/fixtures"
if command -v carrel >/dev/null 2>&1; then CARREL=(carrel); else CARREL=(uv --project "$REPO" run carrel); fi

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
echo "==> building a folder with duplicates in $WORK"
cp "$FIXTURES/sample.txt" "$WORK/notes.txt"
cp "$FIXTURES/sample.txt" "$WORK/notes (copy).txt"
cp "$FIXTURES/sample.txt" "$WORK/notes-final.txt"
cp "$FIXTURES/sample.jpg" "$WORK/photo.jpg"
cp "$FIXTURES/sample.jpg" "$WORK/photo-backup.jpg"
# deterministic mtimes: the "-final"/plain names are newest, so they survive
touch -d '2024-01-01' "$WORK/notes.txt" "$WORK/notes (copy).txt" "$WORK/photo-backup.jpg"
touch -d '2025-06-01' "$WORK/notes-final.txt" "$WORK/photo.jpg"
echo "    files before: $(ls "$WORK" | wc -l)"

echo "==> step 1: report duplicates (nothing is deleted)"
"${CARREL[@]}" dedupe "$WORK"

echo "==> step 2: plan a deletion (still nothing deleted without --apply)"
"${CARREL[@]}" --json dedupe "$WORK" --delete oldest | grep -c '"hash"' \
  | xargs -I{} echo "    {} duplicate group(s) planned"
test "$(ls "$WORK" | wc -l)" -eq 5 && echo "    confirmed: still 5 files on disk"

echo "==> step 3: apply — delete the oldest of each group, keep the newest"
"${CARREL[@]}" --json dedupe "$WORK" --delete oldest --apply

echo "==> verifying survivors"
ls "$WORK"
test "$(ls "$WORK" | wc -l)" -eq 2
test -f "$WORK/notes-final.txt" && test -f "$WORK/photo.jpg"

echo "RECIPE OK"
