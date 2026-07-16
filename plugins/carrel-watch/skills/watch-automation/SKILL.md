---
name: watch-automation
description: Recipes for automating folders with carrel watch — auto-thumbnail new images, auto-index documents into the desk db, auto-convert a drop folder. Use when the user wants something to happen automatically whenever files land in or change inside a directory.
---

# Folder automation recipes with `carrel watch`

`carrel watch DIR --on EVENTS --run CMD` runs shell actions on file events (watchdog-based). `{path}` in the action is substituted with the triggering file, already shell-quoted. Multiple `--run` flags execute in order. `--debounce MS` collapses editor save-storms. Use `--once` or `--timeout SECS` for bounded test runs, `--json-lines` for machine-readable logs. Ctrl-C exits cleanly.

Before composing a recipe, run `carrel watch --help` to confirm the installed version has the flags you plan to use.

## Recipe: auto-thumbnail new images

```bash
carrel watch ~/Pictures/incoming --on created --glob '*.png' \
  --run 'carrel thumb {path} --out-dir ~/Pictures/thumbs'
```

Add a second `--glob`-less watch or broaden the glob for jpg. Thumbnails land in `--out-dir`; the watch ignores files its own actions write.

## Recipe: auto-index documents into the desk db

Keep `carrel search` results fresh as files arrive:

```bash
carrel watch ~/Documents/desk --on created,modified \
  --run 'carrel --root ~/Documents/desk index --update {path} --if-indexed'
```

`--update` (re)indexes just the touched file; `--if-indexed` makes it a silent no-op until someone has run `carrel index` once — safe to leave running.

## Recipe: auto-convert a drop folder

Everything dropped as markdown comes out as PDF:

```bash
carrel watch ~/dropbox/md-in --on created --glob '*.md' \
  --run 'carrel convert {path} --to pdf --out-dir ~/dropbox/pdf-out'
```

Chain steps with repeated `--run` (they execute sequentially per event), e.g. convert then index the output directory.

## Operational notes

- Long-running: start it in the background (`&`, tmux, or a systemd user unit) and tell the user how to stop it.
- Debounce editors: `--debounce 500` (ms) avoids double-firing on save.
- Self-triggering is guarded (in-flight outputs are ignored), but keep action outputs out of the watched glob when possible — e.g. write thumbs to a sibling directory.
- Test any recipe first with `--once --timeout 30` and a `touch` in another shell.
