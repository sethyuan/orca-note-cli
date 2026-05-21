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

### Rules

- Always use the `--json` flag to get structured output.
- Single-quote the JSON string. If the payload contains embedded quotes or multiline markdown, build the JSON carefully before passing it to the command.

### Tool Documentations

When uncertain about how to use a tool, run its help command to get usage instructions and examples:

```sh
orcanote <tool_name> --help
```

## Default Workflow

1. Discover IDs before writing when the target block, page, or tag is not already known.
2. When a write depends on parent-child placement, inspect structure before mutating: use `get_blocks_structure` to confirm the direct parent and ordered children of the target blocks.
3. Use batching whenever possible.
4. Re-read after destructive changes if the user needs confirmation.

## Tool Selection

- Inspect repository: `get_tags_and_pages`, `get_journal`, `query_blocks`
- Read content: `get_blocks_text`, `get_blocks_structure`, `get_page`
- Write content: `create_page`, `create_tags`, `insert_markdown`
- Manage tags: `insert_tags`, `remove_tags`
- Change structure: `move_blocks`, `delete_blocks`
- Date/time manipulation: `parse_datetime`
- Use `parse_datetime` with `{"text":"now"}` when you need the current local date and time, and use `referenceTimestamp` for relative expressions like shifting a date/time from a known base.

## Writing Guidelines

- When inserting content with tags, favor `insert_markdown` over `insert_tags`.
- Tags are usually attached to title lines or lines with a similar purpose.
- When applying a tag, be sure to check its properties and provide reasonable values; if no reasonable values are available, do not provide them to use the property's default values.
