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

## Troubleshooting

- `HTTP 502` or a connection error while Orca Note is running: a proxy in the environment (`HTTP_PROXY`, `HTTPS_PROXY`, `ALL_PROXY`) can hijack the call to the local MCP server. Unset them, or set `NO_PROXY=localhost`; the CLI forces a direct connection for loopback addresses, so also check that you are running a current build.
- `Tool <name> not found`: the running Orca Note app is older than the CLI; update the app.

## Writing Guidelines

- When inserting content with tags, favor `insert_markdown` over `insert_tags`.
- Tags are usually attached to title lines or lines with a similar purpose.
- When applying a tag, be sure to check its properties and provide reasonable values; if no reasonable values are available, do not provide them to use the property's default values.
