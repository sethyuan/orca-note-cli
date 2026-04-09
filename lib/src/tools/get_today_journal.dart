import '../command_context.dart';
import '../tool_command.dart';
import '../tool_metadata.dart';

OrcaToolCommand createGetTodayJournalCommand(OrcaNoteCommandContext context) {
  return OrcaToolCommand(
    context: context,
    metadata: const ToolMetadata(
      name: 'get_today_journal',
      title: 'Get Today\'s Journal ID',
      summary: 'Fetch or create today\'s journal block.',
      description:
          'Returns the journal block ID for today. If today\'s journal does not exist yet, Orca Note creates it automatically before returning the result.',
      fields: <ToolFieldMetadata>[
        ToolFieldMetadata(
          name: 'repoId',
          description: 'The repository ID.',
          required: true,
          providedByRepoFlag: true,
        ),
      ],
      requiredFields: <String>['repoId'],
      examples: <ToolExample>[
        ToolExample(
          description: 'Fetch today\'s journal and render it as text.',
          command: 'orcanote get_today_journal --repo my-repo',
        ),
        ToolExample(
          description: 'Fetch today\'s journal and keep the raw JSON.',
          command: 'orcanote get_today_journal --repo my-repo --json',
        ),
      ],
    ),
  );
}
