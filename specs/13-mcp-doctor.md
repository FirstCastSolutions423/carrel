# spec: mcp + doctor

**Owns:** `src/carrel/commands/{mcp,doctor}.py`, `tests/test_mcp_doctor.py`.

## doctor
`carrel doctor [--json]`
Iterate ADAPTERS: name, found path/version (first line), or MISSING + install_hint. Then a **capability table**: for each carrel command, status ok/degraded/unavailable + which adapter gates it (static mapping in the module). Also: python version, package version, ICC profile dirs found, tesseract langs. Exit 0 always (it's a report). `--json` full structure.

## mcp
`carrel mcp` — stdio MCP server, pure stdlib JSON-RPC 2.0 over stdin/stdout (Content-Length framing NOT used — newline-delimited JSON per MCP stdio spec: one JSON-RPC message per line).
- `initialize` → protocolVersion "2025-06-18" echo-compatible (return client's requested version if we don't know it), capabilities: {tools:{}}, serverInfo from product.
- `notifications/initialized` → ignore. `ping` → {}.
- `tools/list` → three tools with JSON Schemas: `carrel_search{query, root?, limit?}`, `carrel_pack{path, max_bytes?, tree_only?}`, `carrel_inspect{path}`.
- `tools/call` → run the same impl functions the CLI uses; result content: [{type:"text", text: JSON-or-md}] with isError on failure.
- Unknown method → JSON-RPC error -32601. Malformed line → error -32700, keep serving. EOF → clean exit 0.

## Acceptance
doctor human+json run; mcp: pytest drives it via subprocess pipes — initialize handshake, tools/list has 3 tools, tools/call carrel_inspect on fixture returns text content, unknown method errors politely.
