#!/usr/bin/env bash
# =============================================================================
# Recipe 01 — Scanned PDF → OCR → Markdown → index → search
#
# A scanned (image-only) PDF has no text layer, so you can't grep or search it.
# This recipe OCRs it into Markdown notes, indexes the working folder into a
# desk db, and proves the content is now findable with full-text search.
#
# Requirements: carrel (or `uv sync` in this repo), ocrmypdf, tesseract.
# Usage (from anywhere): bash examples/cookbook/01-scan-to-searchable-notes.sh
# Everything happens in a throwaway temp dir; the repo stays clean.
# Expected: search hits for "fixture", ending with RECIPE OK.
# =============================================================================
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
FIXTURES="$REPO/tests/fixtures"
if command -v carrel >/dev/null 2>&1; then CARREL=(carrel); else CARREL=(uv --project "$REPO" run carrel); fi

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
echo "==> working in $WORK"
cp "$FIXTURES/scanned.pdf" "$WORK/"

echo "==> step 1: the scanned PDF has no extractable text"
"${CARREL[@]}" --json inspect "$WORK/scanned.pdf" | grep -E '"(type|pages)"' || true

echo "==> step 2: OCR it into Markdown notes"
"${CARREL[@]}" ocr "$WORK/scanned.pdf" --to md -o "$WORK/scanned-notes.md"
echo "--- first lines of the notes ---"
head -4 "$WORK/scanned-notes.md"

echo "==> step 3: index the folder (--ocr also reads the scanned PDF itself)"
"${CARREL[@]}" --root "$WORK" --json index --ocr

echo "==> step 4: search it"
"${CARREL[@]}" --root "$WORK" --json search "fixture" --fail-empty

echo "RECIPE OK"
