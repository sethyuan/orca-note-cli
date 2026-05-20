import '../command_context.dart';
import '../tool_command.dart';
import '../tool_metadata.dart';

OrcaToolCommand createGetTagsAndPagesCommand(OrcaNoteCommandContext context) {
  return OrcaToolCommand(
    context: context,
    metadata: const ToolMetadata(
      name: 'get_tags_and_pages',
      title: 'Get Tags and Pages List',
      summary: 'List tags and pages from a repository with pagination.',
      description:
          'Lists tags and pages with pagination. Returned properties exclude names that start with an underscore.',
      fields: <ToolFieldMetadata>[
        ToolFieldMetadata(
          name: 'repoId',
          description: 'The repository ID.',
          required: true,
          providedByRepoFlag: true,
        ),
        ToolFieldMetadata(
          name: 'pageNum',
          description: 'Page number starting from 1.',
          required: false,
        ),
        ToolFieldMetadata(
          name: 'pageSize',
          description: 'Number of items returned per page.',
          required: false,
        ),
      ],
      requiredFields: <String>['repoId'],
      sections: <ToolSectionMetadata>[
        ToolSectionMetadata(
          title: 'Input shape',
          body:
              '{\n'
              '  "pageNum": 1,\n'
              '  "pageSize": 200\n'
              '}',
        ),
        ToolSectionMetadata(
          title: 'Notes',
          body:
              '- pageNum defaults to 1.\n'
              '- pageSize defaults to 200.\n'
              '- Returned properties exclude names that start with _.',
        ),
        ToolSectionMetadata(
          title: 'Success output',
          body:
              '{\n'
              '  "success": true,\n'
              '  "pagination": {\n'
              '    "pageNum": 1,\n'
              '    "pageSize": 200\n'
              '  },\n'
              '  "tags": {\n'
              '    "total": 20,\n'
              '    "totalPages": 1,\n'
              '    "items": [\n'
              '      {\n'
              '        "id": 11,\n'
              '        "name": "task",\n'
              '        "properties": [\n'
              '          {\n'
              '            "name": "priority",\n'
              '            "type": "TextChoices",\n'
              '            "details": {\n'
              '              "subType": "single",\n'
              '              "choices": ["low", "medium", "high"]\n'
              '            }\n'
              '          }\n'
              '        ]\n'
              '      }\n'
              '    ]\n'
              '  },\n'
              '  "pages": {\n'
              '    "total": 50,\n'
              '    "totalPages": 1,\n'
              '    "items": [\n'
              '      {\n'
              '        "id": 22,\n'
              '        "name": "Project Roadmap",\n'
              '        "properties": []\n'
              '      }\n'
              '    ]\n'
              '  }\n'
              '}',
        ),
        ToolSectionMetadata(
          title: 'Failure output',
          body:
              '{\n'
              '  "success": false,\n'
              '  "error": "Could not retrieve tags or pages from repository: my-repo"\n'
              '}',
        ),
      ],
      examples: <ToolExample>[
        ToolExample(
          description:
              'Fetch the first page with the default output formatter.',
          command: 'orcanote get_tags_and_pages --repo my-repo',
        ),
        ToolExample(
          description: 'Fetch a smaller page and keep the JSON payload.',
          command:
              "orcanote get_tags_and_pages --repo my-repo --input '{\"pageNum\":1,\"pageSize\":50}' --json",
        ),
      ],
    ),
  );
}
