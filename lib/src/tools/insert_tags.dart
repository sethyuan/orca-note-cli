import '../command_context.dart';
import '../tool_command.dart';
import '../tool_metadata.dart';

OrcaToolCommand createInsertTagsCommand(OrcaNoteCommandContext context) {
  return OrcaToolCommand(
    context: context,
    metadata: const ToolMetadata(
      name: 'insert_tags',
      title: 'Insert Tags',
      summary: 'Attach one or more tags to blocks in one operation.',
      description:
          'Adds tags to multiple blocks atomically. Tags can be simple names or objects that include tag properties.',
      fields: <ToolFieldMetadata>[
        ToolFieldMetadata(
          name: 'repoId',
          description: 'The repository ID.',
          required: true,
          providedByRepoFlag: true,
        ),
        ToolFieldMetadata(
          name: 'blockIds',
          description: 'Array of block IDs to update.',
          required: true,
        ),
        ToolFieldMetadata(
          name: 'tags',
          description: 'Array of tag names or tag objects with name and props.',
          required: true,
        ),
      ],
      requiredFields: <String>['repoId', 'blockIds', 'tags'],
      examples: <ToolExample>[
        ToolExample(
          description: 'Add simple tags to two blocks.',
          command:
              "orcanote insert_tags --repo my-repo --input '{\"blockIds\":[1,2],\"tags\":[\"status\",\"important\"]}'",
        ),
        ToolExample(
          description: 'Add a tag with properties and keep the raw JSON.',
          command:
              "orcanote insert_tags --repo my-repo --input '{\"blockIds\":[1],\"tags\":[{\"name\":\"related\",\"props\":{\"Blocks\":[4,5]}}]}' --json",
        ),
      ],
    ),
  );
}
