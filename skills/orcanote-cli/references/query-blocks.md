# query_blocks Reference

`query_blocks` receives this shape under `--input`:

```json
{
  "description": {
    "q": {
      "kind": 100,
      "conditions": []
    },
    "page": 1,
    "pageSize": 50
  }
}
```

The CLI returns matching block IDs. Use `get_blocks_text` or `get_page` afterward if the user needs readable content or container information.

## Description Object

`description` supports these top-level fields:

- `q`: the main query group or single condition.
- `excludeId`: block ID to exclude from results. The query schema expects a string block ID.
- `sort`: array of `[field, "ASC" | "DESC"]` pairs.
- `page`: 1-based page number. Defaults to `1`.
- `pageSize`: number of items per page. Defaults to `50`.
- `tagName`: the tag name used when a sort expression refers to tag properties.
- `randomSeed`: numeric seed for stable random ordering across pages.
- `useReferenceDate`: when `true`, relative dates are evaluated against the current page date instead of now.
- `referenceDate`: explicit Unix timestamp used as the reference for relative dates.

## Group Kinds

- `100`: self-and. All child conditions must match on the same candidate block.
- `101`: self-or. At least one child condition must match on the same candidate block.
- `106`: chain-and. Child conditions may be satisfied across the candidate block, its ancestors, or its descendants. Use this for structure-aware queries like “a block under a project subtree that also contains deadline”.
- `negate`: optional boolean available on group objects. When `true`, the group result is inverted.
- `conditions`: array of nested groups or leaf conditions.

Use a root group with `kind: 100` unless there is a strong reason not to.

## Condition Kinds

### Text match

```json
{
  "kind": 8,
  "text": "deadline",
  "raw": false
}
```

Parameters:

- `text`: text to search for.
- `raw`: when `true`, use raw text matching without stemming or normalization. Omit it for the default normalized search behavior.

### Tag match

```json
{
  "kind": 4,
  "name": "task",
  "properties": [
    {
      "name": "priority",
      "op": 1,
      "value": "high"
    }
  ]
}
```

Parameters:

- `name`: tag name to match.
- `properties`: optional list of property predicates that must match on the tag.
- `selfOnly`: when `true`, only match direct tag references on the block itself. Do not include matches inherited through included tags or indirect expansion.

Tag property operators:

- `1`: equals
- `2`: not equals
- `3`: includes
- `4`: not includes
- `5`: has
- `6`: not has
- `7`: greater than
- `8`: less than
- `9`: greater or equal
- `10`: less or equal
- `11`: is null
- `12`: not null

Property predicate fields:

- `name`: property name.
- `op`: comparison operator code.
- `value`: comparison value. The schema accepts string, number, or boolean.

### Reference match

```json
{
  "kind": 6,
  "blockId": "123"
}
```

Parameters:

- `blockId`: target referenced block ID, expressed as a string.
- `selfOnly`: when `true`, only count direct references on the candidate block, not references surfaced through included tags.

Note that `blockId` is expressed as a string in this query format.

### Journal range

```json
{
  "kind": 3,
  "start": {
    "t": 1,
    "v": -7,
    "u": "d"
  },
  "end": {
    "t": 1,
    "v": 0,
    "u": "d"
  }
}
```

Parameters:

- `start`: inclusive start bound.
- `end`: inclusive end bound.
- Each bound is a date spec object with `t`, `v`, and optional `u`.

Date spec format:

- Relative: `{ "t": 1, "v": -7, "u": "d" }`
- Absolute: `{ "t": 2, "v": 1712707200000 }`

Units:

- `s`: seconds
- `m`: minutes
- `h`: hours
- `d`: days
- `w`: weeks
- `M`: months
- `y`: years

Date spec fields:

- `t`: date type. `1` means relative, `2` means absolute.
- `v`: numeric value. For relative dates this is an offset; for absolute dates this is a timestamp.
- `u`: relative date unit. Only used when `t` is `1`.

### Block property match

```json
{
  "kind": 9,
  "hasChild": true,
  "hasTags": true,
  "backRefs": {
    "op": 7,
    "value": 3
  }
}
```

Parameters:

- `types`: optional block type predicate. Use `op: 5` for has and `op: 6` for not-has, with `value` as an array of type names.
- `hasParent`: boolean filter for whether a block has a parent.
- `hasChild`: boolean filter for whether a block has at least one child.
- `hasTags`: boolean filter for whether a block has any tags.
- `hasAliases`: boolean filter for whether a block has aliases.
- `backRefs`: numeric predicate on backlink count.
- `created`: predicate on creation time.
- `modified`: predicate on modification time.

Available block conditions include:

- `types`: `{ "op": 5 | 6, "value": ["typeName"] }`
- `hasParent`
- `hasChild`
- `hasTags`
- `hasAliases`
- `backRefs`
- `created`
- `modified`

For `created` and `modified`, `value` may be a number or a date spec object.

For `backRefs`, `created`, and `modified`, the `op` codes are:

- `1`: equals
- `2`: not equals
- `7`: greater than
- `8`: less than
- `9`: greater or equal
- `10`: less or equal

### Task match

```json
{
  "kind": 11,
  "completed": false
}
```

Parameters:

- `completed`: optional boolean. `true` finds completed tasks, `false` finds incomplete tasks, omitted matches task blocks regardless of status.

### Specific block match

```json
{
  "kind": 12,
  "blockId": "456"
}
```

Parameters:

- `blockId`: exact block ID to match, expressed as a string.

### Format match

```json
{
  "kind": 13,
  "f": "b",
  "fa": {}
}
```

Parameters:

- `f`: format identifier, for example `b` for bold.
- `fa`: optional format attributes object for precise matching.

Use this to match formatted fragments such as bold or other inline formats.

## Sorting

Example:

```json
{
  "sort": [
    ["_created", "DESC"],
    ["_text", "ASC"]
  ]
}
```

Common built-in sort fields:

- `_created`
- `_modified`
- `_text`
- `_journal`
- `_refcount`

## Output Format

Successful queries return JSON like this:

```json
{
  "success": true,
  "repoId": "my-repo",
  "totalCount": 2,
  "page": 1,
  "pageSize": 50,
  "tagName": "task",
  "groupBy": null,
  "resultIds": [123, 456]
}
```

Notes:

- `resultIds` is the important payload. It is the list of matching block IDs.
- `totalCount` is the number of IDs returned by the current query execution.
- `tagName` echoes the sort-related tag name when provided.
- `groupBy` may be absent or `null` depending on the wrapper and query.

No-match output is also JSON:

```json
{
  "success": true,
  "repoId": "my-repo",
  "totalCount": 0,
  "page": 1,
  "pageSize": 50,
  "resultIds": []
}
```

Query errors return JSON like this:

```json
{
  "success": false,
  "error": "Database error - check your query syntax",
  "commonIssues": [
    "Invalid kind values - use 100-105 for groups, 3,4,6,8,9,11,12 for conditions"
  ]
}
```

## Common Patterns

### Text search

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
    }
  }
}
```

### Incomplete tasks

```json
{
  "description": {
    "q": {
      "kind": 100,
      "conditions": [
        {
          "kind": 11,
          "completed": false
        }
      ]
    }
  }
}
```

### Blocks tagged as project and containing text

```json
{
  "description": {
    "q": {
      "kind": 100,
      "conditions": [
        {
          "kind": 4,
          "name": "project"
        },
        {
          "kind": 8,
          "text": "deadline"
        }
      ]
    }
  }
}
```

### Either urgent or important

```json
{
  "description": {
    "q": {
      "kind": 100,
      "conditions": [
        {
          "kind": 101,
          "conditions": [
            {
              "kind": 4,
              "name": "urgent"
            },
            {
              "kind": 4,
              "name": "important"
            }
          ]
        }
      ]
    }
  }
}
```

### Chain query

```json
{
  "description": {
    "q": {
      "kind": 100,
      "conditions": [
        {
          "kind": 106,
          "conditions": [
            {
              "kind": 8,
              "text": "project"
            }
          ]
        },
        {
          "kind": 8,
          "text": "deadline"
        }
      ]
    }
  }
}
```

## Failure Checks

If `query_blocks` fails, verify these first:

- The root query shape is under `description.q`.
- Every condition has a valid `kind`.
- `blockId` fields that belong to the query language are strings, not numbers.
- Relative and absolute dates use the correct `{ t, v, u }` structure.
- Sorting is an array of two-item arrays.
