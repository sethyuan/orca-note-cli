# Project Structure — orca-note-cli

## Overview
- Dart CLI project using `mcp_dart` SDK (^2.1.0) for Streamable HTTP MCP client.
- Executable: `orcanote` (entry point: `bin/orcanote.dart`).
- Main entry: `lib/orca_note_cli.dart` → `runOrcaNoteCli()`.

## Key Modules

### `OrcaNoteMcpClient` (`lib/src/orca_note_mcp_client.dart`)
- Connects to `http://localhost:18672/mcp` (configurable).
- Uses Bearer token auth from config store.
- Provides `callTool(toolName, arguments)` and `listTools()`.
- Timeout: 30s for calls, 15s for list.

### `OrcaToolCommand` (`lib/src/tool_command.dart`)
- Base class for all MCP tool commands. Extends `Command<int>` from `args` package.
- Common flags: `--repo` (repoId), `--input` (JSON object), `--json` (raw output), `--help`.
- Validates required fields, unknown fields, and repoId presence.
- Calls `context.mcpClient.callTool(toolName, fullArguments)`.
- Decodes result payload via `decodeToolPayload()`.
- Supports custom output formatting per tool (e.g., `get_blocks_text` uses `formatBlockText`).

### `ToolMetadata` (`lib/src/tool_metadata.dart`)
- Describes a tool's name, title, summary, description, fields, examples, sections.
- `requiresRepo` derived from whether any field has `providedByRepoFlag: true` for `repoId`.
- `fieldNames` and `requiredFields` used for validation.

### `ToolFieldMetadata`
- Describes a single field: name, description, required, providedByRepoFlag.

### `OrcaNoteOutputFormatter` (`lib/src/output_formatter.dart`)
- `formatJson()` — pretty-printed JSON.
- `formatText()` — generic text tree output.
- `formatBlockText()` — special extraction for block text content.

### `JsonSupport` (`lib/src/json_support.dart`)
- `parseJsonObject()` — parses `--input` JSON string.
- `decodeToolPayload()` — extracts and decodes `CallToolResult.content` (prefers single-item unwrap, tries JSON decode).

### Tool Registration (`lib/src/tools/tool_registry.dart`)
- `createToolCommands()` returns `List<OrcaToolCommand>`.
- Each tool is a factory function in its own file under `lib/src/tools/`.
- Pattern: `createXxxCommand(OrcaNoteCommandContext) → OrcaToolCommand`
- Tools currently registered: get_tags_and_pages, get_page, get_blocks_text, get_journal, parse_datetime, query_blocks, insert_markdown, move_blocks, create_page, delete_blocks, insert_tags, remove_tags, create_tags, s3_sync.

### Command Runner (`lib/src/orca_note_command_runner.dart`)
- `OrcaNoteCommandRunner` adds `ConfigCommand` and all tool commands from `createToolCommands()`.

## Field Pattern
- `repoId` is always `providedByRepoFlag: true` and passed via `--repo` flag.
- Additional fields are passed via `--input '{...}'` JSON.
- All tools require `repoId` as a field.
- Field validation checks both `--input` keys and `--repo`.
