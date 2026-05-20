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
          'Moves blocks under a new parent. If leftId is omitted, the tool appends near the end of the target parent\'s children.',
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
      sections: <ToolSectionMetadata>[
        ToolSectionMetadata(
          title: 'Input shape',
          body:
              '{\n'
              '  "blockIds": [701, 702],\n'
              '  "parentId": 800,\n'
              '  "leftId": 799\n'
              '}',
        ),
        ToolSectionMetadata(title: 'Notes', body: '- leftId is optional.'),
        ToolSectionMetadata(
          title: 'Success output',
          body:
              '{\n'
              '  "success": true,\n'
              '  "message": "Successfully moved 2 blocks to parent 800."\n'
              '}',
        ),
        ToolSectionMetadata(
          title: 'Additional metadata',
          body:
              '- If preserved by the wrapper, updatedIds contains changed block IDs and the destination parentId.',
        ),
        ToolSectionMetadata(
          title: 'Failure output',
          body:
              '{\n'
              '  "success": false,\n'
              '  "error": "Invalid parent ID"\n'
              '}',
        ),
      ],
      examples: <ToolExample>[
        ToolExample(
          description: 'Move blocks to a new parent.',
          command:
              "orcanote move_blocks --repo my-repo --input '{\"blockIds\":[701,702],\"parentId\":800}'",
        ),
        ToolExample(
          description:
              'Move blocks after a specific sibling and keep raw JSON.',
          command:
              "orcanote move_blocks --repo my-repo --input '{\"blockIds\":[701,702],\"parentId\":800,\"leftId\":799}' --json",
        ),
      ],
    ),
  );
}
