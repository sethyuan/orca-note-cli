import '../command_context.dart';
import '../tool_command.dart';
import '../tool_metadata.dart';

OrcaToolCommand createInsertMarkdownCommand(OrcaNoteCommandContext context) {
  return OrcaToolCommand(
    context: context,
    metadata: const ToolMetadata(
      name: 'insert_markdown',
      title: 'Insert Markdown Text',
      summary: 'Insert plain text or Markdown near a reference block.',
      description:
          'Inserts Markdown with optional tags and tag properties relative to a reference block. If position is omitted, the tool uses Orca Note\'s smart default insertion behavior.',
      fields: <ToolFieldMetadata>[
        ToolFieldMetadata(
          name: 'repoId',
          description: 'The repository ID.',
          required: true,
          providedByRepoFlag: true,
        ),
        ToolFieldMetadata(
          name: 'refBlockId',
          description:
              'Reference block ID used to resolve the insertion position.',
          required: true,
        ),
        ToolFieldMetadata(
          name: 'position',
          description:
              'Optional insertion position: before, after, firstChild, or lastChild.',
          required: false,
        ),
        ToolFieldMetadata(
          name: 'text',
          description: 'Plain text or Markdown content to insert.',
          required: true,
        ),
      ],
      requiredFields: <String>['repoId', 'refBlockId', 'text'],
      sections: <ToolSectionMetadata>[
        ToolSectionMetadata(
          title: 'Input shape',
          body:
              '{\n'
              '  "refBlockId": 401,\n'
              '  "position": "lastChild",\n'
              '  "text": "# Agenda #Meeting{\\"Location\\":\\"Room A\\"}\\n- Review status\\n- Plan next step"\n'
              '}',
        ),
        ToolSectionMetadata(
          title: 'Valid position values',
          body:
              '- before\n'
              '- after\n'
              '- firstChild\n'
              '- lastChild',
        ),
        ToolSectionMetadata(
          title: 'Notes',
          body:
              '- text is required.\n'
              '- Tag syntax: #Tag Name or #Tag Name{"Property":"Value"} after the content, before the line break.\n'
              '- Add tag properties by appending a single-line JSON object immediately after the tag name.\n'
              '- Date property values must use Unix seconds.\n'
              '- block-ref property values must be arrays of block IDs or alias strings; missing aliases are created automatically.',
        ),
        ToolSectionMetadata(
          title: 'Success output',
          body:
              '{\n'
              '  "success": true,\n'
              '  "blockId": 1001,\n'
              '  "insertedCount": 3\n'
              '}',
        ),
        ToolSectionMetadata(
          title: 'Failure output',
          body:
              '{\n'
              '  "success": false,\n'
              '  "error": "Reference block with ID 401 not found in repository my-repo"\n'
              '}',
        ),
      ],
      examples: <ToolExample>[
        ToolExample(
          description: 'Insert Markdown with tags under a reference block.',
          command:
              "orcanote insert_markdown --repo my-repo --input '{\"refBlockId\":401,\"position\":\"lastChild\",\"text\":\"# Agenda #Meeting{\\\"Location\\\":\\\"Room A\\\"}\\n- Review status\\n- Plan next step\"}'",
        ),
        ToolExample(
          description:
              'Insert markdown relative to a block and keep JSON output.',
          command:
              "orcanote insert_markdown --repo my-repo --input '{\"refBlockId\":401,\"position\":\"before\",\"text\":\"# Release notes\"}' --json",
        ),
      ],
    ),
  );
}
