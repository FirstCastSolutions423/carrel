# BUILD_PLAN

Waves of ≤4 parallel subagents. Owner types from `.claude/agents/`. Every task's acceptance = its spec's Acceptance section + CLAUDE.md command standards. Orchestrator verifies each wave by running smoke tests personally, then commits `wave(N)`.

**Constraint honored:** Wave 1 tasks must not depend on `tests/conftest.py`/fixtures (built concurrently) — they synthesize test inputs with pypdf/Pillow/stdlib in their own test files. Waves 2+ use shared fixtures.

## Wave 1 — foundations (no cross-deps)

- [x] W1.1 fixtures + conftest + core unit tests — **test-engineer** — specs/14, specs/00 acceptance — size M
- [x] W1.2 doctor + mcp — **module-builder** — specs/13 — size M
- [x] W1.3 pack — **module-builder** — specs/05 — size M
- [x] W1.4 edit — **module-builder** — specs/04 — size M

## Wave 2 — extraction & desk-db commands (need fixtures)

- [ ] W2.1 convert — **module-builder** — specs/01 — size L
- [ ] W2.2 ocr — **module-builder** — specs/02 — size S
- [ ] W2.3 inspect + diff — **module-builder** — specs/03 — size M
- [ ] W2.4 index + search + tag + note — **module-builder** — specs/06 — size M

## Wave 3 — media, automation, documents (need fixtures; marketplace independent)

- [ ] W3.1 thumb + extract-images + proof + color — **module-builder** — specs/07 — size M
- [ ] W3.2 watch + organize + dedupe — **module-builder** — specs/08 — size M
- [ ] W3.3 redact + sign + form — **module-builder** — specs/10 — size L
- [ ] W3.4 marketplace + 5 plugins — **module-builder** — specs/12 — size M

════════ **MVP LINE** — everything above must pass before anything below is attempted ════════

## Wave 4 — flagship & flourish

- [ ] W4.1 audiobook — **module-builder** — specs/09 — size S
- [ ] W4.2 desk TUI (flagship) — **module-builder** — specs/11 — size L
- [ ] W4.3 snippets/ + examples/cookbook/ seed scripts — **doc-smith** — CLAUDE.md standards — size S
- [ ] W4.4 integration review sweep — **integration-reviewer** — all specs — size M

## Phase 5+ (orchestrator-led, not waved)

- [ ] fixtures for cookbook E2E runs executed for real → docs/TEST_REPORT.md
- [ ] marketplace add + install + slash-command execution proof
- [ ] Phase 6 wave: design-artist (assets/BRAND/README) ∥ doc-smith (docs package) ∥ CI workflow
- [ ] Phase 7: finalize.sh + dry-run + temp-dir run

## Scope guards

- If a Wave 3 task slips badly: cut `proof`/`color` first, then `form build --pdf` (keep fill), then near-dupe. Log in FEATURES.md.
- If W4.2 TUI slips: reduce to two panes (tree + inspector w/ actions) before cutting.
- `recipes` runner and PAdES already cut (FEATURES.md).
