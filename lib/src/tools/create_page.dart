import '../command_context.dart';
import '../tool_command.dart';
import '../tool_metadata.dart';

OrcaToolCommand createCreatePageCommand(OrcaNoteCommandContext context) {
  return OrcaToolCommand(
    context: context,
    metadata: const ToolMetadata(
      name: 'create_page',
      title: 'Create Page',
      summary: 'Create a new page by alias name.',
      description:
          'Creates a new aliased page in the repository. Optionally include the page in other pages by providing includeIn names.',
      fields: <ToolFieldMetadata>[
        ToolFieldMetadata(
          name: 'repoId',
          description: 'The repository ID.',
          required: true,
          providedByRepoFlag: true,
        ),
        ToolFieldMetadata(
          name: 'name',
          description:
              'The page name to create. It must not start with an underscore.',
          required: true,
        ),
        ToolFieldMetadata(
          name: 'includeIn',
          description:
              'Optional list of page names that should include the new page.',
          required: false,
        ),
      ],
      requiredFields: <String>['repoId', 'name'],
      examples: <ToolExample>[
        ToolExample(
          description: 'Create a plain page.',
          command:
              "orcanote create_page --repo=my-repo --input='{\"name\":\"Roadmap\"}'",
        ),
        ToolExample(
          description: 'Create a page and include it in two other pages.',
          command:
              "orcanote create_page --repo=my-repo --input='{\"name\":\"Roadmap\",\"includeIn\":[\"Projects\",\"Planning\"]}' --json",
        ),
      ],
    ),
  );
}
