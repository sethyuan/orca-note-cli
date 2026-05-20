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
          'Adds tags to multiple blocks in one atomic operation. Tags can be plain names or objects with name and props.',
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
      sections: <ToolSectionMetadata>[
        ToolSectionMetadata(
          title: 'Input shape',
          body:
              '{\n'
              '  "blockIds": [501, 502],\n'
              '  "tags": [\n'
              '    "status",\n'
              '    {\n'
              '      "name": "related",\n'
              '      "props": {\n'
              '        "Blocks": [601, "Project A", "123"]\n'
              '      }\n'
              '    }\n'
              '  ]\n'
              '}',
        ),
        ToolSectionMetadata(
          title: 'Notes',
          body:
              '- Maximum 100 blocks and 100 tags per call.\n'
              '- Tag names must not start with _.\n'
              '- Date property values must use Unix seconds.\n'
              '- block-ref property values must be arrays of block IDs or alias strings.\n'
              '- If an alias string already exists, the reference targets that alias\'s block.\n'
              '- If an alias string does not exist, Orca Note creates an alias block automatically and uses that block as the target.\n'
              '- Pure numeric strings such as "123" are treated as aliases, not block IDs.',
        ),
        ToolSectionMetadata(
          title: 'Success output',
          body:
              '{\n'
              '  "success": true\n'
              '}',
        ),
        ToolSectionMetadata(
          title: 'Additional metadata',
          body:
              '- If preserved by the wrapper, updatedIds is the same block ID list passed in.',
        ),
        ToolSectionMetadata(
          title: 'Failure output',
          body:
              '{\n'
              '  "success": false,\n'
              '  "error": "Validation Failed",\n'
              '  "details": ["tags[0]: Tag name cannot be empty."]\n'
              '}',
        ),
      ],
      examples: <ToolExample>[
        ToolExample(
          description: 'Add tags to multiple blocks.',
          command:
              "orcanote insert_tags --repo my-repo --input '{\"blockIds\":[501,502],\"tags\":[\"status\",{\"name\":\"related\",\"props\":{\"Blocks\":[601,\"Project A\",\"123\"]}}]}'",
        ),
        ToolExample(
          description: 'Add a tag with properties and keep the raw JSON.',
          command:
              "orcanote insert_tags --repo my-repo --input '{\"blockIds\":[501],\"tags\":[{\"name\":\"related\",\"props\":{\"Blocks\":[601,\"Project A\",\"123\"]}}]}' --json",
        ),
      ],
    ),
  );
}
