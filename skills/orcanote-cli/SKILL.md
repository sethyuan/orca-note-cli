---
name: orcanote-cli
description: Read, write, query and manipulate an Orca Note note repository. Use this skill when users need to operate on their notes.
---

# OrcaNote CLI

Use this skill when the user wants to read, write, query, or manipulate an Orca Note repository through the `orcanote` command.

## Command Shape

```sh
orcanote <tool_name> --repo <repoId> --input '<json object>' --json
```

## Default Workflow

1. Always call tool's help `orcanote help <tool_name>` to fully understand it before actually using it.
2. Use batching whenever possible.
3. Re-read after destructive changes if the user needs confirmation.

## Tool Selection

- Inspect repository: `get_tags_and_pages`, `get_journal`, `query_blocks`
- Read content: `get_blocks_text`, `get_page`
- Write content: `create_page`, `create_tags`, `insert_markdown`
- Manage tags: `insert_tags`, `remove_tags`
- Change structure: `move_blocks`, `delete_blocks`
- Date/time manipulation: `parse_datetime`
- Repository sync: `s3_sync`
- App UI level operations: `invoke_commands`
- Use `parse_datetime` with `{"text":"now"}` when you need the current local date and time, and use `referenceTimestamp` for relative expressions like shifting a date/time from a known base. When calling `parse_datetime`, don't pass the `--repo` argument.

## App UI Commands

The content tools cannot change a block's type, toggle a task, delete a block by ID, set block properties, manage aliases or references, or drive the app UI. Use `invoke_commands` for that: it runs app commands inside the window of an already open repository and reports a status for every command.

```sh
orcanote invoke_commands --repo <repoId> --input '{"commands":[{"id":"<command ID>","args":[1234]},{"id":"<command ID>"}]}'
```

### Command Reference

Every `core.*` command ID, its arguments and a usage example are documented in two reference
files next to this `SKILL.md`. Read them on demand — never load them wholesale:

- `Core-Commands.md` (253 lines, 42 commands) — commands that act on the app rather than inside an
  editor: `core.global.*`, theme/UI, sidebar, panel management, navigation (`core.open*`,
  `core.go*`), application, clipboard, assets, index, S3 sync, layout, preview. Small enough to
  read in full.
- `Core-Editor-Commands.md` (2549 lines, ~85 KB, 175 commands) — everything that manipulates
  blocks or text, plus a few helpers outside that namespace (`core.duplicateTag`,
  `core.ai.openChatAside`). Far too large to read whole; search it for the exact ID instead:

  ```sh
  grep -n -A16 '### `core.editor.collapseEmptyBlock`' /Users/sethyuan/dev/orca-note-cli/skills/orcanote-cli/Core-Editor-Commands.md
  ```

The split is by command kind, not strictly by ID prefix: `core.editor.copySelection` and
`core.editor.copySelectionForMove` are plain (non-editor) commands and live in `Core-Commands.md`.
`orcanote help invoke_commands` still owns the tool contract — input shape, limits, `panelId` /
`undoable` / `focus`, status and error codes.

Turning a doc entry into an `invoke_commands` item:

1. The doc's **Parameters** list is the order of `args`. The `cursor` argument in its examples is
   injected by the app and has no `args` counterpart — drop it. `core.editor.collapseEmptyBlock`
   (`blockId: DbId`, `mode: "promote" | "absorb"`) therefore becomes
   `{"id":"core.editor.collapseEmptyBlock","args":[123,"promote"]}`.
2. Prefer an explicit block id over `focus: true`: it works without stealing the user's focus,
   whereas a no-arg editor command is otherwise skipped with `editor_not_focused`.
3. The docs describe the in-app JavaScript API, so examples pass `Block` objects and `Date`s;
   `args` is plain JSON, so pass block ids and ISO strings for dates. Commands that truly need a
   `Block` snapshot and are useless through `invoke_commands`: `core.editor.insertBlock`,
   `batchInsertText`, `batchInsertReprs`, `batchInsertHTML` — use `insert_markdown` /
   `create_page` instead.

## Troubleshooting

- `HTTP 502` or a connection error while Orca Note is running: a proxy in the environment (`HTTP_PROXY`, `HTTPS_PROXY`, `ALL_PROXY`) can hijack the call to the local MCP server. Unset them, or set `NO_PROXY=localhost`; the CLI forces a direct connection for loopback addresses, so also check that you are running a current build.
- `Tool <name> not found`: the running Orca Note app is older than the CLI; update the app.

## Writing Guidelines

- When inserting content with tags, favor `insert_markdown` over `insert_tags`.
- Tags are usually attached to title lines or lines with a similar purpose.
- When applying a tag, be sure to check its properties and provide reasonable values; if no reasonable values are available, do not provide them to use the property's default values.
