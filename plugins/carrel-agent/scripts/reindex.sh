#!/usr/bin/env bash
# PostToolUse hook (Write|Edit): re-index a file Claude just wrote, iff a desk
# index already exists. Reads the hook JSON payload from stdin, never blocks
# the session: every path out of this script is `exit 0`.
set -u

# Drain stdin first (Claude Code pipes the event JSON; leaving it unread can
# upset the pipe). Keep the payload for parsing.
payload="$(cat 2>/dev/null || true)"

# Guard: carrel must be on PATH.
command -v carrel >/dev/null 2>&1 || exit 0

# Extract tool_input.file_path and cwd from the PostToolUse payload.
file_path=""
hook_cwd=""
if command -v jq >/dev/null 2>&1; then
    file_path="$(printf '%s' "$payload" | jq -r '.tool_input.file_path // empty' 2>/dev/null || true)"
    hook_cwd="$(printf '%s' "$payload" | jq -r '.cwd // empty' 2>/dev/null || true)"
elif command -v python3 >/dev/null 2>&1; then
    parsed="$(printf '%s' "$payload" | python3 -c '
import json, sys
try:
    d = json.load(sys.stdin)
    print(d.get("tool_input", {}).get("file_path", ""))
    print(d.get("cwd", ""))
except Exception:
    pass
' 2>/dev/null || true)"
    file_path="$(printf '%s\n' "$parsed" | sed -n 1p)"
    hook_cwd="$(printf '%s\n' "$parsed" | sed -n 2p)"
fi

[ -n "$file_path" ] || exit 0
[ -f "$file_path" ] || exit 0

# Work from the session's project directory when the payload provides one.
if [ -n "$hook_cwd" ] && [ -d "$hook_cwd" ]; then
    cd "$hook_cwd" 2>/dev/null || exit 0
fi

# Guard: only refresh an index someone already created (.carrel under cwd).
[ -d .carrel ] || exit 0

# --if-indexed re-checks db existence inside carrel and exits 0 silently
# otherwise; unsupported/missing files are silently skipped.
carrel index --update "$file_path" --if-indexed >/dev/null 2>&1 || true

exit 0
