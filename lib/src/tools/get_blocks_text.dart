import '../command_context.dart';
import '../tool_command.dart';
import '../tool_metadata.dart';

OrcaToolCommand createGetBlocksTextCommand(OrcaNoteCommandContext context) {
  return OrcaToolCommand(
    context: context,
    metadata: const ToolMetadata(
      name: 'get_blocks_text',
      title: 'Get Blocks Text Content',
      summary: 'Read structured text for blocks and their descendants.',
      description:
          'Returns structured text for root blocks and their descendants. The root block is always included, even when you request a descendant slice.',
      fields: <ToolFieldMetadata>[
        ToolFieldMetadata(
          name: 'repoId',
          description: 'The repository ID.',
          required: true,
          providedByRepoFlag: true,
        ),
        ToolFieldMetadata(
          name: 'blockIds',
          description: 'Array of block IDs to read.',
          required: true,
        ),
        ToolFieldMetadata(
          name: 'childStartIndex',
          description:
              'Optional 1-based inclusive start index for descendant blocks.',
          required: false,
        ),
        ToolFieldMetadata(
          name: 'childEndIndex',
          description:
              'Optional 1-based inclusive end index for descendant blocks.',
          required: false,
        ),
      ],
      requiredFields: <String>['repoId', 'blockIds'],
      sections: <ToolSectionMetadata>[
        ToolSectionMetadata(
          title: 'Input shape',
          body:
              '{\n'
              '  "blockIds": [201, 202],\n'
              '  "childStartIndex": 1,\n'
              '  "childEndIndex": 20\n'
              '}',
        ),
        ToolSectionMetadata(
          title: 'Notes',
          body:
              '- The root block is always included.\n'
              '- childStartIndex and childEndIndex are both optional, but they must be supplied together.\n'
              '- Child ranges are 1-based and inclusive.',
        ),
        ToolSectionMetadata(
          title: 'Success output',
          body:
              '{\n'
              '  "success": true,\n'
              '  "repoId": "my-repo",\n'
              '  "results": [\n'
              '    {\n'
              '      "blockId": 201,\n'
              '      "blocks": [\n'
              '        {\n'
              '          "id": 201,\n'
              '          "text": "Root block"\n'
              '        },\n'
              '        {\n'
              '          "id": 202,\n'
              '          "text": "Child block and [Root block]",\n'
              '          "links": [201]\n'
              '        }\n'
              '      ]\n'
              '    }\n'
              '  ]\n'
              '}',
        ),
        ToolSectionMetadata(
          title: 'Failure output',
          body:
              '{\n'
              '  "success": false,\n'
              '  "error": "childStartIndex and childEndIndex must be provided together."\n'
              '}',
        ),
      ],
      examples: <ToolExample>[
        ToolExample(
          description: 'Read the full tree for one or more root blocks.',
          command:
              "orcanote get_blocks_text --repo my-repo --input '{\"blockIds\":[201,202]}'",
        ),
        ToolExample(
          description: 'Read only a descendant slice for a block.',
          command:
              "orcanote get_blocks_text --repo my-repo --input '{\"blockIds\":[201],\"childStartIndex\":1,\"childEndIndex\":20}' --json",
        ),
      ],
    ),
  );
}
