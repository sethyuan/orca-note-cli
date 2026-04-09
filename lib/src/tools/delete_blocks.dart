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
          'Deletes one or more blocks from the repository in a single tool call.',
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
      examples: <ToolExample>[
        ToolExample(
          description: 'Delete two blocks and show formatted output.',
          command:
              "orcanote delete_blocks --repo=my-repo --input='{\"blockIds\":[4001,4002]}'",
        ),
        ToolExample(
          description: 'Delete blocks and keep the raw JSON response.',
          command:
              "orcanote delete_blocks --repo=my-repo --input='{\"blockIds\":[4001,4002]}' --json",
        ),
      ],
    ),
  );
}
