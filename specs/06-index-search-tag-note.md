# spec: index + search + tag + note (desk DB commands)

**Owns:** `src/carrel/commands/{index,search,tag,note}.py`, `tests/test_desk_db_cmds.py`. Uses `core.db.DeskDB` — do not open sqlite directly.

## index
`carrel index [PATH...] [--root DIR] [--ocr] [--prune] [--json]`
Default PATH: root. Walk supported types, skip unchanged (mtime+size vs files row), extract text (textextract), upsert files + FTS. `--prune` removes rows for missing paths. Human output: progress to stderr, summary table. JSON: `{"indexed":N,"skipped":N,"pruned":N,"errors":[...]}`.

## search
`carrel search QUERY [--root DIR] [--limit 20] [--type pdf,md] [--tag TAG] [--json] [--fail-empty]`
FTS5 match with bm25 rank; snippet() highlights. Filters combine (AND). Human: rank, path, snippet. JSON: `[{"path","score","snippet"}]`. `--fail-empty` → exit 5 on no hits.

## tag
`carrel tag add PATH TAG... | rm PATH TAG... | ls [PATH] | find TAG [--json]`
Tags normalized lowercase; `find` lists files having ALL given tags. Auto-registers file in files table if absent.

## note
`carrel note add PATH "text" | ls PATH [--json]` — sidecar notes (DeskDB), newest first, timestamps ISO.
`carrel note pdf PATH` — list PDF annotations (pypdf): page, subtype, contents.
`carrel note pdf-add PATH "text" [--page 1] [--pos x,y] [-o OUT]` — add a text annotation (pypdf FreeText or Text/"sticky note").

## Acceptance
index fixtures → search finds pdf-embedded word and md word; unchanged reindex skips all; tag add/find roundtrip; note add/ls; pdf-add then `note pdf` lists it (pypdf reads own annotation); `--fail-empty` exit 5.
