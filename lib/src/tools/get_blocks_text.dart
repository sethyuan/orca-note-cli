import '../command_context.dart';
import '../tool_command.dart';
import '../tool_metadata.dart';

OrcaToolCommand createGetBlocksTextCommand(OrcaNoteCommandContext context) {
  return OrcaToolCommand(
    context: context,
    metadata: const ToolMetadata(
      name: 'get_blocks_text',
      title: 'Get Blocks Text Content',
      summary: 'Read concatenated text for blocks and their descendants.',
      description:
          'Reads the text content of one or more blocks, including descendants, and returns plain concatenated text without indentation or block IDs. Optional childStartIndex and childEndIndex let you request a partial descendant range while always keeping the root block in the result.',
      fields: <ToolFieldMetadata>[
        ToolFieldMetadata(
          name: 'repoId',
          description: 'The repository ID.',
          required: true,
          providedByRepoFlag: true,
        ),
        ToolFieldMetadata(
          name: 'blockIds',
          description: 'Array of block IDs to read.',
          required: true,
        ),
        ToolFieldMetadata(
          name: 'childStartIndex',
          description:
              'Optional 1-based inclusive start index for descendant blocks.',
          required: false,
        ),
        ToolFieldMetadata(
          name: 'childEndIndex',
          description:
              'Optional 1-based inclusive end index for descendant blocks.',
          required: false,
        ),
      ],
      requiredFields: <String>['repoId', 'blockIds'],
      examples: <ToolExample>[
        ToolExample(
          description: 'Read the full tree for one block.',
          command:
              "orcanote get_blocks_text --repo=my-repo --input='{\"blockIds\":[12345]}'",
        ),
        ToolExample(
          description: 'Read only a descendant slice for a block.',
          command:
              "orcanote get_blocks_text --repo=my-repo --input='{\"blockIds\":[12345],\"childStartIndex\":1,\"childEndIndex\":20}' --json",
        ),
      ],
    ),
  );
}
