# Desktop s3_sync MCP Tool — Reference Implementation

## File
`/Users/sethyuan/dev/orca-note/src/libs/mcp/tools/s3-sync.ts`

## Registration
- Imported and registered in `/Users/sethyuan/dev/orca-note/src/libs/mcp/server.ts`:
  - `import { registerS3SyncTool } from "./tools/s3-sync"`
  - Called `registerS3SyncTool(mcpServer)` unconditionally (not hidden behind `orca-note-mcp` token check).

## Tool Definition
- **Name**: `s3_sync`
- **Title**: `S3 Sync`
- **Description**: "Sync the repository with remote S3 storage. Supports download (pull from remote) and upload (push to remote)."
- **Input schema**:
  - `repoId` (string, required) — "The repository ID."
  - `operation` (enum: `"download" | "upload"`) — "The sync operation to perform: 'download' to pull from remote, 'upload' to push to remote."

## Handler Logic
1. If `operation === "download"`:
   - Calls `invokeWorker(repoId, "downloadFromRemote", [])`
   - Reopens the repo window to refresh UI: `openRepoWindow()`, then `closeRepoWindow()`.
2. If `operation === "upload"`:
   - Calls `invokeWorker(repoId, "uploadToRemote", [])`
3. Returns `{ type: "text", text: JSON.stringify({ success: true }) }` on success.
4. On error, returns `{ type: "text", text: JSON.stringify({ success: false, error: errorMessage }) }` with `isError: true`.

## Dependencies
- `@modelcontextprotocol/sdk/server/mcp.js` — `McpServer`
- `zod` — `z` for input validation
- `@/libs/workers` — `invokeWorker`
- `@/libs/windows` — `openRepoWindow`, `closeRepoWindow`
- `@/libs/system-wide` — `locale`

## Notes
- The `download` path includes UI refresh logic (window reopen) that is desktop-specific. The CLI side should NOT replicate this; it just calls the MCP tool and receives the result.
