# STATE

> Live status of the build. A brand-new session should be able to resume from this file alone.
> Directive: the original build prompt (mission, phases, Definition of Done) — key points mirrored in docs/BUILD_PLAN.md once written. Approved plan copy: `~/.claude/plans/quiet-orbiting-feigenbaum.md`.

## Now

- **Phase:** 6 — DONE. Visual identity (4 SVGs, BRAND.md), README hero+grid, full docs package (16 docs), CI workflow, 9 executed cookbook recipes. 501 tests green.
- **Next:** Phase 7 — finalize.sh real temp-dir run + rename test, DoD report.

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
