#!/usr/bin/env bash
# pack-repo-for-claude.sh — bundle a repo into chunked, LLM-ready context files.
#
# What it does:
#   Runs `carrel pack` over a directory, honoring .gitignore, excluding lockfiles
#   and build junk, and splits the result into N-token chunks you can paste into
#   Claude one part at a time. Prints a per-file token table first so you can see
#   what is eating your budget.
#
# Requirements: carrel on PATH (pure-python pack — no external binaries needed).
# Usage:
#   ./pack-repo-for-claude.sh [REPO_DIR] [OUT_PREFIX] [CHUNK_TOKENS]
#   ./pack-repo-for-claude.sh ~/projects/myapp /tmp/myapp-context.md 40000
# Defaults: REPO_DIR=. OUT_PREFIX=./pack.md CHUNK_TOKENS=40000
# Override the CLI with e.g. CARREL="uv run carrel".

set -euo pipefail

CARREL="${CARREL:-carrel}"           # intentionally unquoted below: may hold "uv run carrel"
REPO_DIR="${1:-.}"
OUT="${2:-./pack.md}"
CHUNK="${3:-40000}"

echo "==> token budget per file (largest offenders first):"
$CARREL pack "$REPO_DIR" \
  --exclude '*.lock' --exclude 'uv.lock' --exclude 'package-lock.json' \
  --exclude 'node_modules' --exclude 'dist' --exclude 'build' --exclude '.venv' \
  --stats

echo
echo "==> writing chunks (<= $CHUNK tokens_est each) to $OUT.part1..N"
$CARREL pack "$REPO_DIR" \
  --exclude '*.lock' --exclude 'uv.lock' --exclude 'package-lock.json' \
  --exclude 'node_modules' --exclude 'dist' --exclude 'build' --exclude '.venv' \
  -o "$OUT" --chunk "$CHUNK"

ls -1 "$OUT".part* 2>/dev/null || ls -1 "$OUT"
echo "done — paste the parts into your model in order."
