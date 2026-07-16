# spec: core (adapters, output, filetypes, textextract, db, product)

**Owns:** `src/carrel/core/*`, `src/carrel/__init__.py`, `src/carrel/_product.py` (generated), `src/carrel/cli.py`, `scripts/sync_product.py`, `tests/test_core*.py`.

## Purpose
Foundation every command builds on. Interfaces are BINDING as written in docs/ARCHITECTURE.md §Global contracts — implement exactly that API.

## Details beyond ARCHITECTURE.md
- `adapters.ADAPTERS` must cover: pandoc, pdftotext, pdftoppm, pdfimages, qpdf, gs, weasyprint, tesseract, ocrmypdf, magick (candidates: magick, convert), exiftool, ffmpeg, pngquant, icotool, jq, mlr, rg, fd (fd, fdfind), sqlite3, inotifywait, espeak-ng (also: piper, edge-tts as preferred-TTS probes), gpg, claude.
- `run()` uses `require()` internally, captures stdout/stderr as text by default, `binary=True` opt-out.
- `cli.py`: click group; `--version` from `_product.py`; `COMMANDS` lazy map; central try/except for `MissingDependencyError` (exit 3) and `CarrelInputError` (exit 4); `--debug` re-raises.
- `textextract.extract_text(path, ocr=False) -> str`: txt/md read; html→text (strip tags, stdlib HTMLParser); json/xml/csv pretty-flatten; pdf via pdftotext (if `ocr` and empty text and ocrmypdf present → OCR temp copy first); images: return "" unless `ocr` (tesseract). Raises CarrelInputError on unsupported.
- `db.DeskDB`: as schema'd; plus `upsert_file(path) -> id`, `iter_files()`, helper `fts_search(query, limit)`.
- `filetypes.detect`: exts .pdf .md .jpg .jpeg .png .ico .txt .html .htm .json .xml .csv; magic sniff for pdf/png/jpeg/ico.

## Acceptance
- `uv run carrel --version` prints name+version from product.json copy.
- `uv run carrel badcmd` → exit 2. `python -c "from carrel.core import adapters; print(adapters.have('pandoc'))"` → True on this box.
- Unit tests: detect() on fixture files; extract_text on txt/md/json/html; DeskDB roundtrip (upsert, fts insert+search, tag, note); adapters.require('nonexistent-tool-xyz') raises with hint.
