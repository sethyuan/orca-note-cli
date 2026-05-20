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
          'Removes tags from multiple blocks in one atomic operation. Missing tags on a block are ignored.',
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
      sections: <ToolSectionMetadata>[
        ToolSectionMetadata(
          title: 'Input shape',
          body:
              '{\n'
              '  "blockIds": [901, 902],\n'
              '  "tags": ["status", "related"]\n'
              '}',
        ),
        ToolSectionMetadata(
          title: 'Notes',
          body:
              '- Maximum 100 blocks and 100 tags per call.\n'
              '- Missing tags on a block are ignored.\n'
              '- Tag names must not start with _.',
        ),
        ToolSectionMetadata(
          title: 'Success output',
          body:
              '{\n'
              '  "success": true,\n'
              '  "updatedIds": [901, 902]\n'
              '}',
        ),
        ToolSectionMetadata(
          title: 'Failure output',
          body:
              '{\n'
              '  "success": false,\n'
              '  "error": "Validation Failed",\n'
              '  "details": ["tags[0]: Tag name cannot start with underscore."]\n'
              '}',
        ),
      ],
      examples: <ToolExample>[
        ToolExample(
          description: 'Remove tags from multiple blocks.',
          command:
              "orcanote remove_tags --repo my-repo --input '{\"blockIds\":[901,902],\"tags\":[\"status\",\"related\"]}'",
        ),
        ToolExample(
          description: 'Remove tags and preserve the JSON response.',
          command:
              "orcanote remove_tags --repo my-repo --input '{\"blockIds\":[901,902],\"tags\":[\"status\"]}' --json",
        ),
      ],
    ),
  );
}
