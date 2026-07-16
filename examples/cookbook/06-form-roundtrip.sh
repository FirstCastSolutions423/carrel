#!/usr/bin/env bash
# =============================================================================
# Recipe 06 — Forms: build one from JSON, fill a PDF AcroForm, verify
#
# Two halves of `carrel form`:
#   1. build — a JSON spec becomes clean standalone HTML (and, with --pdf, a
#      print-friendly PDF for pen-and-paper filling);
#   2. fields / fill — an existing fillable PDF (AcroForm) is listed, filled
#      from a JSON object, and re-listed to prove the values landed.
#
# Requirements: carrel; weasyprint only for the --pdf render in step 1.
# Usage (from anywhere): bash examples/cookbook/06-form-roundtrip.sh
# Expected: 4-field HTML+PDF built, name/agree filled and verified, RECIPE OK.
# =============================================================================
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
FIXTURES="$REPO/tests/fixtures"
if command -v carrel >/dev/null 2>&1; then CARREL=(carrel); else CARREL=(uv --project "$REPO" run carrel); fi

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
echo "==> working in $WORK"

echo "==> step 1: build an HTML (+ print PDF) form from a JSON spec"
cat > "$WORK/visitor-spec.json" <<'EOF'
{
  "title": "Visitor Log",
  "fields": [
    {"name": "visitor", "label": "Full name", "type": "text", "required": true},
    {"name": "email",   "label": "Email",     "type": "email"},
    {"name": "purpose", "label": "Purpose",   "type": "select",
     "options": ["Tour", "Meeting", "Delivery"]},
    {"name": "agree",   "label": "I accept the visitor rules", "type": "checkbox"}
  ]
}
EOF
"${CARREL[@]}" form build "$WORK/visitor-spec.json" -o "$WORK/visitor.html" --pdf
test -s "$WORK/visitor.html" && test -s "$WORK/visitor.pdf"
grep -c '<input\|<select' "$WORK/visitor.html" | xargs -I{} echo "    {} form control(s) in visitor.html"

echo "==> step 2: list the fixture AcroForm's fields (empty)"
cp "$FIXTURES/form.pdf" "$WORK/agreement.pdf"
"${CARREL[@]}" --json form fields "$WORK/agreement.pdf"

echo "==> step 3: fill it from JSON"
printf '{"name": "Ada Lovelace", "agree": true}\n' > "$WORK/answers.json"
"${CARREL[@]}" --json form fill "$WORK/agreement.pdf" "$WORK/answers.json" \
  -o "$WORK/agreement.filled.pdf"

echo "==> step 4: verify the values landed"
"${CARREL[@]}" --json form fields "$WORK/agreement.filled.pdf" \
  | grep -E '"value"'
"${CARREL[@]}" --json form fields "$WORK/agreement.filled.pdf" | grep -q "Ada Lovelace"
"${CARREL[@]}" --json form fields "$WORK/agreement.filled.pdf" | grep -q "/Yes"

echo "RECIPE OK"
