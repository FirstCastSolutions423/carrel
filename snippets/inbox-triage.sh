#!/usr/bin/env bash
# inbox-triage.sh — triage a messy downloads/inbox folder: sort plan + duplicate report.
#
# What it does:
#   1. `carrel organize` prints a dry-run plan sorting the folder's files into
#      pdf/, images/, data/, docs/ subfolders (nothing moves unless you pass --apply).
#   2. `carrel dedupe` reports exact-duplicate groups underneath it (report only —
#      this script never deletes; see the dedupe recipe for safe deletion).
#
# Requirements: carrel on PATH (both commands are pure python).
# Usage:
#   ./inbox-triage.sh ~/Downloads            # plan + duplicate report, no changes
#   ./inbox-triage.sh ~/Downloads --apply    # actually perform the sorting moves
# Override the CLI with e.g. CARREL="uv run carrel".

set -euo pipefail

CARREL="${CARREL:-carrel}"   # intentionally unquoted below: may hold "uv run carrel"
INBOX="${1:?usage: inbox-triage.sh FOLDER [--apply]}"
MODE="${2:---dry-run}"

echo "==> sort plan for $INBOX (by type):"
$CARREL organize "$INBOX" --by type "$MODE"

echo
echo "==> exact duplicates under $INBOX:"
$CARREL dedupe "$INBOX" || true   # exits nonzero only on real errors; empty report is fine

echo
echo "next steps:"
echo "  apply the plan:      $0 $INBOX --apply"
echo "  delete duplicates:   $CARREL dedupe $INBOX --delete oldest --apply"
