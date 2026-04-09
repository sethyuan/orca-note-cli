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
          'Fetches tags and page blocks from an Orca Note repository. The response includes tag property definitions and supports paging through large repositories.',
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
