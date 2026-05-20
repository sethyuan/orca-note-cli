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

Rules:

- Put every parameter except `repoId` inside `--input`.
- Single-quote the JSON string. If the payload contains embedded quotes or multiline markdown, build the JSON carefully before passing it to the command.

## Default Workflow

1. Discover IDs before writing when the target block, page, or tag is not already known.
2. When a write depends on parent-child placement, inspect structure before mutating: use `get_blocks_structure` to confirm the direct parent and ordered children of the target blocks.
3. Apply mutations with the smallest valid batch.
4. Re-read after destructive changes if the user needs confirmation.

## Tool Selection

- Create content: `create_page`, `create_tags`, `insert_markdown`
- Change structure: `move_blocks`, `delete_blocks`
- Read content: `get_blocks_text`, `get_blocks_structure`, `get_page`
- Manage tags: `insert_tags`, `remove_tags`
- Inspect repository: `get_tags_and_pages`, `get_journal`, `query_blocks`
- Date/time manipulation: `parse_datetime`, `shift_datetime`
- Use `parse_datetime` with `{"text":"now"}` when you need the current local date and time.

For tool details, usage, input formats, and output formats, see the [tool catalog](references/tools.md).

For `query_blocks` grammar, parameter semantics, and output formats, see [references/query-blocks.md](references/query-blocks.md).

## Writing Guidelines

- When inserting content with tags, favor `insert_markdown` over `insert_tags`.
- Tags are usually attached to title lines or lines with a similar purpose.
- When applying a tag, be sure to check its properties and provide reasonable values; if no reasonable values are available, do not provide them to use the property's default values.

## Guardrails

- `insert_tags` and `remove_tags` accept at most 100 blocks and 100 tags per call.
- `get_blocks_text` requires `childStartIndex` and `childEndIndex` together when using partial reads.
- `query_blocks` expects the full query payload under `description`.
