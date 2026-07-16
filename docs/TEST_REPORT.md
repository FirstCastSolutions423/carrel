# TEST_REPORT — 2026-07-16

Everything below was executed for real on the dev machine (Ubuntu 26.04 / WSL2). Commands are copy-pasteable from the repo root.

## Suite

```
$ uv run pytest
501 passed in 49.24s
```

20 test files; fixtures for **all 11 supported types** in `tests/fixtures/` (18 files), generated idempotently by `tests/fixtures/generate.py`, including: a PDF with text + embedded image (`text+image.pdf`), an AcroForm PDF (`form.pdf`: text field + checkbox), a scanned-style image (`scanned.png`, tesseract-verified) and an image-only PDF (`scanned.pdf`). Binary-gated tests use a `needs()` skip helper; on this machine all binaries exist so nothing skips.

## Cookbook end-to-end runs (all executed, all "RECIPE OK")

| # | Recipe | Proof observed |
|---|---|---|
| 01 | scan → OCR → md → index → search | search snippet returns `CARREL OCR [FIXTURE] 42` |
| 02 | watch-folder → auto-thumbnail | watch event rc=0; 128×96 png produced |
| 03 | dedupe sweep (exact + near) | 5 files → 2 survivors, newest kept |
| 04 | redaction (txt + true pdf raster redaction) | pdf `verified: true`; leak-check: no text layer PII |
| 05 | conversion relay md→html→pdf→txt + inspect summary (4+ types) | sentinel "melodious cartography" survives the relay |
| 06 | form build + fill roundtrip | fill read-back `Ada Lovelace` / `/Yes` |
| 07 | audiobook from markdown (chapters) | 2 chapter mp3s, engine espeak-ng, 40.23s total |

Run any of them: `bash examples/cookbook/07-audiobook-from-markdown.sh`

## Marketplace validation (the hard requirement) — documented flow, executed

(Local paths in this transcript are generalized to `~/projects/...`.)

```
$ claude plugin validate .
✔ Validation passed                       # marketplace + all 5 plugin manifests

$ claude plugin marketplace add ~/projects/carrel
✔ Successfully added marketplace: carrel (declared in user settings)

$ claude plugin install carrel-inspect@carrel
✔ Successfully installed plugin: carrel-inspect@carrel (scope: user)

$ claude plugin list
❯ carrel-inspect@carrel · Version 0.1.0 · Scope user · Status ✔ enabled

$ uv tool install .                        # puts `carrel` on PATH for the plugins
$ claude -p "/carrel-inspect:inspect text+image.pdf" --allowedTools "Bash(carrel:*)"
# → Claude ran `carrel inspect --json`, summarized: 2 pages, 50 KB, ReportLab
#   producer, sha256 … (real headless run, 2026-07-16)
```

Notes: in headless `-p` mode the command needs its plugin-namespaced name (`/carrel-inspect:inspect`); in the interactive `/plugin`-managed session, `/inspect` autocompletes. The PostToolUse reindex hook was validated end-to-end in the integration review (synthetic payload → index refreshed → search finds new content; degenerate payloads exit 0).

## Integration review (adversarial, execution-based)

Full sweep of all 24 commands: `--help` exit 0, real fixture invocation, parseable `--json`, missing-file → exit 4, exit 3 verified live with a crippled adapter, no direct `subprocess` outside the adapter layer (one documented exception: `watch` runs user-supplied shell actions). Findings — all fixed and re-verified:

- **M1** `organize.md` plugin doc drifted from the real `--into CATEGORY=DIR` flag → corrected.
- **m1** `pack`/missing path exited 2 instead of 4 (click `exists=True` pre-empted the convention) → now 4.
- **m2** `audiobook` silently overwrote outputs → `--force` guard added (refusal → exit 1).
- also fixed: `sign manifest` no longer hashes its own output file; `watch-folder.md` event list completed.

## MCP server

`carrel mcp` handshake validated by pytest subprocess tests (initialize / tools/list = 3 tools / tools/call inspect / error paths) and re-checked in the review sweep with a live JSON-RPC round-trip.

## finalize.sh

Tested in Phase 7 — see the "finalize.sh test runs" section appended below.

## finalize.sh test runs (Phase 7, executed 2026-07-16)

**Dry run:** `bash scripts/finalize.sh --dry-run --dest <tmp>/final-dry --name carrel` → exit 0; prints every step ([dry-run] prefixed), changes nothing.

**Real run into a temp dir:** `bash scripts/finalize.sh --dest <tmp>/carrel-final --keep-source` → copy relocated (tar-pipe, venv/caches excluded), full dev history preserved, release commit `release: carrel v0.1.0` created, tag `v0.1.0` set, clean tree; in the copy: `uv sync` → `carrel --version` boots, tests pass.

**Centralized rename in the copy:** `python3 scripts/rename_product.py lectern` → 99 text files patched, 5 plugin dirs renamed, pyproject name + console-script renamed, `_product.py` regenerated. Verified in the renamed copy: **entire 501-test suite green**, `claude plugin validate .` ✔, `lectern --help` / `lectern doctor --json` correct. Guarantees enforced by design: the Python import package stays `carrel`; core-owned literals (`.carrel/`, `carrel.db`, `carrel.*` module paths) are protected from renaming; fixture content is name-neutral (nothing product-named is baked into committed binaries).
