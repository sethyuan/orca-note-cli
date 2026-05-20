import '../command_context.dart';
import '../tool_command.dart';
import '../tool_metadata.dart';

OrcaToolCommand createGetJournalCommand(OrcaNoteCommandContext context) {
  return OrcaToolCommand(
    context: context,
    metadata: const ToolMetadata(
      name: 'get_journal',
      title: 'Get Journal ID',
      summary: 'Fetch or create a journal block for a date.',
      description:
          'Returns the journal block ID for the requested date. If no journal exists for that date yet, Orca Note creates it automatically. When date is omitted, the tool targets today.',
      fields: <ToolFieldMetadata>[
        ToolFieldMetadata(
          name: 'repoId',
          description: 'The repository ID.',
          required: true,
          providedByRepoFlag: true,
        ),
        ToolFieldMetadata(
          name: 'date',
          description:
              'Optional Unix timestamp in seconds for the target journal date.',
          required: false,
        ),
      ],
      requiredFields: <String>['repoId'],
      examples: <ToolExample>[
        ToolExample(
          description: 'Fetch or create today\'s journal.',
          command: 'orcanote get_journal --repo my-repo',
        ),
        ToolExample(
          description:
              'Fetch or create the journal for a specific date and keep raw JSON.',
          command:
              "orcanote get_journal --repo my-repo --input '{\"date\":1776432000}' --json",
        ),
      ],
    ),
  );
}
