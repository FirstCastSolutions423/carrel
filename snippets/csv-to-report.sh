#!/usr/bin/env bash
# csv-to-report.sh — turn a CSV into a Markdown table + standalone HTML report.
#
# What it does:
#   1. `carrel inspect --json` reads the CSV's shape (delimiter, columns, rows)
#      and prints a one-line summary.
#   2. `carrel convert` writes NAME.md (pipe table) and NAME.html (standalone
#      page with a <table>) next to the CSV, or into OUTDIR if given.
#
# Requirements: carrel on PATH; python3 for the summary line (jq works too).
# Usage:
#   ./csv-to-report.sh data.csv [OUTDIR]
# Override the CLI with e.g. CARREL="uv run carrel".

set -euo pipefail

CARREL="${CARREL:-carrel}"   # intentionally unquoted below: may hold "uv run carrel"
CSV="${1:?usage: csv-to-report.sh FILE.csv [OUTDIR]}"
OUTDIR="${2:-$(dirname "$CSV")}"
mkdir -p "$OUTDIR"
STEM="$(basename "${CSV%.*}")"

echo "==> shape:"
$CARREL --json inspect "$CSV" | python3 -c '
import json, sys
d = json.load(sys.stdin)["detail"]
print("  {} rows x {} columns (delimiter {!r}): {}".format(
    d["rows"], d["column_count"], d["delimiter"], ", ".join(d["columns"])))'

echo "==> writing $OUTDIR/$STEM.md and $OUTDIR/$STEM.html"
$CARREL convert "$CSV" --to md   -o "$OUTDIR/$STEM.md"   --force
$CARREL convert "$CSV" --to html -o "$OUTDIR/$STEM.html" --force

echo "done — preview the table with: head $OUTDIR/$STEM.md"
