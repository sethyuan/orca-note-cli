import '../command_context.dart';
import '../tool_command.dart';
import '../tool_metadata.dart';

OrcaToolCommand createMoveBlocksCommand(OrcaNoteCommandContext context) {
  return OrcaToolCommand(
    context: context,
    metadata: const ToolMetadata(
      name: 'move_blocks',
      title: 'Move Blocks',
      summary: 'Move blocks under a new parent block.',
      description:
          'Moves one or more blocks to a different parent. Optionally place them after a specific sibling using leftId.',
      fields: <ToolFieldMetadata>[
        ToolFieldMetadata(
          name: 'repoId',
          description: 'The repository ID.',
          required: true,
          providedByRepoFlag: true,
        ),
        ToolFieldMetadata(
          name: 'blockIds',
          description: 'Array of block IDs to move.',
          required: true,
        ),
        ToolFieldMetadata(
          name: 'parentId',
          description: 'The ID of the new parent block.',
          required: true,
        ),
        ToolFieldMetadata(
          name: 'leftId',
          description: 'Optional sibling block ID to insert after.',
          required: false,
        ),
      ],
      requiredFields: <String>['repoId', 'blockIds', 'parentId'],
      examples: <ToolExample>[
        ToolExample(
          description: 'Move two blocks under a new parent.',
          command:
              "orcanote move_blocks --repo=my-repo --input='{\"blockIds\":[101,102],\"parentId\":999}'",
        ),
        ToolExample(
          description:
              'Move blocks after a specific sibling and keep raw JSON.',
          command:
              "orcanote move_blocks --repo=my-repo --input='{\"blockIds\":[101,102],\"parentId\":999,\"leftId\":555}' --json",
        ),
      ],
    ),
  );
}
