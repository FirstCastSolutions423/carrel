# spec: edit

**Owns:** `src/carrel/commands/edit.py`, `tests/test_edit.py`.

## CLI (subgroup)
- `carrel edit pdf SRC [--merge B.pdf...] [--split] [--pages 1-3,7] [--rotate 90] [-o OUT] [--force]`
  merge (pypdf, SRC+list order), split (one pdf per page → out-dir), pages (extract range), rotate (all or `--pages`). qpdf used for `--linearize`/`--decrypt PW` extras when present; pypdf primary.
- `carrel edit image SRC [--resize WxH|50%] [--rotate DEG] [--crop X,Y,W,H] [--strip] [--quality N] [-o OUT]` (Pillow; `--strip` drops EXIF).
- `carrel edit text SRC --find PAT --replace REP [--regex] [-i/--in-place] [-o OUT]` (txt/md/html/csv-as-text).
- `carrel edit json SRC --set a.b.c=VALUE | --del a.b.c [-o OUT]` (dotted path; VALUE parsed as JSON then string fallback).
All emit `--json` result records; refuse silent overwrite (need `-o`, `--in-place`, or `--force`).

## Acceptance
merge 2 fixture pdfs → page count = sum; split→N files; rotate image 90 → dimensions swapped; strip removes EXIF; text replace works regex+literal; json set/del roundtrip. Exit 4 on wrong type per subcommand.
