# STATE

> Live status of the build. A brand-new session should be able to resume from this file alone.
> Directive: the original build prompt (mission, phases, Definition of Done) — key points mirrored in docs/BUILD_PLAN.md once written. Approved plan copy: (local Claude Code plan file — path generalized).

## Now

- **Phase:** 7 — DONE. finalize.sh tested (dry + real + rename round-trip, suite green post-rename). BUILD COMPLETE.
- **Next:** nothing — run scripts/finalize.sh when ready to relocate/publish.

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
