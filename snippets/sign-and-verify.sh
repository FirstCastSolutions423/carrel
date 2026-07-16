#!/usr/bin/env bash
# sign-and-verify.sh — hash-manifest a folder, GPG-sign it if you have a key, verify.
#
# What it does:
#   1. `carrel sign manifest` writes FOLDER.MANIFEST.sha256 covering every file
#      under FOLDER (sha256sum format — verifiable with plain `sha256sum -c`).
#      The manifest lives BESIDE the folder, not inside it — a manifest inside
#      the tree it covers would hash its own stale self on the next run and
#      always fail verification.
#   2. If your gpg keyring has a secret key, adds a detached armored signature
#      MANIFEST.sha256.asc; otherwise it says so and continues unsigned.
#   3. `carrel sign verify` recomputes every hash and checks the signature.
#   Re-run step 3 any time to prove the folder hasn't changed.
#
# Requirements: carrel on PATH; gpg only for the signature step.
# Usage:
#   ./sign-and-verify.sh ~/deliverables
#   GPG_KEY=me@example.com ./sign-and-verify.sh ~/deliverables   # pick a key
# Override the CLI with e.g. CARREL="uv run carrel".

set -euo pipefail

CARREL="${CARREL:-carrel}"   # intentionally unquoted below: may hold "uv run carrel"
FOLDER="${1:?usage: sign-and-verify.sh FOLDER}"
MANIFEST="${FOLDER%/}.MANIFEST.sha256"   # beside the folder, never inside it

SIGN_ARGS=()
if [[ -n "${GPG_KEY:-}" ]]; then
  SIGN_ARGS=(--key "$GPG_KEY")
elif command -v gpg >/dev/null 2>&1 \
     && gpg --list-secret-keys --with-colons 2>/dev/null | grep -q '^sec'; then
  SIGN_ARGS=(--gpg)
else
  echo "note: no gpg secret key found — writing an unsigned manifest."
fi

echo "==> writing $MANIFEST"
$CARREL sign manifest "$FOLDER" -o "$MANIFEST" --force "${SIGN_ARGS[@]}"

echo
echo "==> verifying"
$CARREL --json sign verify "$MANIFEST"
