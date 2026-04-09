import '../command_context.dart';
import '../tool_command.dart';
import '../tool_metadata.dart';

OrcaToolCommand createGetPageCommand(OrcaNoteCommandContext context) {
  return OrcaToolCommand(
    context: context,
    metadata: const ToolMetadata(
      name: 'get_page',
      title: 'Get Page/Journal Block',
      summary: 'Find the page or journal that contains the given blocks.',
      description:
          'Returns the page or journal block metadata for one or more block IDs. Use this when you need to resolve descendant blocks back to their owning page.',
      fields: <ToolFieldMetadata>[
        ToolFieldMetadata(
          name: 'repoId',
          description: 'The repository ID.',
          required: true,
          providedByRepoFlag: true,
        ),
        ToolFieldMetadata(
          name: 'blockIds',
          description:
              'Array of block IDs whose parent page should be resolved.',
          required: true,
        ),
      ],
      requiredFields: <String>['repoId', 'blockIds'],
      examples: <ToolExample>[
        ToolExample(
          description: 'Resolve one block back to its page.',
          command:
              "orcanote get_page --repo my-repo --input '{\"blockIds\":[12345]}'",
        ),
        ToolExample(
          description: 'Resolve multiple blocks and keep raw JSON.',
          command:
              "orcanote get_page --repo my-repo --input '{\"blockIds\":[12345,67890]}' --json",
        ),
      ],
    ),
  );
}
