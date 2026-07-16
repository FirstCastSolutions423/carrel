---
name: agent-workflows
description: Looping and pipeline patterns that combine carrel with Claude Code — watch + claude -p pipelines, index-then-ask loops, MCP-backed desk queries. Use when the user wants recurring or automated agentic processing of local files rather than a one-off command.
---

# Agent workflows with carrel

Patterns for wiring `carrel` and Claude Code together into pipelines. Run `carrel doctor --json` first to see what the environment supports, and `--help` on any carrel command before scripting it.

## Pattern: watch + `claude -p` pipeline

React to new files with a headless Claude turn. Example — summarize every PDF dropped into a folder:

```bash
carrel watch ~/inbox --on created --glob '*.pdf' \
  --run 'sh -c "carrel convert {path} --to txt -o /tmp/drop.txt --force && claude -p \"Summarize /tmp/drop.txt in 5 bullets\" >> ~/inbox/summaries.md"'
```

Notes: keep the `claude -p` prompt self-contained; append results to a log/markdown file; test with `--once --timeout 60` before leaving it running. (Confirm `carrel watch` exists in the installed version.)

## Pattern: index-then-ask loop

For question-answering over a collection, keep one desk index and reuse it:

```bash
carrel --json --root ~/papers index          # incremental, cheap to re-run
carrel --json --root ~/papers search 'transformer AND survey'
```

Feed the hit paths to Claude (or the `file-librarian` agent in this plugin) rather than packing the whole corpus — search first, read the top hits, cite paths.

## Pattern: desk over MCP

This plugin ships a `carrel` MCP server (`carrel mcp`, stdio) exposing `search`, `pack`, and `inspect` as tools. When it's connected, prefer the MCP tools over shelling out for those three operations — same results, structured output. The server searches the desk under the session's working directory; run `carrel index` there first.

## Pattern: pack for a second opinion

Bundle context for another model/session: `carrel pack DIR --format xml --chunk 40000 -o ctx.xml` then feed `ctx.xml.part1..N` sequentially. See the `context-packing` skill (carrel-inspect plugin) for budgeting guidance.

## Hygiene for all loops

- Idempotence: carrel index is incremental and `--if-indexed` makes hook-style reindexing a no-op until a desk exists — loops can run unconditionally.
- Never delete in a loop: `carrel dedupe` stays report-only unless both `--delete` and `--apply` are passed; keep automation on the report side.
- Budget: bound every unattended loop with `--timeout`, log with `--json-lines`, and route long outputs to files, not the terminal.
