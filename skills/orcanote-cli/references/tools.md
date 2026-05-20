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
          "text": "Child block and [Root block]",
          "links": [201]
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

## get_blocks_structure

Returns the direct parent and ordered child block IDs for each requested block.

Input JSON:

```json
{
  "blockIds": [210, 211]
}
```

Notes:

- `results` is an object keyed by block ID.
- Each resolved entry only contains `parent` and `children`.
- `children` follows Orca Note's block ordering semantics.
- Root blocks return `parent: null`.
- If a specific block cannot be resolved, that entry returns an `error` field instead of failing the whole request.

Success output:

```json
{
  "success": true,
  "repoId": "my-repo",
  "results": {
    "210": {
      "parent": 100,
      "children": [310, 311, 312]
    },
    "211": {
      "parent": null,
      "children": []
    }
  }
}
```

Per-block error example:

```json
{
  "success": true,
  "repoId": "my-repo",
  "results": {
    "999999": {
      "error": "Block 999999 not found in repository my-repo"
    }
  }
}
```

Failure output:

```json
{
  "success": false,
  "error": "Error retrieving blocks structure: No block IDs provided."
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

## get_journal

Returns the journal block ID for a specified date, creating it if needed. If `date` is omitted, the current date is used.

Input JSON:

```json
{
  "repoId": "my-repo",
  "date": 1776432000
}
```

Notes:

- `repoId` is required.
- `date` is optional and must be a Unix timestamp in seconds.

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
  "error": "Error retrieving journal: ..."
}
```

## parse_datetime

Parses a date/time string using local time and returns both a Unix timestamp in seconds and a formatted local datetime string.

This tool does not require `repoId`.

Input JSON:

```json
{
  "text": "3 days later",
  "referenceTimestamp": 1778932800
}
```

Notes:

- `text` is required.
- `referenceTimestamp` is optional and must be a Unix timestamp in seconds.
- Supports ISO strings, natural language (in English), and `now` for the current local date and time.

Success output:

```json
{
  "success": true,
  "timestamp": 1779199200,
  "formattedDatetime": "2026-05-18 09:20:00 +08:00"
}
```

Failure output:

```json
{
  "success": false,
  "error": "Error parsing date/time: Could not parse date/time string: not a date"
}
```

## shift_datetime

Applies a relative offset to a base Unix timestamp in seconds and returns both the resulting Unix timestamp in seconds and a formatted local datetime string.

This tool does not require `repoId`.

Input JSON:

```json
{
  "baseTimestamp": 1778932800,
  "amount": -3,
  "unit": "d"
}
```

Valid `unit` values:

- `s`
- `m`
- `h`
- `d`
- `w`
- `M`
- `y`

Success output:

```json
{
  "success": true,
  "timestamp": 1778673600,
  "formattedDatetime": "2026-05-12 09:20:00 +08:00"
}
```

Failure output:

```json
{
  "success": false,
  "error": "Error shifting date/time: ..."
}
```

## insert_markdown

Insert Markdown with optional tags and tag properties relative to a reference block.

Input JSON:

```json
{
  "refBlockId": 401,
  "position": "lastChild",
  "text": "# Agenda #Meeting{\"Location\":\"Room A\"}\n- Review status\n- Plan next step"
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
- Tag syntax: `#Tag Name` or `#Tag Name{"Property":"Value"}` after the content, before the line break.
- Add tag properties by appending a single line JSON object immediately after the tag name.
- Date property values must use Unix seconds.
- `block-ref` property values must be arrays of block IDs or alias strings; missing aliases are created automatically.

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
        "Blocks": [601, "Project A", "123"]
      }
    }
  ]
}
```

Notes:

- Maximum 100 blocks and 100 tags per call.
- Tag names must not start with `_`.
- Date property values must use Unix seconds.
- `block-ref` property values must be arrays of block IDs or alias strings.
- If an alias string already exists, the reference targets that alias's block.
- If an alias string does not exist, Orca Note creates an alias block automatically and uses that block as the target.
- Pure numeric strings such as `"123"` are treated as aliases, not block IDs.

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
