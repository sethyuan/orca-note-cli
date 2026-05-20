import '../command_context.dart';
import '../tool_command.dart';
import '../tool_metadata.dart';

OrcaToolCommand createCreateTagsCommand(OrcaNoteCommandContext context) {
  return OrcaToolCommand(
    context: context,
    metadata: const ToolMetadata(
      name: 'create_tags',
      title: 'Create Tags',
      summary: 'Create tags and their property definitions.',
      description:
          'Creates multiple tags in one atomic operation. Each tag can define properties, including select and multi-select choices.',
      fields: <ToolFieldMetadata>[
        ToolFieldMetadata(
          name: 'repoId',
          description: 'The repository ID.',
          required: true,
          providedByRepoFlag: true,
        ),
        ToolFieldMetadata(
          name: 'tags',
          description:
              'Array of tag definitions with name, properties, and optional select options.',
          required: true,
        ),
      ],
      requiredFields: <String>['repoId', 'tags'],
      sections: <ToolSectionMetadata>[
        ToolSectionMetadata(
          title: 'Input shape',
          body:
              '{\n'
              '  "tags": [\n'
              '    {\n'
              '      "name": "task",\n'
              '      "properties": [\n'
              '        {\n'
              '          "name": "priority",\n'
              '          "type": "select",\n'
              '          "options": ["low", "medium", "high"]\n'
              '        },\n'
              '        {\n'
              '          "name": "due",\n'
              '          "type": "date"\n'
              '        }\n'
              '      ]\n'
              '    }\n'
              '  ]\n'
              '}',
        ),
        ToolSectionMetadata(
          title: 'Property types',
          body:
              '- text\n'
              '- image\n'
              '- link\n'
              '- place\n'
              '- phone\n'
              '- email\n'
              '- number\n'
              '- boolean\n'
              '- date\n'
              '- time\n'
              '- datetime\n'
              '- select\n'
              '- multi-select\n'
              '- block-ref',
        ),
        ToolSectionMetadata(
          title: 'Success output',
          body:
              '{\n'
              '  "success": true,\n'
              '  "result": [\n'
              '    {\n'
              '      "name": "task",\n'
              '      "id": 456\n'
              '    }\n'
              '  ]\n'
              '}',
        ),
        ToolSectionMetadata(
          title: 'Failure output',
          body:
              '{\n'
              '  "success": false,\n'
              '  "error": "Validation Failed",\n'
              '  "details": [\n'
              '    "Tag at index 0: Name \\"_bad\\" is invalid (cannot be empty or start with underscore)."\n'
              '  ]\n'
              '}',
        ),
      ],
      examples: <ToolExample>[
        ToolExample(
          description: 'Create a simple tag with no custom properties.',
          command:
              "orcanote create_tags --repo my-repo --input '{\"tags\":[{\"name\":\"status\"}]}'",
        ),
        ToolExample(
          description: 'Create a task tag with select and date properties.',
          command:
              "orcanote create_tags --repo my-repo --input '{\"tags\":[{\"name\":\"task\",\"properties\":[{\"name\":\"priority\",\"type\":\"select\",\"options\":[\"low\",\"medium\",\"high\"]},{\"name\":\"due\",\"type\":\"date\"}]}]}' --json",
        ),
      ],
    ),
  );
}
