#!/usr/bin/env bash
# =============================================================================
# Recipe 05 — Conversion relay: md → html → pdf → txt, then a JSON summary
#
# Chains carrel convert through four file types starting from the Markdown
# fixture, then runs `carrel inspect --json` on every artifact and folds the
# results into one relay-summary.json — a worked example of feeding carrel's
# JSON output into your own tooling (python3 here; jq works the same way).
#
# Requirements: carrel, pandoc (md→html), weasyprint (html→pdf),
#               pdftotext (pdf→txt). Check with `carrel doctor`.
# Usage (from anywhere): bash examples/cookbook/05-conversion-relay.sh
# Expected: 4 conversion lines, a summary table of every artifact, RECIPE OK.
# =============================================================================
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
FIXTURES="$REPO/tests/fixtures"
if command -v carrel >/dev/null 2>&1; then CARREL=(carrel); else CARREL=(uv --project "$REPO" run carrel); fi

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
echo "==> working in $WORK"
cp "$FIXTURES/sample.md" "$WORK/relay.md"

echo "==> the relay: md → html → pdf → txt"
"${CARREL[@]}" convert "$WORK/relay.md"   --to html -o "$WORK/relay.html"
"${CARREL[@]}" convert "$WORK/relay.html" --to pdf  -o "$WORK/relay.pdf"
"${CARREL[@]}" convert "$WORK/relay.pdf"  --to txt  -o "$WORK/relay.txt"

echo "==> inspect every artifact and fold into relay-summary.json"
for f in relay.md relay.html relay.pdf relay.txt; do
  "${CARREL[@]}" --json inspect "$WORK/$f"
done | python3 -c '
import json, sys
docs = json.loads("[" + sys.stdin.read().replace("}\n{", "},\n{") + "]")
summary = [{"name": d["name"], "type": d["type"], "size": d["size"],
            "sha256": d["sha256"][:12]} for d in docs]
json.dump({"relay": summary}, open(sys.argv[1], "w"), indent=2)
for s in summary:
    print("    {:<12} {:<5} {:>7} bytes  {}...".format(
        s["name"], s["type"], s["size"], s["sha256"]))
' "$WORK/relay-summary.json"

echo "==> sanity: the sentinel phrase survives the whole relay"
grep -qi "melodious cartography" "$WORK/relay.txt"
test -s "$WORK/relay-summary.json"

echo "RECIPE OK"
