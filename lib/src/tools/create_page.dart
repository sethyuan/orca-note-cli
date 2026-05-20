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
          'Creates a new page alias. Provide only non-repoId fields inside --input. The page name is required and must not start with an underscore.',
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
      sections: <ToolSectionMetadata>[
        ToolSectionMetadata(
          title: 'Input shape',
          body:
              '{\n'
              '  "name": "Project Roadmap",\n'
              '  "includeIn": ["Projects", "Planning"]\n'
              '}',
        ),
        ToolSectionMetadata(
          title: 'Notes',
          body:
              '- name is required and must not start with _.\n'
              '- includeIn is optional and lists page names to place into _is.',
        ),
        ToolSectionMetadata(
          title: 'Success output',
          body:
              '{\n'
              '  "success": true,\n'
              '  "blockId": 123\n'
              '}',
        ),
        ToolSectionMetadata(
          title: 'Failure output',
          body:
              '{\n'
              '  "success": false,\n'
              '  "error": "Page name already exists (block 123)."\n'
              '}',
        ),
      ],
      examples: <ToolExample>[
        ToolExample(
          description: 'Create a page alias.',
          command:
              "orcanote create_page --repo my-repo --input '{\"name\":\"Project Roadmap\"}'",
        ),
        ToolExample(
          description: 'Create a page and include it in two other pages.',
          command:
              "orcanote create_page --repo my-repo --input '{\"name\":\"Project Roadmap\",\"includeIn\":[\"Projects\",\"Planning\"]}' --json",
        ),
      ],
    ),
  );
}
