# spec: desk (flagship TUI)

**Owns:** `src/carrel/desk/*`, `src/carrel/commands/desk.py`, `tests/test_desk.py`.

## CLI
`carrel desk [ROOT]` — launches textual app. Missing textual → exit 3 hint (it's a core dep, but guard anyway).

## Layout (textual)
- Left: `DirectoryTree(ROOT)` filtered to supported types + dirs.
- Center: Inspector panel — on selection, render `inspect` data (reuse command's collector function, NOT CLI), plus text preview (first 200 lines via textextract, lazy) and image preview placeholder (dimensions + palette swatches as colored blocks).
- Right: Actions list for selection: Convert→(pdf/txt/md/html/png), OCR, Thumbnail, Pack (dir), Index root, Tag…, Note… . Actions call core command functions in a worker thread; results/toasts via `notify()`; outputs to `<root>/carrel-out/`.
- Bottom bar: search input → DeskDB fts_search, results clickable (jump tree).
- Keys: `q` quit, `/` focus search, `enter` open action menu, `t` tag prompt, `n` note prompt.
- Theme: brand colors from docs/BRAND.md once written (fallback: textual defaults + accent #E8A13D-ish; final palette in Phase 6 applied via CSS vars).

## Design constraints
Zero business logic: every action delegates to the same functions the CLI uses (import from commands' `_impl` functions or core). Never blocks the event loop (workers). Errors → toast, never crash.

## Acceptance
`tests/test_desk.py` uses textual's `App.run_test()` pilot: app boots on fixtures dir, tree renders, selecting a file populates inspector, search box returns a known hit (pre-indexed fixture root), an action (thumb on png) writes to carrel-out. Headless-safe.
