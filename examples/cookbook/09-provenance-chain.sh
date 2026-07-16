#!/usr/bin/env bash
# 09 — Provenance chain
#
# Proves a folder of deliverables hasn't changed: write a sha256 manifest,
# GPG-sign it with a throwaway key (ephemeral GNUPGHOME — your real keyring is
# never touched), verify the chain, then tamper with a file and watch
# verification fail with exit 1. Requires: gpg.
#
# The manifest is written BESIDE the folder, never inside it — a manifest
# inside the tree it covers would hash its own stale self and always fail.
#
# Expected: signed manifest + .asc, a passing verify, a failing verify (exit 1)
# after tampering, then RECIPE OK.
set -euo pipefail
cd "$(dirname "$0")/../.."
CARREL="${CARREL:-uv run carrel}"

command -v gpg >/dev/null || { echo "gpg is required: sudo apt install gnupg" >&2; exit 3; }

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

echo "==> assemble a deliverables folder"
deliv="$work/deliverables"
mkdir -p "$deliv"
cp tests/fixtures/sample.md tests/fixtures/sample.csv tests/fixtures/text+image.pdf "$deliv/"

echo "==> create a throwaway gpg key (ephemeral keyring, no passphrase)"
export GNUPGHOME="$work/gnupg"
mkdir -p "$GNUPGHOME"; chmod 700 "$GNUPGHOME"
gpg --batch --pinentry-mode loopback --passphrase '' \
    --quick-generate-key 'Cookbook Demo <demo@cookbook.invalid>' ed25519 sign 0 2>/dev/null
gpg --list-secret-keys --with-colons | grep -q '^sec' && echo "  ephemeral key ready"

manifest="$work/deliverables.MANIFEST.sha256"   # beside the folder, not inside

echo "==> sign: sha256 manifest + detached armored signature"
$CARREL sign manifest "$deliv" -o "$manifest" --key demo@cookbook.invalid
ls -la "$manifest" "$manifest.asc"
head -3 "$manifest"

echo "==> verify the untouched folder (must pass)"
$CARREL --json sign verify "$manifest" | python3 -m json.tool

echo "==> tamper: flip one byte in the csv"
printf 'x' | dd of="$deliv/sample.csv" bs=1 seek=5 conv=notrunc status=none

echo "==> verify again — MUST fail with exit 1"
rc=0
$CARREL --json sign verify "$manifest" > "$work/verify2.json" || rc=$?
python3 -m json.tool < "$work/verify2.json" || true
[ "$rc" -eq 1 ] || { echo "expected exit 1 on tamper, got $rc" >&2; exit 1; }
echo "  tamper detected (exit $rc) — chain broken as it should be"

echo "RECIPE OK"
