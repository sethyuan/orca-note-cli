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
          'Finds the containing page or journal for each block. Use this to resolve descendant blocks back to their owning page.',
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
      sections: <ToolSectionMetadata>[
        ToolSectionMetadata(
          title: 'Input shape',
          body:
              '{\n'
              '  "blockIds": [301, 302]\n'
              '}',
        ),
        ToolSectionMetadata(
          title: 'Success output',
          body:
              '{\n'
              '  "success": true,\n'
              '  "results": [\n'
              '    {\n'
              '      "blockId": 301,\n'
              '      "pageId": 900,\n'
              '      "pageName": "Project Roadmap"\n'
              '    },\n'
              '    {\n'
              '      "blockId": 302,\n'
              '      "error": "Block is not under any page."\n'
              '    }\n'
              '  ]\n'
              '}',
        ),
        ToolSectionMetadata(
          title: 'Failure output',
          body:
              '{\n'
              '  "success": false,\n'
              '  "error": "Error retrieving page: ..."\n'
              '}',
        ),
      ],
      examples: <ToolExample>[
        ToolExample(
          description: 'Resolve blocks back to their containing page.',
          command:
              "orcanote get_page --repo my-repo --input '{\"blockIds\":[301,302]}'",
        ),
        ToolExample(
          description: 'Resolve multiple blocks and keep raw JSON.',
          command:
              "orcanote get_page --repo my-repo --input '{\"blockIds\":[301,302]}' --json",
        ),
      ],
    ),
  );
}
