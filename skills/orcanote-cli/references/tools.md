# OrcaNote CLI Tool Reference

All commands follow this base form:

```sh
orcanote <tool-name> --repo <repoId> --input '<json object>' --json
```

Only include non-`repoId` parameters in `--input`.

## create_page

Creates a new page alias.

Input JSON:

```json
{
  "name": "Project Roadmap",
  "includeIn": ["Projects", "Planning"]
}
```

Notes:

- `name` is required and must not start with `_`.
- `includeIn` is optional and lists page names to place into `_is`.

## create_tags

Creates multiple tags, optionally with property definitions, in one atomic operation.

Input JSON:

```json
{
  "tags": [
    {
      "name": "task",
      "properties": [
        {
          "name": "priority",
          "type": "select",
          "options": ["low", "medium", "high"]
        },
        {
          "name": "due",
          "type": "date"
        }
      ]
    }
  ]
}
```

Property types:

- `text`
- `image`
- `link`
- `place`
- `phone`
- `email`
- `number`
- `boolean`
- `date`
- `time`
- `datetime`
- `select`
- `multi-select`
- `block-ref`

## delete_blocks

Deletes blocks by ID.

Input JSON:

```json
{
  "blockIds": [101, 102, 103]
}
```

Notes:

- `blockIds` must be a non-empty array of numeric block IDs.

## get_blocks_text

Returns structured text for root blocks and their descendants.

Input JSON:

```json
{
  "blockIds": [201, 202],
  "childStartIndex": 1,
  "childEndIndex": 20
}
```

Notes:

- The root block is always included.
- `childStartIndex` and `childEndIndex` are both optional, but they must be supplied together.
- Child ranges are 1-based and inclusive.

## get_page

Finds the containing page or journal for each block.

Input JSON:

```json
{
  "blockIds": [301, 302]
}
```

## get_tags_and_pages

Lists tags and pages with pagination.

Input JSON:

```json
{
  "pageNum": 1,
  "pageSize": 200
}
```

Notes:

- `pageNum` defaults to `1`.
- `pageSize` defaults to `200`.
- Returned properties exclude names that start with `_`.

## get_today_journal

Returns today's journal block ID, creating it if needed.

Input JSON:

```json
{}
```

## insert_markdown

Parses plain text or Markdown and inserts it relative to a reference block.

Input JSON:

```json
{
  "refBlockId": 401,
  "position": "lastChild",
  "text": "# Agenda\n- Review status\n- Plan next step"
}
```

Valid `position` values:

- `before`
- `after`
- `firstChild`
- `lastChild`

Notes:

- If `position` is omitted, the tool uses Orca Note's smart default insertion behavior.
- `text` is required.

## insert_tags

Adds tags to multiple blocks in one atomic operation.

Input JSON:

```json
{
  "blockIds": [501, 502],
  "tags": [
    "status",
    {
      "name": "related",
      "props": {
        "Blocks": [601, 602]
      }
    }
  ]
}
```

Notes:

- Maximum 100 blocks and 100 tags per call.
- Tag names must not start with `_`.
- Date property values must use Unix seconds.
- `block-ref` property values must be arrays of block IDs.

## move_blocks

Moves blocks under a new parent.

Input JSON:

```json
{
  "blockIds": [701, 702],
  "parentId": 800,
  "leftId": 799
}
```

Notes:

- `leftId` is optional.
- If `leftId` is omitted, the tool appends near the end of the target parent's children.

## query_blocks

Runs advanced block queries and returns matching block IDs.

Input JSON:

```json
{
  "description": {
    "q": {
      "kind": 100,
      "conditions": [
        {
          "kind": 8,
          "text": "deadline"
        }
      ]
    },
    "page": 1,
    "pageSize": 50
  }
}
```

Notes:

- The actual query spec lives under `description`.
- Use [query-blocks.md](query-blocks.md) for the full grammar.
- Follow `query_blocks` with `get_blocks_text` if the user needs content, not just IDs.

## remove_tags

Removes tags from multiple blocks in one atomic operation.

Input JSON:

```json
{
  "blockIds": [901, 902],
  "tags": ["status", "related"]
}
```

Notes:

- Maximum 100 blocks and 100 tags per call.
- Missing tags on a block are ignored.
- Tag names must not start with `_`.
