# spec: inspect + diff

**Owns:** `src/carrel/commands/inspect.py`, `src/carrel/commands/diff.py`, `tests/test_inspect.py`, `tests/test_diff.py`.

## inspect CLI
`carrel inspect PATH [--json] [--deep]`
Always: name, size, mtime, detected type, sha256 (files <512MB), mime guess.
Per type: pdf → pages, title/author/producer, encrypted?, form fields count, annotations count (pypdf); images → dimensions, mode, EXIF summary (Pillow; `--deep` + exiftool → full tag table); json → top-level shape, key count, depth; csv → dialect, columns, row count; xml → root tag, element count, depth; html → title, headings outline, link/img counts; md → headings outline, word count; txt → lines/words/chars.
`--deep` uses exiftool when present (degrade silently to builtin summary — inspect never exits 3, it annotates `"exiftool": "not installed"`).

## diff CLI
`carrel diff A B [--json] [--mode auto|text|struct|image|pdf]`
- auto by type pair. text: unified diff (difflib), colorized human output.
- struct (json/csv/xml): key/row-level added/removed/changed lists (json: dotted paths; csv: row index + column).
- pdf: extract text both sides → unified diff; note page counts.
- image: dimensions + pixel-diff percentage + mean channel delta (Pillow); `--out heatmap.png` optional diff visualization.
- Exit 0 identical, 1 different (documented; `--json` includes `"identical": bool`). Type mismatch → auto falls back to text if both text-ish, else exit 4.

## Acceptance
inspect on every fixture type returns sane JSON (golden-ish assertions on keys). diff: identical file → exit 0; modified json → changed path listed; image pair → percentage >0; pdf pair text diff non-empty.
