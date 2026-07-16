#!/usr/bin/env bash
# finalize.sh — relocate this build to its official home, confirm/set the
# product name, and establish the official git repo.
#
# Usage:
#   scripts/finalize.sh [--dest <path>] [--name <final-name>] [--fresh-history]
#                       [--push [--visibility public|private]] [--keep-source]
#                       [--dry-run] [--force]
#
# Anything not passed as a flag is prompted for interactively.
set -euo pipefail

SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEST=""
NEW_NAME=""
FRESH_HISTORY=0
PUSH=0
VISIBILITY="private"
KEEP_SOURCE=0
DRY_RUN=0
FORCE=0

say()  { printf '\033[1;36m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33mwarning:\033[0m %s\n' "$*" >&2; }
die()  { printf '\033[1;31merror:\033[0m %s\n' "$*" >&2; exit 1; }
run()  { if [ "$DRY_RUN" -eq 1 ]; then printf '\033[2m[dry-run]\033[0m %s\n' "$*"; else "$@"; fi; }

while [ $# -gt 0 ]; do
  case "$1" in
    --dest)          DEST="${2:?--dest needs a path}"; shift 2 ;;
    --name)          NEW_NAME="${2:?--name needs a value}"; shift 2 ;;
    --fresh-history) FRESH_HISTORY=1; shift ;;
    --push)          PUSH=1; shift ;;
    --visibility)    VISIBILITY="${2:?--visibility needs public|private}"; shift 2 ;;
    --keep-source)   KEEP_SOURCE=1; shift ;;
    --dry-run)       DRY_RUN=1; shift ;;
    --force)         FORCE=1; shift ;;
    -h|--help)       sed -n '2,10p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *)               die "unknown flag: $1 (see --help)" ;;
  esac
done

case "$VISIBILITY" in public|private) ;; *) die "--visibility must be public or private" ;; esac
command -v python3 >/dev/null || die "python3 is required"
command -v git >/dev/null || die "git is required"

CURRENT_NAME="$(python3 -c "import json; print(json.load(open('$SOURCE_DIR/product.json'))['name'])")"
VERSION="$(python3 -c "import json; print(json.load(open('$SOURCE_DIR/product.json'))['version'])")"

# ---------------------------------------------------------------- 1. name
say "current product name: $CURRENT_NAME (v$VERSION)"
if [ -z "$NEW_NAME" ] && [ -t 0 ]; then
  read -r -p "Keep the name '$CURRENT_NAME'? [Y/n or type a new name] " reply
  case "$reply" in
    ""|y|Y|yes) NEW_NAME="$CURRENT_NAME" ;;
    n|N|no)     read -r -p "New name (lowercase, cli-friendly): " NEW_NAME ;;
    *)          NEW_NAME="$reply" ;;
  esac
fi
NEW_NAME="${NEW_NAME:-$CURRENT_NAME}"
if ! printf '%s' "$NEW_NAME" | grep -Eq '^[a-z][a-z0-9-]{1,30}$'; then
  die "name '$NEW_NAME' is not CLI-friendly (want ^[a-z][a-z0-9-]{1,30}$)"
fi

if [ "$NEW_NAME" != "$CURRENT_NAME" ]; then
  say "renaming $CURRENT_NAME -> $NEW_NAME (centralized via product.json)"
  if [ "$DRY_RUN" -eq 1 ]; then
    printf '\033[2m[dry-run]\033[0m update product.json + scripts/rename_product.py\n'
  else
    python3 "$SOURCE_DIR/scripts/rename_product.py" "$NEW_NAME"
    ( cd "$SOURCE_DIR" && git add -A && git commit -q -m "rename: $CURRENT_NAME -> $NEW_NAME" )
  fi
fi

# ---------------------------------------------------------------- 2. relocate
if [ -z "$DEST" ] && [ -t 0 ]; then
  read -r -p "Destination directory [~/projects/$NEW_NAME]: " DEST
fi
DEST="${DEST:-$HOME/projects/$NEW_NAME}"
DEST="$(python3 -c "import os,sys; print(os.path.abspath(os.path.expanduser(sys.argv[1])))" "$DEST")"
[ "$DEST" = "$SOURCE_DIR" ] && die "destination equals the source directory"

if [ -e "$DEST" ] && [ -n "$(ls -A "$DEST" 2>/dev/null)" ] && [ "$FORCE" -eq 0 ]; then
  die "destination $DEST is not empty (pass --force to use it anyway)"
fi

say "relocating to $DEST $([ "$KEEP_SOURCE" -eq 1 ] && echo '(copy — source kept)' || echo '(move)')"
run mkdir -p "$DEST"
if [ "$DRY_RUN" -eq 1 ]; then
  printf '\033[2m[dry-run]\033[0m copy tree %s -> %s\n' "$SOURCE_DIR" "$DEST"
else
  # tar-pipe copy preserves permissions; excludes venv/caches (rebuilt by uv)
  ( cd "$SOURCE_DIR" && tar --exclude=.venv --exclude=__pycache__ --exclude=.pytest_cache -cf - . ) \
    | ( cd "$DEST" && tar -xf - )
fi

# ---------------------------------------------------------------- 3. git
if [ "$FRESH_HISTORY" -eq 1 ]; then
  say "re-initializing git history"
  run rm -rf "$DEST/.git"
  if [ "$DRY_RUN" -eq 0 ]; then
    ( cd "$DEST" && git init -qb main && git add -A \
      && git commit -qm "release: $NEW_NAME v$VERSION" )
  else
    printf '\033[2m[dry-run]\033[0m git init + release commit in %s\n' "$DEST"
  fi
else
  say "preserving full dev history"
  if [ "$DRY_RUN" -eq 0 ]; then
    ( cd "$DEST" && git add -A \
      && git commit -qm "release: $NEW_NAME v$VERSION" --allow-empty )
  else
    printf '\033[2m[dry-run]\033[0m release commit in %s\n' "$DEST"
  fi
fi
if [ "$DRY_RUN" -eq 0 ]; then
  ( cd "$DEST" && git tag -f "v$VERSION" >/dev/null )
else
  printf '\033[2m[dry-run]\033[0m git tag v%s\n' "$VERSION"
fi

# ---------------------------------------------------------------- 4. remote
REMOTE_MSG="no remote configured"
if [ "$PUSH" -eq 1 ]; then
  if command -v gh >/dev/null && gh auth status >/dev/null 2>&1; then
    say "creating GitHub repo ($VISIBILITY) and pushing"
    if [ "$DRY_RUN" -eq 0 ]; then
      ( cd "$DEST" && gh repo create "$NEW_NAME" "--$VISIBILITY" --source=. --push )
      REMOTE_MSG="pushed to GitHub: $(cd "$DEST" && gh repo view --json url -q .url 2>/dev/null || echo '?')"
    else
      printf '\033[2m[dry-run]\033[0m gh repo create %s --%s --source=. --push\n' "$NEW_NAME" "$VISIBILITY"
      REMOTE_MSG="[dry-run] would push to GitHub"
    fi
  else
    warn "gh is missing or not authenticated — push skipped"
    REMOTE_MSG="push manually:
    cd $DEST
    gh auth login          # one-time GitHub authentication
    gh repo create $NEW_NAME --$VISIBILITY --source=. --push"
  fi
else
  REMOTE_MSG="to publish later:
    cd $DEST
    gh repo create $NEW_NAME --private --source=. --push"
fi

# ---------------------------------------------------------------- 5. source cleanup + summary
if [ "$KEEP_SOURCE" -eq 0 ] && [ "$DRY_RUN" -eq 0 ]; then
  warn "source directory left in place: $SOURCE_DIR (delete manually once you've verified the new location — this script never deletes the source itself)"
fi

say "───────────────────────────────────────────"
say "product:   $NEW_NAME v$VERSION"
say "location:  $DEST"
say "git:       $([ "$FRESH_HISTORY" -eq 1 ] && echo 'fresh history' || echo 'full dev history'), tagged v$VERSION"
say "remote:    $REMOTE_MSG"
say "next:      cd $DEST && uv sync && uv run $NEW_NAME doctor"
[ "$DRY_RUN" -eq 1 ] && say "(dry run — nothing was changed)"
exit 0
