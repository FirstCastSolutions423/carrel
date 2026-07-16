#!/usr/bin/env bash
# 07 — Audiobook from markdown
#
# Narrates a markdown document into per-chapter MP3s: headings become spoken
# chapter announcements, code blocks are skipped, links read their text.
# Requires: espeak-ng (voice), ffmpeg (mp3 encode). ~30s of audio.
#
# Expected: two chapter mp3 files plus a duration report, then RECIPE OK.
set -euo pipefail
cd "$(dirname "$0")/../.."
CARREL="${CARREL:-uv run carrel}"

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

cp tests/fixtures/sample.md "$work/book.md"

echo "==> narrate with chapter splitting"
$CARREL --json audiobook "$work/book.md" -o "$work/book.mp3" --split-chapters \
  | python3 -c '
import json, sys
r = json.load(sys.stdin)
assert len(r["outputs"]) >= 2, f"expected >=2 chapter files, got {r['"'"'outputs'"'"']}"
assert r["duration_s"] and r["duration_s"] > 5, f"suspiciously short: {r['"'"'duration_s'"'"']}"
print(f"  engine={r['"'"'engine'"'"']} chapters={len(r['"'"'outputs'"'"'])} duration={r['"'"'duration_s'"'"']}s")
'

echo "==> chapter files on disk"
ls -la "$work" | grep -E 'book-[0-9]+.*\.mp3'

echo "RECIPE OK"
