#!/usr/bin/env bash
# redact-pii.sh — sweep a folder's text files for PII and write redacted copies.
#
# What it does:
#   Runs `carrel redact` with every built-in PII pattern (email, phone, ssn,
#   ipv4, cc) over each txt/md/html/json/csv/xml file directly inside FOLDER,
#   writing NAME.redacted.EXT copies into OUTDIR. Originals are never touched.
#   JSON/XML outputs are re-parsed by carrel so they stay valid. PDFs are skipped
#   here — PDF redaction rasterizes pages; run it deliberately, per file:
#   `carrel redact file.pdf --builtin email,ssn`.
#
# Requirements: carrel on PATH (text redaction is pure python).
# Usage:
#   ./redact-pii.sh ~/exports ~/exports-clean
# Override the CLI with e.g. CARREL="uv run carrel".

set -euo pipefail

CARREL="${CARREL:-carrel}"   # intentionally unquoted below: may hold "uv run carrel"
FOLDER="${1:?usage: redact-pii.sh FOLDER OUTDIR}"
OUTDIR="${2:?usage: redact-pii.sh FOLDER OUTDIR}"
mkdir -p "$OUTDIR"

shopt -s nullglob
count=0
for f in "$FOLDER"/*.txt "$FOLDER"/*.md "$FOLDER"/*.html \
         "$FOLDER"/*.json "$FOLDER"/*.csv "$FOLDER"/*.xml; do
  name="$(basename "$f")"
  out="$OUTDIR/${name%.*}.redacted.${name##*.}"
  echo "==> $f"
  $CARREL redact "$f" --builtin email,phone,ssn,ipv4,cc -o "$out" --force
  count=$((count + 1))
done

echo "done — $count file(s) redacted into $OUTDIR (originals untouched)."
