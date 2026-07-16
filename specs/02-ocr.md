# spec: ocr

**Owns:** `src/carrel/commands/ocr.py`, `tests/test_ocr.py`.

## CLI
`carrel ocr SRC [-o OUT] [--lang eng] [--to txt|pdf|md] [--json] [--force]`
- Image (jpg/jpeg/png) → tesseract → txt (default) or md (same text). `--to pdf` → tesseract pdf output.
- PDF → ocrmypdf (`--skip-text` default so born-digital pages pass through; `--force-ocr` flag exposed as `--redo`). `--to txt` runs pdftotext on the OCRed result.
- Missing tesseract/ocrmypdf → exit 3 + hint. Language pack missing → surface tesseract's error + `apt install tesseract-ocr-<lang>` hint.

## JSON
`{"src":..., "dest":..., "engine":"ocrmypdf|tesseract", "chars": <len of extracted text>}`

## Acceptance
- OCR the scanned-style fixture image → text contains a known word (fixture generated with large clear text). ocrmypdf on image-only fixture PDF yields searchable text via pdftotext. Skip tests if binaries absent.
