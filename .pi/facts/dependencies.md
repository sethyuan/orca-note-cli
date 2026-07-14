# Dependency Research

## mcp_dart ^2.1.0
- **Package**: `mcp_dart` on pub.dev (ID: `/websites/pub_dev_mcp_dart`)
- **Used by**: `OrcaNoteMcpClient` for MCP client communication.
- **Key API**:
  - `McpClient.callTool(CallToolRequest params)` → `Future<CallToolResult>`
  - `CallToolRequest(name: String, arguments: Map<String, dynamic>)`
  - `CallToolResult` has `.content` (list of `TextContent`, etc.), `.isError` (bool?)
  - `StreamableHttpClientTransport` for HTTP transport.
- **Already used in project**: Yes, existing tools use this API.

## args ^2.7.0
- **Used by**: CLI argument parsing for `Command<int>`, `ArgParser`, etc.
- Already used for all existing tools.

## Desktop s3_sync Tool Dependencies (for reference only)
- `@modelcontextprotocol/sdk/server/mcp.js` — `McpServer` (desktop-only)
- `zod` — schema validation (desktop-only)
- `@/libs/workers` — `invokeWorker` (desktop-only, invokes Flutter/Rust backend)
- `@/libs/windows` — window management (desktop-only, UI refresh)
