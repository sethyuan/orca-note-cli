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
          'Creates multiple tags in one atomic operation. Each tag can include a list of property definitions and select options.',
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
      examples: <ToolExample>[
        ToolExample(
          description: 'Create a simple tag with no custom properties.',
          command:
              "orcanote create_tags --repo=my-repo --input='{\"tags\":[{\"name\":\"status\"}]}'",
        ),
        ToolExample(
          description:
              'Create a tag with a select property and keep the JSON payload.',
          command:
              "orcanote create_tags --repo=my-repo --input='{\"tags\":[{\"name\":\"priority\",\"properties\":[{\"name\":\"level\",\"type\":\"select\",\"options\":[\"high\",\"medium\",\"low\"]}]}]}' --json",
        ),
      ],
    ),
  );
}
