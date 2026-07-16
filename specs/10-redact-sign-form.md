# spec: redact + sign + form

**Owns:** `src/carrel/commands/{redact,sign,form}.py`, `tests/test_redact_sign_form.py`.

## redact
`carrel redact SRC [--pattern REGEX]... [--builtin email,phone,ssn,ipv4,cc] [--replacement '█'] [-o OUT] [--json]`
- Text types (txt/md/html/json/csv/xml): regex replace; JSON/XML operate on serialized text but MUST remain parseable after (redact within string values: replacement preserves quotes — implement by matching inside the raw text; acceptance enforces re-parse).
- Builtins: email, phone (NANP-ish), ssn, ipv4, cc (13-19 digit runs w/ separators, Luhn-checked to reduce false hits).
- pdf: `--pattern` finds words via pdftotext -bbox... COMPLEX — v1 scope: rasterize each page (pdftoppm 200dpi) → draw black boxes over regions of matched words using tesseract tsv word boxes when pattern matches word text → rebuild PDF (Pillow). True redaction (no text layer). If tesseract missing → exit 3. Report match counts per page.
- JSON: {src, dest, matches: {pattern: count}}. Zero matches → still writes output, notes 0 (exit 0; `--fail-empty` → 5).

## sign
`carrel sign stamp SRC [--text "Signed by X on DATE"] [--image sig.png] [--page last] [--pos bottom-right] [-o OUT]` — reportlab overlay merged via pypdf.
`carrel sign manifest PATH... [-o MANIFEST.sha256] [--gpg [--key ID]]` — sha256 lines (sha256sum format); `--gpg` detached .asc via gpg adapter.
`carrel sign verify MANIFEST [--json]` — recompute + gpg verify if .asc exists; exit 1 on any mismatch.

## form
`carrel form build SPEC.json [-o form.html] [--pdf]` — spec: {title, fields:[{name,label,type(text|textarea|select|checkbox|radio|date|email|number),options?,required?}]} → clean standalone HTML (embedded CSS, POST-less, print-friendly); `--pdf` renders via weasyprint.
`carrel form fields SRC.pdf [--json]` — list AcroForm fields (pypdf).
`carrel form fill SRC.pdf DATA.json -o OUT.pdf` — fill AcroForm (pypdf), report unmatched keys.

## Acceptance
redact email+ssn from txt/json fixtures (json re-parses); pdf redact: fixture with known string → output pdf's pdftotext no longer contains it; stamp adds visible text (extract via pdftotext contains stamp text OR page object count grows — verify pixel-diff nonzero too); manifest+verify roundtrip, tamper → exit 1; form build produces valid HTML (parseable) + pdf; fill fixture AcroForm → pypdf reads value back.
