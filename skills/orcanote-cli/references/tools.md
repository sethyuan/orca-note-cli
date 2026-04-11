# OrcaNote CLI Tool Reference

All commands follow this base form:

```sh
orcanote <tool-name> --repo <repoId> --input '<json object>' --json
```

Only include non-`repoId` parameters in `--input`.

Output conventions:

- All tool responses are JSON.
- Successful operations usually return `success: true`.
- Failures return `success: false` with an `error` field, and some validation failures also include a `details` array.

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

Success output:

```json
{
  "success": true,
  "blockId": 123
}
```

Failure output:

```json
{
  "success": false,
  "error": "Page name already exists (block 123)."
}
```

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

Success output:

```json
{
  "success": true,
  "result": [
    {
      "name": "task",
      "id": 456
    }
  ]
}
```

Failure output:

Validation failures and runtime failures are JSON, for example:

```json
{
  "success": false,
  "error": "Validation Failed",
  "details": [
    "Tag at index 0: Name \"_bad\" is invalid (cannot be empty or start with underscore)."
  ]
}
```

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

Success output:

```json
{
  "success": true
}
```

Failure output:

```json
{
  "success": false,
  "error": "No block IDs provided for deletion."
}
```

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

Success output:

```json
{
  "success": true,
  "repoId": "my-repo",
  "results": [
    {
      "blockId": 201,
      "blocks": [
        {
          "id": 201,
          "text": "Root block"
        },
        {
          "id": 202,
          "text": "Child block"
        }
      ]
    }
  ]
}
```

Failure output:

```json
{
  "success": false,
  "error": "childStartIndex and childEndIndex must be provided together."
}
```

## get_page

Finds the containing page or journal for each block.

Input JSON:

```json
{
  "blockIds": [301, 302]
}
```

Success output:

```json
{
  "success": true,
  "results": [
    {
      "blockId": 301,
      "pageId": 900,
      "pageName": "Project Roadmap"
    },
    {
      "blockId": 302,
      "error": "Block is not under any page."
    }
  ]
}
```

Failure output:

```json
{
  "success": false,
  "error": "Error retrieving page: ..."
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

Success output:

```json
{
  "success": true,
  "pagination": {
    "pageNum": 1,
    "pageSize": 200
  },
  "tags": {
    "total": 20,
    "totalPages": 1,
    "items": [
      {
        "id": 11,
        "name": "task",
        "properties": [
          {
            "name": "priority",
            "type": "TextChoices",
            "details": {
              "subType": "single",
              "choices": ["low", "medium", "high"]
            }
          }
        ]
      }
    ]
  },
  "pages": {
    "total": 50,
    "totalPages": 1,
    "items": [
      {
        "id": 22,
        "name": "Project Roadmap",
        "properties": []
      }
    ]
  }
}
```

Failure output:

```json
{
  "success": false,
  "error": "Could not retrieve tags or pages from repository: my-repo"
}
```

## get_today_journal

Returns today's journal block ID, creating it if needed.

Input JSON:

```json
{}
```

Success output:

```json
{
  "success": true,
  "blockId": 777,
  "date": "2026-04-11"
}
```

Failure output:

```json
{
  "success": false,
  "error": "Error retrieving today's journal: ..."
}
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

Success output:

```json
{
  "success": true,
  "blockId": 1001,
  "insertedCount": 3
}
```

Failure output:

```json
{
  "success": false,
  "error": "Reference block with ID 401 not found in repository my-repo"
}
```

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

Success output:

```json
{
  "success": true
}
```

Additional metadata:

- If preserved by the wrapper, `updatedIds` is the same block ID list passed in.

Failure output:

Validation failures and runtime failures are JSON, for example:

```json
{
  "success": false,
  "error": "Validation Failed",
  "details": ["tags[0]: Tag name cannot be empty."]
}
```

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

Success output:

```json
{
  "success": true,
  "message": "Successfully moved 2 blocks to parent 800."
}
```

Additional metadata:

- If preserved by the wrapper, `updatedIds` contains changed block IDs and the destination `parentId`.

Failure output:

```json
{
  "success": false,
  "error": "Invalid parent ID"
}
```

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

Success output:

```json
{
  "success": true,
  "totalCount": 2,
  "page": 1,
  "pageSize": 50,
  "tagName": "task",
  "groupBy": null,
  "resultIds": [123, 456]
}
```

Failure output:

Empty matches and exceptions are both JSON. Examples:

```json
{
  "success": true,
  "totalCount": 0,
  "page": 1,
  "pageSize": 50,
  "resultIds": []
}
```

```json
{
  "success": false,
  "error": "Database error - check your query syntax",
  "commonIssues": [
    "Invalid kind values - use 100-105 for groups, 3,4,6,8,9,11,12 for conditions"
  ]
}
```

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

Success output:

```json
{
  "success": true,
  "updatedIds": [901, 902]
}
```

Failure output:

Validation failures and runtime failures are JSON, for example:

```json
{
  "success": false,
  "error": "Validation Failed",
  "details": ["tags[0]: Tag name cannot start with underscore."]
}
```
