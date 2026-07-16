# spec: pack (context engineering)

**Owns:** `src/carrel/commands/pack.py`, `tests/test_pack.py`.

## CLI
`carrel pack PATH... [-o OUT] [--format md|xml|json] [--include GLOB]... [--exclude GLOB]... [--no-gitignore] [--max-bytes N] [--max-file-bytes N] [--chunk TOKENS] [--tree-only] [--ocr] [--stats] [--json]`

## Behavior
- Walk PATHs (files or dirs). Respect `.gitignore` (simple matcher: dir names, globs, negation NOT required — document) unless `--no-gitignore`; always skip `.git`, `.carrel`, binaries not in supported set (listed in tree as `[skipped: binary]` with size).
- Text extraction via `core.textextract` (pdf text; `--ocr` opt-in for images/scanned).
- **md format** (default): header block (generated-by, root, counts, est tokens) + fenced tree + per-file sections ` ``path`` ` with language-tagged fences (fence collision-safe: lengthen fence).
- **xml format**: `<context><tree/><file path=...><![CDATA[...]]></file></context>` (Claude-friendly).
- **json**: `{meta, tree, files:[{path, tokens_est, content}]}`.
- Token estimate: `ceil(chars/3.6)` labeled `tokens_est`.
- `--chunk N`: split output into OUT.part1..N ≤ N est-tokens each, never splitting mid-file unless single file > N (then split on line boundaries with `(continued)` markers).
- `--max-bytes`: stop adding files when budget hit; note omissions in header. `--stats`/`--json`: per-file token table, totals.
- Deterministic order: dirs-first alphabetical.

## Acceptance
Pack tests/fixtures dir → contains tree + every text fixture; excludes honored; est tokens > 0; chunking produces ≤ budget parts; xml format parses (ElementTree) with CDATA intact; binary image listed-not-inlined; `--tree-only` has no contents.
