import '../command_context.dart';
import '../tool_command.dart';
import '../tool_metadata.dart';

OrcaToolCommand createQueryBlocksCommand(OrcaNoteCommandContext context) {
  return OrcaToolCommand(
    context: context,
    metadata: const ToolMetadata(
      name: 'query_blocks',
      title: 'Query Blocks',
      summary: 'Run structured block queries with QueryDescription2.',
      description:
          'Runs advanced block queries and returns matching block IDs. The full query spec lives under description, and the root group should usually be kind 100.',
      fields: <ToolFieldMetadata>[
        ToolFieldMetadata(
          name: 'repoId',
          description: 'The repository ID.',
          required: true,
          providedByRepoFlag: true,
        ),
        ToolFieldMetadata(
          name: 'description',
          description:
              'Complete query description object containing q, pagination, sorting, and related options.',
          required: true,
        ),
      ],
      requiredFields: <String>['repoId', 'description'],
      sections: <ToolSectionMetadata>[
        ToolSectionMetadata(
          title: 'Input shape',
          body:
              '{\n'
              '  "description": {\n'
              '    "q": {\n'
              '      "kind": 100,\n'
              '      "conditions": []\n'
              '    },\n'
              '    "page": 1,\n'
              '    "pageSize": 50\n'
              '  }\n'
              '}',
        ),
        ToolSectionMetadata(
          title: 'Description object',
          body:
              '- q: the main query group or single condition.\n'
              '- excludeId: block ID to exclude from results. The query schema expects a string block ID.\n'
              '- sort: array of [field, "ASC" | "DESC"] pairs.\n'
              '- page: 1-based page number. Defaults to 1.\n'
              '- pageSize: number of items per page. Defaults to 50.\n'
              '- tagName: the tag name used when a sort expression refers to tag properties.\n'
              '- randomSeed: numeric seed for stable random ordering across pages.\n'
              '- useReferenceDate: when true, relative dates are evaluated against the current page date instead of now.\n'
              '- referenceDate: explicit Unix timestamp used as the reference for relative dates.',
        ),
        ToolSectionMetadata(
          title: 'Group kinds',
          body:
              '- 100: self-and. All child conditions must match on the same candidate block.\n'
              '- 101: self-or. At least one child condition must match on the same candidate block.\n'
              '- 106: chain-and. Child conditions may be satisfied across the candidate block, its ancestors, or its descendants. Use this for structure-aware queries.\n'
              '- negate: optional boolean available on group objects. When true, the group result is inverted.\n'
              '- conditions: array of nested groups or leaf conditions.\n'
              '- Use a root group with kind: 100 unless there is a strong reason not to.',
        ),
        ToolSectionMetadata(
          title: 'Condition kinds',
          body:
              'Text match:\n'
              '{\n'
              '  "kind": 8,\n'
              '  "text": "deadline",\n'
              '  "raw": false\n'
              '}\n\n'
              '- text: text to search for.\n'
              '- raw: when true, use raw text matching without stemming or normalization.\n\n'
              'Tag match:\n'
              '{\n'
              '  "kind": 4,\n'
              '  "name": "task",\n'
              '  "properties": [\n'
              '    {\n'
              '      "name": "priority",\n'
              '      "op": 1,\n'
              '      "value": "high"\n'
              '    }\n'
              '  ]\n'
              '}\n\n'
              '- selfOnly: when true, only match direct tag references on the block itself.\n'
              '- Tag property operators: 1=equals, 2=not equals, 3=includes, 4=not includes, 5=has, 6=not has, 7=greater than, 8=less than, 9=greater or equal, 10=less or equal, 11=is null, 12=not null.\n\n'
              'Reference match:\n'
              '{\n'
              '  "kind": 6,\n'
              '  "blockId": "123"\n'
              '}\n\n'
              '- blockId must be a string in this query format.\n'
              '- selfOnly limits matches to direct references.\n\n'
              'Journal range:\n'
              '{\n'
              '  "kind": 3,\n'
              '  "start": {"t": 1, "v": -7, "u": "d"},\n'
              '  "end": {"t": 1, "v": 0, "u": "d"}\n'
              '}\n\n'
              '- Relative spec: {"t": 1, "v": -7, "u": "d"}.\n'
              '- Absolute spec: {"t": 2, "v": 1712707200000} (UNIX timestamp in milliseconds).\n'
              '- Units: s, m, h, d, w, M, y.\n\n'
              'Block property match:\n'
              '{\n'
              '  "kind": 9,\n'
              '  "hasChild": true,\n'
              '  "hasTags": true,\n'
              '  "backRefs": {"op": 7, "value": 3}\n'
              '}\n\n'
              '- Available predicates: types, hasParent, hasChild, hasTags, hasAliases, backRefs, created, modified.\n'
              '- types uses op 5 for has and 6 for not-has, with value as an array of type names.\n'
              '- backRefs, created, and modified support op 1, 2, 7, 8, 9, 10.\n\n'
              'Task match:\n'
              '{\n'
              '  "kind": 11,\n'
              '  "completed": false\n'
              '}\n\n'
              'Specific block match:\n'
              '{\n'
              '  "kind": 12,\n'
              '  "blockId": "456"\n'
              '}\n\n'
              'Format match:\n'
              '{\n'
              '  "kind": 13,\n'
              '  "f": "b",\n'
              '  "fa": {}\n'
              '}\n\n'
              '- Use format match for inline formatting such as bold.',
        ),
        ToolSectionMetadata(
          title: 'Sorting',
          body:
              '{\n'
              '  "sort": [\n'
              '    ["_created", "DESC"],\n'
              '    ["_text", "ASC"]\n'
              '  ]\n'
              '}\n\n'
              'Common built-in sort fields: _created, _modified, _text, _journal, _refcount.\n'
              'Or use a tag property as a sort field by specifying tagName in the description and using property name in the sort field.',
        ),
        ToolSectionMetadata(
          title: 'Output format',
          body:
              'Success example:\n'
              '{\n'
              '  "success": true,\n'
              '  "repoId": "my-repo",\n'
              '  "totalCount": 2,\n'
              '  "page": 1,\n'
              '  "pageSize": 50,\n'
              '  "tagName": "task",\n'
              '  "groupBy": null,\n'
              '  "resultIds": [123, 456]\n'
              '}\n\n'
              'No-match example:\n'
              '{\n'
              '  "success": true,\n'
              '  "repoId": "my-repo",\n'
              '  "totalCount": 0,\n'
              '  "page": 1,\n'
              '  "pageSize": 50,\n'
              '  "resultIds": []\n'
              '}\n\n'
              '- resultIds is the important payload. Use get_blocks_text or get_page afterward if you need readable content or container information.',
        ),
        ToolSectionMetadata(
          title: 'Common patterns',
          body:
              'Text search:\n'
              '{\n'
              '  "description": {\n'
              '    "q": {\n'
              '      "kind": 100,\n'
              '      "conditions": [\n'
              '        {"kind": 8, "text": "deadline"}\n'
              '      ]\n'
              '    }\n'
              '  }\n'
              '}\n\n'
              'Incomplete tasks under a journal:\n'
              '{\n'
              '  "description": {\n'
              '    "q": {\n'
              '      "kind": 100,\n'
              '      "conditions": [\n'
              '        {\n'
              '          "kind": 102,\n'
              '          "conditions": [\n'
              '            {"kind": 3, "start": {"t": 2, "v": 1779206400000}, "end": {"t": 2, "v": 1779206400000}}\n'
              '          ]\n'
              '        },\n'
              '        {"kind": 11, "completed": false}\n'
              '      ]\n'
              '    }\n'
              '  }\n'
              '}\n\n'
              'Blocks tagged as project and containing text:\n'
              '{\n'
              '  "description": {\n'
              '    "q": {\n'
              '      "kind": 100,\n'
              '      "conditions": [\n'
              '        {"kind": 4, "name": "project"},\n'
              '        {"kind": 8, "text": "deadline"}\n'
              '      ]\n'
              '    }\n'
              '  }\n'
              '}\n\n'
              'Either urgent or important:\n'
              '{\n'
              '  "description": {\n'
              '    "q": {\n'
              '      "kind": 100,\n'
              '      "conditions": [\n'
              '        {\n'
              '          "kind": 101,\n'
              '          "conditions": [\n'
              '            {"kind": 4, "name": "urgent"},\n'
              '            {"kind": 4, "name": "important"}\n'
              '          ]\n'
              '        }\n'
              '      ]\n'
              '    }\n'
              '  }\n'
              '}\n\n'
              'Chain query:\n'
              '{\n'
              '  "description": {\n'
              '    "q": {\n'
              '      "kind": 100,\n'
              '      "conditions": [\n'
              '        {\n'
              '          "kind": 106,\n'
              '          "conditions": [\n'
              '            {"kind": 8, "text": "project"}\n'
              '          ]\n'
              '        },\n'
              '        {"kind": 8, "text": "deadline"}\n'
              '      ]\n'
              '    }\n'
              '  }\n'
              '}',
        ),
        ToolSectionMetadata(
          title: 'Failure checks',
          body:
              '- The root query shape must live under description.q.\n'
              '- Every condition must have a valid kind.\n'
              '- blockId fields that belong to the query language must be strings, not numbers.\n'
              '- Relative and absolute dates must use the correct { t, v, u } structure.\n'
              '- Sorting must be an array of two-item arrays.\n\n'
              'Error example:\n'
              '{\n'
              '  "success": false,\n'
              '  "error": "Database error - check your query syntax",\n'
              '  "commonIssues": [\n'
              '    "Invalid kind values - use 100-105 for groups, 3,4,6,8,9,11,12 for conditions"\n'
              '  ]\n'
              '}',
        ),
      ],
      examples: <ToolExample>[
        ToolExample(
          description: 'Search for blocks containing a text fragment.',
          command:
              "orcanote query_blocks --repo my-repo --input '{\"description\":{\"q\":{\"kind\":100,\"conditions\":[{\"kind\":8,\"text\":\"deadline\"}]}}}'",
        ),
        ToolExample(
          description: 'Find incomplete tasks and keep the raw JSON response.',
          command:
              "orcanote query_blocks --repo my-repo --input '{\"description\":{\"q\":{\"kind\":100,\"conditions\":[{\"kind\":11,\"completed\":false}]}}}' --json",
        ),
      ],
    ),
  );
}
