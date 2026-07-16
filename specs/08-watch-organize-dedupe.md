# spec: watch + organize + dedupe

**Owns:** `src/carrel/commands/{watch,organize,dedupe}.py`, `tests/test_watch_org_dedupe.py`.

## watch
`carrel watch DIR --on created,modified [--glob '*.pdf'] --run 'carrel thumb {path} --out-dir thumbs' [--debounce 500] [--once] [--timeout SECS] [--json-lines]`
watchdog observer; `{path}` substitution (shlex-quoted); actions run sequentially, log to stdout as JSON lines when `--json-lines` else human lines. `--once` exits after first triggered action (testable); `--timeout` hard stop (testable/demoable). SIGINT clean exit. Multiple `--run` allowed (in order). Guard: events for files being written by an action itself are ignored via an in-flight set + output-path suffix heuristic (document limits).

## organize
`carrel organize DIR [--by type|date|exif-date] [--into DIR=DIR] [--dry-run default ON, --apply to execute] [--json]`
type → subdirs pdf/, images/, data/, docs/ (mapping documented); date → YYYY/MM from mtime; exif-date → EXIF DateTimeOriginal fallback mtime (images only, others skip). Collision policy: append `-1`, `-2`. Dry-run prints plan; `--apply` moves (os.replace within fs). JSON: [{src, dest, action}].

## dedupe
`carrel dedupe DIR... [--near] [--delete newest|oldest|interactive-off] [--json]`
Exact: BLAKE2b file hash groups (size prefilter). `--near`: images only, 64-bit dHash (custom, Pillow, no numpy), hamming ≤ 8 clusters. Default: report only. `--delete` requires `--apply` too (double safety); never deletes the kept member; prints reclaimable bytes. JSON: [{hash, files:[...], kept, deleted:[...]}].

## Acceptance
watch --once: touch file in tmpdir triggers echo action (integration test with timeout); organize dry-run plans type layout on fixtures copy, --apply moves; dedupe finds planted duplicate pair, --near clusters resized copy of same image; nothing deleted without --apply.
