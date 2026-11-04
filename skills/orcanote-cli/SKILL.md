---
name: orcanote-cli
description: Read, write, query and manipulate an Orca Note note repository — pages, sub-pages, journals and [[references]], tags with properties, showing a page as long-form, and reading blocks back to verify a change. Use this skill when users need to operate on their Orca Note notes, create or reorganize pages, insert Markdown into a repository, or check how a page actually turned out.
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
- Read block JSON (`_repr`, aliases, tags, links, parent/children): `invoke_commands` + `core.ai.getBlocks` — see `Orca-Page-Workflows.md`
- Write content: `create_page`, `create_tags`, `insert_markdown`
- Manage tags: `insert_tags`, `remove_tags`
- Change structure: `move_blocks`, `delete_blocks`
- Date/time manipulation: `parse_datetime`
- Repository sync: `s3_sync`
- App UI level operations: `invoke_commands`
- Use `parse_datetime` with `{"text":"now"}` when you need the current local date and time, and use `referenceTimestamp` for relative expressions like shifting a date/time from a known base. When calling `parse_datetime`, don't pass the `--repo` argument.

## App UI Commands

The content tools cannot change a block's type, toggle a task, delete a block by ID, set block properties, manage aliases or references, or drive the app UI. Use `invoke_commands` for that: it runs app commands inside the window of an already open repository and reports a status for every command.

AI commands (`core.ai.*`) also **return data**: the value lands in `results[i].ret` (for example
`core.ai.getBlocks` gives a JSON view of blocks, including `_repr`). That is the read-back channel
for things the content tools cannot see — see `Orca-Page-Workflows.md`.

```sh
orcanote invoke_commands --repo <repoId> --input '{"commands":[{"id":"<command ID>","args":[1234]},{"id":"<command ID>"}]}'
```

### Command Reference

Every `core.*` command ID, its arguments and a usage example are documented in two reference
files next to this `SKILL.md`, plus a third one with verified page-level workflows. Read them on
demand — never load them wholesale:

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

- `Orca-Page-Workflows.md` (short) — **read this before any page-level task**: creating pages
  (an alias *is* the page title), sub-pages, showing a page as long-form (`_repr.lf`), journals
  and `[[…]]` references, tags with properties, the focused-window precondition for clipboard
  commands, and how to read every one of those back to verify.

  ```sh
  orcanote invoke_commands --repo <repoId> --input \
    '{"commands":[{"id":"core.ai.getBlocks","args":[[1234]]}]}' --json
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
   **Exception — clipboard-dependent commands** (`copyBlockLink`, `copy.md`, `copyBlockID`,
   `copySelection`, `pasteText` / `pastePlainText`): they need the Orca Note window to be
   **focused**. Unfocused they still answer `status: ok`, but what lands on the clipboard is
   unreliable (e.g. `copyBlockLink` leaves only the repo id). Pass `"focus": true` (it raises the
   window) when you really need the clipboard, and if you cannot or should not raise the window,
   do not take results from the clipboard — verify with `core.ai.getBlocks` instead.
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
- For tagging an **existing** block/page with no new content (the usual "page + `#Article` + properties"
  case), `insert_tags` is the right tool — `insert_markdown` cannot touch an existing block's content.
  Verify the result by querying the tag (and its properties) back, see `Orca-Page-Workflows.md`.
- Tags are usually attached to title lines or lines with a similar purpose.
- When applying a tag, be sure to check its properties and provide reasonable values; if no reasonable values are available, do not provide them to use the property's default values.
