#!/usr/bin/env bash
# watch-thumbs.sh — auto-thumbnail every image/PDF dropped into a folder.
#
# What it does:
#   Runs `carrel watch` on FOLDER and generates a 256px PNG thumbnail into
#   FOLDER/../thumbs (outside the watched folder, so thumbnails never re-trigger
#   the watcher). Runs until Ctrl-C; pass a number of seconds as the second
#   argument for a bounded run.
#
# Requirements: carrel on PATH; pdftoppm (poppler) for PDF thumbnails.
# Usage:
#   ./watch-thumbs.sh ~/inbox           # watch until Ctrl-C
#   ./watch-thumbs.sh ~/inbox 30        # stop after 30 seconds
# Override the CLI with e.g. CARREL="uv run carrel".

set -euo pipefail

CARREL="${CARREL:-carrel}"   # intentionally unquoted below: may hold "uv run carrel"
FOLDER="${1:?usage: watch-thumbs.sh FOLDER [TIMEOUT_SECS]}"
TIMEOUT="${2:-}"

THUMBS="$(dirname "$FOLDER")/thumbs"
mkdir -p "$THUMBS"

EXTRA=()
[[ -n "$TIMEOUT" ]] && EXTRA=(--timeout "$TIMEOUT")

echo "==> watching $FOLDER — thumbnails land in $THUMBS (Ctrl-C to stop)"
$CARREL watch "$FOLDER" \
  --on created,modified \
  --run "$CARREL thumb {path} --out-dir $THUMBS --size 256" \
  "${EXTRA[@]}"
