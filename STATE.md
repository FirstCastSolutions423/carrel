# STATE

> Live status of the build. A brand-new session should be able to resume from this file alone.
> Directive: the original build prompt (mission, phases, Definition of Done) — key points mirrored in docs/BUILD_PLAN.md once written. Approved plan copy: `~/.claude/plans/quiet-orbiting-feigenbaum.md`.

## Now

- **Phase:** 4 — Wave 1 DONE (fixtures, core tests, doctor, mcp, pack, edit; 163 tests green; core bugs fixed: lazy --help, hinted require()). Wave 2 dispatching.
- **Next:** Wave 2: convert, ocr, inspect+diff, index/search/tag/note. Then wave(2) commit.

## Done

- git init (branch `main`)
- CLAUDE.md, STATE.md, docs/DECISIONS.md created
- Plugin marketplace schema verified against live docs (2026-07-16) — see docs/DECISIONS.md D-001

## Open issues

- (none yet)

## Key facts for a fresh session

- Stack: Python + uv (decided, see DECISIONS.md). Flagship: Textual TUI.
- Product: **carrel** (product.json is the SoT). Tagline: "A library desk for your files — and your agents."
- Marketplace install flow to validate in Phase 5: `claude plugin validate .` → `claude plugin marketplace add <path>` → `claude plugin install <plugin>@<marketplace>`.
