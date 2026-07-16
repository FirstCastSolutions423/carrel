#!/usr/bin/env bash
# =============================================================================
# Recipe 02 — Watch-folder auto-thumbnails (deterministic 10-second demo)
#
# `carrel watch` runs shell actions on file events. Here it watches an inbox/
# and thumbnails every image dropped in. A background job drops a JPEG two
# seconds in, and --timeout 10 stops the watcher on its own — so the demo is
# fully hands-off and deterministic. Thumbnails go OUTSIDE the watched folder
# so they can never re-trigger the watcher.
#
# Requirements: carrel (watchdog is bundled).
# Usage (from anywhere): bash examples/cookbook/02-watch-auto-thumbs.sh
# Expected: one json-lines event with rc 0, a thumbs/incoming.png, RECIPE OK.
# =============================================================================
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
FIXTURES="$REPO/tests/fixtures"
if command -v carrel >/dev/null 2>&1; then CARREL=(carrel); else CARREL=(uv --project "$REPO" run carrel); fi

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
mkdir -p "$WORK/inbox" "$WORK/thumbs"
echo "==> working in $WORK"

echo "==> dropping a file into inbox/ two seconds from now (background)"
( sleep 2; cp "$FIXTURES/sample.jpg" "$WORK/inbox/incoming.jpg" ) &
DROP_PID=$!

echo "==> watching inbox/ for 10 seconds (json-lines log below)"
"${CARREL[@]}" watch "$WORK/inbox" \
  --on created --glob '*.jpg' \
  --run "${CARREL[*]} thumb {path} --out-dir $WORK/thumbs --size 128" \
  --timeout 10 --json-lines
wait "$DROP_PID"

echo "==> verifying the thumbnail exists"
test -f "$WORK/thumbs/incoming.png"
"${CARREL[@]}" --json inspect "$WORK/thumbs/incoming.png" | grep -E '"(width|height|type)"'

echo "RECIPE OK"
