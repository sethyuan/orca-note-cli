import '../command_context.dart';
import '../tool_command.dart';
import '../tool_metadata.dart';

OrcaToolCommand createRemoveTagsCommand(OrcaNoteCommandContext context) {
  return OrcaToolCommand(
    context: context,
    metadata: const ToolMetadata(
      name: 'remove_tags',
      title: 'Remove Tags',
      summary: 'Remove one or more tags from blocks.',
      description:
          'Removes tags from multiple blocks atomically. Missing tags on target blocks are ignored by the server.',
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
          description: 'Array of tag names to remove.',
          required: true,
        ),
      ],
      requiredFields: <String>['repoId', 'blockIds', 'tags'],
      examples: <ToolExample>[
        ToolExample(
          description: 'Remove two tags from a batch of blocks.',
          command:
              "orcanote remove_tags --repo=my-repo --input='{\"blockIds\":[1,2,3],\"tags\":[\"status\",\"related\"]}'",
        ),
        ToolExample(
          description: 'Remove tags and preserve the JSON response.',
          command:
              "orcanote remove_tags --repo=my-repo --input='{\"blockIds\":[1,2,3],\"tags\":[\"status\"]}' --json",
        ),
      ],
    ),
  );
}
