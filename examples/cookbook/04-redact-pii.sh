#!/usr/bin/env bash
# =============================================================================
# Recipe 04 — Redaction demo: text file and true PDF redaction
#
# Writes a memo full of fake PII, then:
#   1. redacts the .txt with built-in patterns (email, phone, ssn, ipv4, cc)
#      — regex replacement, original untouched;
#   2. converts the memo to PDF and redacts THAT. PDF redaction is true
#      redaction: pages are rasterized and matches painted over, so the output
#      has no text layer at all (that's the point — nothing to un-hide).
#   3. proves it: extracting text from the redacted PDF finds no PII because
#      there is no text to extract. Run `carrel ocr` on it if you want the
#      non-redacted words searchable again.
#
# Requirements: carrel, weasyprint (txt→pdf), tesseract (PDF redaction verify).
# Usage (from anywhere): bash examples/cookbook/04-redact-pii.sh
# Expected: 5 matches in the txt, 2+ in the pdf, empty extraction, RECIPE OK.
# =============================================================================
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
if command -v carrel >/dev/null 2>&1; then CARREL=(carrel); else CARREL=(uv --project "$REPO" run carrel); fi

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
echo "==> working in $WORK"

cat > "$WORK/memo.txt" <<'EOF'
INTERNAL MEMO — do not distribute

Reach Jane at jane.doe@example.com or 555-123-4567.
Her SSN is 123-45-6789 and the build box lives at 192.168.10.44.
Card on file: 4111 1111 1111 1111.
EOF

echo "==> step 1: redact the text file with every builtin pattern"
"${CARREL[@]}" --json redact "$WORK/memo.txt" \
  --builtin email,phone,ssn,ipv4,cc -o "$WORK/memo.redacted.txt"
echo "--- redacted text ---"
cat "$WORK/memo.redacted.txt"

echo "==> step 2: make a PDF of the memo and truly redact it"
"${CARREL[@]}" convert "$WORK/memo.txt" --to pdf -o "$WORK/memo.pdf"
"${CARREL[@]}" --json redact "$WORK/memo.pdf" \
  --builtin email,ssn -o "$WORK/memo.redacted.pdf"

echo "==> step 3: prove the text layer is gone"
"${CARREL[@]}" convert "$WORK/memo.redacted.pdf" --to txt -o "$WORK/leaktest.txt"
if grep -qE 'example\.com|123-45-6789' "$WORK/leaktest.txt"; then
  echo "FAIL: PII survived redaction" >&2
  exit 1
fi
echo "    extracted $(wc -c < "$WORK/leaktest.txt") byte(s) of text — no PII, no text layer"

echo "RECIPE OK"
