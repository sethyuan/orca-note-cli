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
          'Returns the direct parent block ID and ordered child block IDs for one or more blocks. Use this to inspect structure before moving, deleting, or inserting blocks relative to existing content.',
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
      examples: <ToolExample>[
        ToolExample(
          description: 'Read the parent and children for one block.',
          command:
              "orcanote get_blocks_structure --repo my-repo --input '{\"blockIds\":[12345]}'",
        ),
        ToolExample(
          description: 'Inspect multiple blocks and keep raw JSON.',
          command:
              "orcanote get_blocks_structure --repo my-repo --input '{\"blockIds\":[12345,67890]}' --json",
        ),
      ],
    ),
  );
}
