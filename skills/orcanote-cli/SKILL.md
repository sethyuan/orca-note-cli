---
name: orcanote-cli
description: Use this skill when you need to operate an Orca Note repository through the orcanote CLI. It covers page, tag, block, and query operations.
---

# OrcaNote CLI

Use this skill when the user wants to read or mutate an Orca Note repository through the `orcanote` command.

## Command Shape

```sh
orcanote <tool-name> --repo <repoId> --input '<json object>' [--json]
```

Rules:

- Put every parameter except `repoId` inside `--input`.
- Prefer `--json` so the response is stable and machine-readable.
- Use the tool name with underscores as `<tool-name>`.
- On macOS and Linux, single-quote the JSON string. If the payload contains embedded quotes or multiline markdown, build the JSON carefully before passing it to the command.

## Default Workflow

1. Discover IDs before writing when the target block, page, or tag is not already known.
2. Use read-oriented tools first: `get_tags_and_pages`, `get_today_journal`, `query_blocks`, `get_page`, `get_blocks_text`.
3. Apply mutations with the smallest valid batch.
4. Re-read after destructive changes if the user needs confirmation.

## Tool Selection

- Create content: `create_page`, `create_tags`, `insert_markdown`
- Change structure: `move_blocks`, `delete_blocks`
- Manage tags: `insert_tags`, `remove_tags`
- Inspect repository state: `get_blocks_text`, `get_page`, `get_tags_and_pages`, `get_today_journal`, `query_blocks`

## Guardrails

- `insert_tags` and `remove_tags` accept at most 100 blocks and 100 tags per call.
- `get_blocks_text` requires `childStartIndex` and `childEndIndex` together when using partial reads.
- `query_blocks` expects the full query payload under `description`.

## References

- Tool catalog and examples: [references/tools.md](references/tools.md)
- `query_blocks` grammar and examples: [references/query-blocks.md](references/query-blocks.md)
