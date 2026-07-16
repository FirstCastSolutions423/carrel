---
name: context-packing
description: When and how to bundle local folders/files into LLM context with carrel pack — format choice, token budgeting, chunking, include/exclude strategy. Use when preparing documents or a codebase-adjacent folder as context for an LLM, or when a pack would blow the context window.
---

# Context packing with `carrel pack`

`carrel pack PATHS...` turns files and folders into a single LLM-ready document. This skill covers choosing settings that fit a context window instead of flooding it.

## When to pack

- The user wants an LLM (this session or another) to "read" a folder of documents.
- You need repeatable, shareable context (a file you can re-attach) rather than ad-hoc Reads.
- Many small files are involved — one pack beats dozens of Read calls.

Don't pack when the user needs 1-2 specific files — just read those.

## Decision procedure

1. **Size it first.** `carrel pack DIR --stats` prints a per-file token table (estimates are `ceil(chars/3.6)`, labeled `tokens_est`). Alternatively `--tree-only` shows structure without contents.
2. **Choose a format.**
   - `--format xml` for Claude — CDATA-wrapped `<file>` sections parse robustly.
   - `--format md` (default) for humans and most models — fenced sections, fences auto-lengthen on collision.
   - `--format json` when a program will consume the pack.
3. **Trim before you chunk.** Prefer `--exclude`/`--include` globs (repeatable) over huge chunk counts: exclude build output, archives, fixtures. `.gitignore` is already honored (no negation patterns; `.git`/`.carrel` always skipped). Binaries outside the supported types are tree-listed, never inlined.
4. **Set budgets.**
   - Fits comfortably (rule of thumb: ≤ half the model's window, e.g. ≲80k tokens for a 200k window): single pack, `-o context.md`.
   - Too big: `--chunk TOKENS -o out.md` → `out.part1..N`, each ≤ TOKENS estimated tokens. Files are never split mid-file unless one alone exceeds the budget (then split on line boundaries with "(continued)" markers). Pick TOKENS ≈ what one turn can afford, e.g. 30000–60000.
   - Hard caps: `--max-bytes N` (total) and `--max-file-bytes N` (skip single huge files); omissions are noted in the pack header — mention them to the user.
5. **Images/scans:** only read with `--ocr` (needs tesseract/ocrmypdf); otherwise they're listed but contribute no text.

## Examples

```bash
# Gauge a folder
carrel pack ./papers --stats

# Claude-friendly single pack of only the PDFs and notes
carrel pack ./papers --format xml --include '*.pdf' --include '*.md' -o papers.xml

# Big corpus, 40k-token chunks, skip anything over 2 MB
carrel pack ./archive --chunk 40000 --max-file-bytes 2000000 -o archive.md

# Structure-only orientation pass
carrel pack ./unknown-folder --tree-only
```

## Interpreting results

Report to the user: output path(s), `tokens_est` total, and anything the header says was omitted (budget hits, skipped binaries). If chunked, say how many parts and suggest feeding them in order.
