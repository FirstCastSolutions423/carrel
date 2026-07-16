# DECISIONS

Format: `D-NNN (date) — decision — rationale — consequences`.

## D-001 (2026-07-16) — Marketplace schema locked to live docs

Fetched https://code.claude.com/docs/en/plugin-marketplaces and /plugins-reference during planning. Confirmed shape: `.claude-plugin/marketplace.json` at repo root (`name`, `owner`, `plugins[]` with `name` + `source: "./plugins/<n>"`, optional `metadata.pluginRoot`); each plugin has `plugins/<n>/.claude-plugin/plugin.json` (only `name` required) with default-scanned `commands/`, `skills/<skill>/SKILL.md`, `agents/`, `hooks/hooks.json`, `.mcp.json`; scripts use `${CLAUDE_PLUGIN_ROOT}`. Validation: `claude plugin validate`. Install: `claude plugin marketplace add` + `claude plugin install <p>@<m>`. Consequence: scaffold conforms to this; re-check cheaply at Phase 2.

## D-002 (2026-07-16) — Stack: Python ≥3.12 + uv

Dev box has Python 3.14.4 and uv 0.11. Python's file-format ecosystem (pypdf, Pillow, etc.) beats Node's for this capability set; uv makes installs fast and reproducible. External binaries only via one adapter layer with capability detection; `doctor` command re-probes. Consequence: `pyproject.toml` project, `uv run pytest`, entry points via `[project.scripts]`.

## D-003 (2026-07-16) — Flagship experience: Textual TUI

TUI dashboard (file browser + inspector + actions) sharing the core library with the CLI. Chosen over local web UI: finishable in one session, impressive in a terminal-first WSL environment, zero extra runtime surface. Fallback if it slips: cut to a rich-based interactive picker and document in FEATURES.md.

## D-004 (2026-07-16) — No forced installs of optional binaries

Phase 0 only inventories. Features degrade gracefully (exit 3 + install hint); `doctor` prints per-feature status. Bias from the directive honored.
