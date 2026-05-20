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
          'Returns the journal block ID for a specified date, creating it if needed. If date is omitted, today is used.',
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
      sections: <ToolSectionMetadata>[
        ToolSectionMetadata(
          title: 'Input shape',
          body:
              '{\n'
              '  "date": 1776432000\n'
              '}',
        ),
        ToolSectionMetadata(
          title: 'Notes',
          body:
              '- date is optional and must be a Unix timestamp in seconds.\n'
              '- repoId is provided by --repo, not inside --input.',
        ),
        ToolSectionMetadata(
          title: 'Success output',
          body:
              '{\n'
              '  "success": true,\n'
              '  "blockId": 777,\n'
              '  "date": "2026-04-11"\n'
              '}',
        ),
        ToolSectionMetadata(
          title: 'Failure output',
          body:
              '{\n'
              '  "success": false,\n'
              '  "error": "Error retrieving journal: ..."\n'
              '}',
        ),
      ],
      examples: <ToolExample>[
        ToolExample(
          description: 'Fetch or create today\'s journal.',
          command: 'orcanote get_journal --repo my-repo',
        ),
        ToolExample(
          description: 'Fetch or create the journal for a specific date.',
          command:
              "orcanote get_journal --repo my-repo --input '{\"date\":1776432000}' --json",
        ),
      ],
    ),
  );
}
