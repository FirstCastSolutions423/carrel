#!/usr/bin/env bash
# 08 — Pack a repo for Claude
#
# Bundles a small project into LLM-ready context three ways: a --stats token
# budget pass, a single Claude-friendly XML pack, and token-budgeted chunks.
# Runs entirely offline against a synthetic mini-repo built in a temp dir, so
# the output is deterministic. Requires: nothing beyond carrel (pack is pure
# python).
#
# Follow-on (not run here, needs the Claude CLI + network): feed the pack in —
#   claude -p "Summarize this codebase: $(cat ctx.xml)" --allowedTools ""
# or paste ctx.md.part1..N into a session in order.
#
# Expected: a token table, an XML pack with a CDATA-wrapped <file> per source
# file, 2+ chunk parts each under the budget, then RECIPE OK.
set -euo pipefail
cd "$(dirname "$0")/../.."
CARREL="${CARREL:-uv run carrel}"

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

echo "==> build a synthetic mini-repo (deterministic input)"
repo="$work/mini-repo"
mkdir -p "$repo/src" "$repo/docs" "$repo/build"
cat > "$repo/README.md" <<'EOF'
# mini-repo
A tiny fake project used to demonstrate carrel pack.
Sentinel phrase: ultramarine gazetteer.
EOF
for i in 1 2 3; do
  {
    echo "\"\"\"module $i of mini-repo.\"\"\""
    for line in $(seq 1 120); do
      echo "def fn_${i}_${line}(x: int) -> int: return x + ${line}  # padding line"
    done
  } > "$repo/src/module$i.py"
done
printf '{"name": "mini-repo", "version": "1.0.0"}\n' > "$repo/docs/meta.json"
head -c 2048 /dev/zero > "$repo/build/junk.bin"          # binary, gitignored
printf 'build/\n' > "$repo/.gitignore"

echo "==> pass 1: size it first (--stats prints a per-file token table)"
$CARREL pack "$repo" --stats | tee "$work/stats.txt"
grep -q 'README.md' "$work/stats.txt"
if grep -q 'junk.bin' "$work/stats.txt"; then
  echo "gitignored build/junk.bin leaked into the pack" >&2; exit 1
fi

echo "==> pass 2: single Claude-friendly pack (--format xml, CDATA sections)"
$CARREL pack "$repo" --format xml -o "$work/ctx.xml"
grep -c '<file ' "$work/ctx.xml" | xargs echo "  <file> sections:"
grep -q 'CDATA' "$work/ctx.xml"
grep -q 'ultramarine gazetteer' "$work/ctx.xml"   # contents really inlined
echo "  head of the pack:"
head -c 300 "$work/ctx.xml"; echo

echo "==> pass 3: chunked pack (--chunk 4000 tokens, requires -o)"
$CARREL pack "$repo" -o "$work/ctx.md" --chunk 4000
ls -1 "$work"/ctx.md.part*
parts=$(ls -1 "$work"/ctx.md.part* | wc -l)
[ "$parts" -ge 2 ] || { echo "expected >=2 parts, got $parts" >&2; exit 1; }
for p in "$work"/ctx.md.part*; do
  # tokens_est is ceil(chars/3.6); sanity-check each part against the budget
  chars=$(wc -c < "$p")
  est=$(( (chars + 3) * 10 / 36 ))
  echo "  $(basename "$p"): $chars chars ≈ $est tokens_est"
  [ "$est" -le 4400 ] || { echo "part exceeds budget" >&2; exit 1; }
done

echo "==> next step (manual): feed ctx.xml or the .part files to Claude in order"
echo "RECIPE OK"
