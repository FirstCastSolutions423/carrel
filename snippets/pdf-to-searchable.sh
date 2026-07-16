#!/usr/bin/env bash
# pdf-to-searchable.sh — OCR every PDF in a folder, then build a full-text index.
#
# What it does:
#   For each *.pdf directly inside FOLDER, writes a searchable copy NAME.ocr.pdf
#   (ocrmypdf passes born-digital pages through untouched, so it is safe to run
#   over mixed folders). Then runs `carrel index --ocr` so the whole folder —
#   including the fresh text layers — is searchable with `carrel search`.
#
# Requirements: carrel on PATH, plus ocrmypdf + tesseract (`carrel doctor` to check).
# Usage:
#   ./pdf-to-searchable.sh ~/scans
#   carrel --root ~/scans search "invoice 2024"
# Override the CLI with e.g. CARREL="uv run carrel".

set -euo pipefail

CARREL="${CARREL:-carrel}"   # intentionally unquoted below: may hold "uv run carrel"
FOLDER="${1:?usage: pdf-to-searchable.sh FOLDER}"

shopt -s nullglob
for pdf in "$FOLDER"/*.pdf; do
  case "$pdf" in *.ocr.pdf) continue ;; esac      # don't re-OCR our own outputs
  out="${pdf%.pdf}.ocr.pdf"
  if [[ -e "$out" ]]; then
    echo "skip (exists): $out"
    continue
  fi
  echo "==> OCR: $pdf -> $out"
  $CARREL ocr "$pdf" --to pdf -o "$out"
done

echo "==> indexing $FOLDER into $FOLDER/.carrel/carrel.db"
$CARREL --root "$FOLDER" index --ocr

echo "done — try: $CARREL --root $FOLDER search 'your query'"
