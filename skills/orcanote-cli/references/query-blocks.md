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

- `q`: the main query group or single condition
- `excludeId`: block ID to exclude, passed as a string
- `sort`: array of `[field, "ASC" | "DESC"]`
- `page`: defaults to `1`
- `pageSize`: defaults to `50`
- `tagName`: required when sorting by tag property fields
- `stats`: optional statistical aggregations
- `randomSeed`: stable random sort seed
- `useReferenceDate`: whether to use the page date as the relative-date reference
- `referenceDate`: Unix timestamp used as the relative-date reference

## Group Kinds

- `100`: self-and. All child conditions must match.
- `101`: self-or. At least one child condition must match.
- `106`: chain-and. All child conditions must match across self, ancestors, or descendants.

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
  ],
  "selfOnly": true
}
```

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

### Reference match

```json
{
  "kind": 6,
  "blockId": "123",
  "selfOnly": true
}
```

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

### Task match

```json
{
  "kind": 11,
  "completed": false
}
```

### Specific block match

```json
{
  "kind": 12,
  "blockId": "456"
}
```

### Format match

```json
{
  "kind": 13,
  "f": "b",
  "fa": {}
}
```

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
