import '../command_context.dart';
import '../tool_command.dart';
import '../tool_metadata.dart';

OrcaToolCommand createDeleteBlocksCommand(OrcaNoteCommandContext context) {
  return OrcaToolCommand(
    context: context,
    metadata: const ToolMetadata(
      name: 'delete_blocks',
      title: 'Delete Blocks',
      summary: 'Delete multiple blocks by ID.',
      description:
          'Deletes blocks by ID. blockIds must be a non-empty array of numeric block IDs.',
      fields: <ToolFieldMetadata>[
        ToolFieldMetadata(
          name: 'repoId',
          description: 'The repository ID.',
          required: true,
          providedByRepoFlag: true,
        ),
        ToolFieldMetadata(
          name: 'blockIds',
          description: 'Array of block IDs to delete.',
          required: true,
        ),
      ],
      requiredFields: <String>['repoId', 'blockIds'],
      sections: <ToolSectionMetadata>[
        ToolSectionMetadata(
          title: 'Input shape',
          body:
              '{\n'
              '  "blockIds": [101, 102, 103]\n'
              '}',
        ),
        ToolSectionMetadata(
          title: 'Notes',
          body: '- blockIds must be a non-empty array of numeric block IDs.',
        ),
        ToolSectionMetadata(
          title: 'Success output',
          body:
              '{\n'
              '  "success": true\n'
              '}',
        ),
        ToolSectionMetadata(
          title: 'Failure output',
          body:
              '{\n'
              '  "success": false,\n'
              '  "error": "No block IDs provided for deletion."\n'
              '}',
        ),
      ],
      examples: <ToolExample>[
        ToolExample(
          description: 'Delete a batch of blocks.',
          command:
              "orcanote delete_blocks --repo my-repo --input '{\"blockIds\":[101,102,103]}'",
        ),
        ToolExample(
          description: 'Delete blocks and keep the raw JSON response.',
          command:
              "orcanote delete_blocks --repo my-repo --input '{\"blockIds\":[101,102,103]}' --json",
        ),
      ],
    ),
  );
}
