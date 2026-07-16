# STATE

> Live status of the build. A brand-new session should be able to resume from this file alone.
> Directive: the original build prompt (mission, phases, Definition of Done) — key points mirrored in docs/BUILD_PLAN.md once written. Approved plan copy: `~/.claude/plans/quiet-orbiting-feigenbaum.md`.

## Now

- **Phase:** 4 — Waves 1-3 DONE — **MVP line crossed**: 20 commands live, marketplace validates (claude plugin validate ✔), 470 tests green. Wave 4 (flagship) dispatching.
- **Next:** Wave 4: audiobook, desk TUI, snippets/cookbook seeds, integration review sweep.

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
