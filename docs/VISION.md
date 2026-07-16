# VISION

## The three concepts considered

### 1. carrel — "the library desk" (CHOSEN)

A *carrel* is a private study desk in a library: your working materials, close at hand, organized your way. The product is that desk for a modern local file collection — **and it treats AI agents as first-class users of the desk alongside you.**

- Every command has two audiences: pretty terminal output for humans, `--json` for agents and scripts.
- First-class **context engineering**: `carrel pack` turns files/folders into LLM-ready context (tree + contents, filters, chunking, token estimates).
- A persistent **desk index** (SQLite FTS5) makes everything searchable, taggable, annotatable.
- The repo itself is a **Claude Code plugin marketplace**: install it and Claude gets slash commands, agents, and skills that drive the same CLI.
- Flagship: a Textual TUI — the desk itself: browse, inspect, act.

### 2. bindery — "the document craftsman's bench"

Bookbinding identity (quires, folios, stamps). Strong on convert/stamp/sign/proof/annotate; weaker story for search, context packing, and agents. Charming but backward-looking: it's a metaphor for making documents, not for working with them in 2026.

### 3. flume — "files as flows"

Pipeline-first: YAML recipes, watch-folders triggering multi-step transforms, a visual pipeline builder as flagship. Most ambitious flagship, highest risk (a pipeline engine + builder UI is a session on its own), and the pipeline framing buries the individually useful tools.

## Scoring (uniqueness × feasibility, 1–5, against the probed environment)

| Concept | Uniqueness | Feasibility | Product | Notes |
|---|---|---|---|---|
| **carrel** | 4 | 5 | **20** | agent-native file toolkit is a fresh, current angle; every capability maps to a present tool or pure Python; TUI flagship well-scoped |
| bindery | 3 | 5 | 15 | feasible but generic "pdf toolbox" gravity; weak marketplace synergy |
| flume | 5 | 2 | 10 | pipeline engine + builder won't ship polished in one session |

**Decision: carrel.** It has the best synergy with the one hard requirement — a toolkit that speaks `--json` everywhere and packs context natively is exactly what makes Claude Code plugins genuinely useful rather than decorative. Name check 2026-07-16: PyPI `carrel` unclaimed (404); no dominant GitHub project (top hit ★18); no notable trademark found in a quick search.

## Product principles

1. **Two audiences, one desk.** Humans get rich output; agents get `--json` and stable exit codes. Neither is an afterthought.
2. **Wrap the masters.** pandoc, poppler, qpdf, tesseract/ocrmypdf, ImageMagick, exiftool… called through one adapter layer with capability detection. `carrel doctor` tells you what your desk can do today and how to extend it.
3. **The index is the memory.** `carrel index` + FTS5 search, tags, and notes live in one SQLite DB per root (`.carrel/`), portable and inspectable.
4. **Degrade, never crash.** Missing binary → exit 3 + install hint.
5. **The marketplace is the product too.** Plugins group by domain and delegate to the CLI — no duplicated logic.

## Flagship: `carrel desk` (Textual TUI)

Three-pane desk: file tree · inspector (metadata, preview, tags/notes) · action palette (convert, ocr, pack, thumbnail… driving the same core library). Ships after the MVP CLI is green.
