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
          'Parses plain text or Markdown and inserts the resulting blocks into the repository relative to a reference block.',
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
          description: 'Optional insertion position relative to refBlockId.',
          required: false,
        ),
        ToolFieldMetadata(
          name: 'text',
          description: 'Plain text or Markdown content to insert.',
          required: true,
        ),
      ],
      requiredFields: <String>['repoId', 'refBlockId', 'text'],
      examples: <ToolExample>[
        ToolExample(
          description: 'Insert a short Markdown bullet list after a block.',
          command:
              "orcanote insert_markdown --repo my-repo --input '{\"refBlockId\":12345,\"text\":\"- ship cli\\n- write docs\"}'",
        ),
        ToolExample(
          description:
              'Insert Markdown before a reference block and keep JSON output.',
          command:
              "orcanote insert_markdown --repo my-repo --input '{\"refBlockId\":12345,\"position\":\"before\",\"text\":\"# Release notes\"}' --json",
        ),
      ],
    ),
  );
}
