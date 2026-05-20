import '../command_context.dart';
import '../tool_command.dart';
import '../tool_metadata.dart';

OrcaToolCommand createGetBlocksStructureCommand(
  OrcaNoteCommandContext context,
) {
  return OrcaToolCommand(
    context: context,
    metadata: const ToolMetadata(
      name: 'get_blocks_structure',
      title: 'Get Blocks Structure',
      summary: 'Read the direct parent and ordered children for blocks.',
      description:
          'Returns the direct parent and ordered child block IDs for each requested block. Use this to inspect structure before moving, deleting, or inserting blocks.',
      fields: <ToolFieldMetadata>[
        ToolFieldMetadata(
          name: 'repoId',
          description: 'The repository ID.',
          required: true,
          providedByRepoFlag: true,
        ),
        ToolFieldMetadata(
          name: 'blockIds',
          description: 'Array of block IDs whose structure should be read.',
          required: true,
        ),
      ],
      requiredFields: <String>['repoId', 'blockIds'],
      sections: <ToolSectionMetadata>[
        ToolSectionMetadata(
          title: 'Input shape',
          body:
              '{\n'
              '  "blockIds": [210, 211]\n'
              '}',
        ),
        ToolSectionMetadata(
          title: 'Notes',
          body:
              '- results is an object keyed by block ID.\n'
              '- Each resolved entry only contains parent and children.\n'
              '- children follows Orca Note\'s block ordering semantics.\n'
              '- Root blocks return parent: null.\n'
              '- If a specific block cannot be resolved, that entry returns an error field instead of failing the whole request.',
        ),
        ToolSectionMetadata(
          title: 'Success output',
          body:
              '{\n'
              '  "success": true,\n'
              '  "repoId": "my-repo",\n'
              '  "results": {\n'
              '    "210": {\n'
              '      "parent": 100,\n'
              '      "children": [310, 311, 312]\n'
              '    },\n'
              '    "211": {\n'
              '      "parent": null,\n'
              '      "children": []\n'
              '    }\n'
              '  }\n'
              '}',
        ),
        ToolSectionMetadata(
          title: 'Per-block error example',
          body:
              '{\n'
              '  "success": true,\n'
              '  "repoId": "my-repo",\n'
              '  "results": {\n'
              '    "999999": {\n'
              '      "error": "Block 999999 not found in repository my-repo"\n'
              '    }\n'
              '  }\n'
              '}',
        ),
        ToolSectionMetadata(
          title: 'Failure output',
          body:
              '{\n'
              '  "success": false,\n'
              '  "error": "Error retrieving blocks structure: No block IDs provided."\n'
              '}',
        ),
      ],
      examples: <ToolExample>[
        ToolExample(
          description: 'Read the direct parent and child order for blocks.',
          command:
              "orcanote get_blocks_structure --repo my-repo --input '{\"blockIds\":[210,211]}'",
        ),
        ToolExample(
          description: 'Inspect multiple blocks and keep raw JSON.',
          command:
              "orcanote get_blocks_structure --repo my-repo --input '{\"blockIds\":[210,211]}' --json",
        ),
      ],
    ),
  );
}
