import '../command_context.dart';
import '../tool_command.dart';
import '../tool_metadata.dart';

OrcaToolCommand createParseDatetimeCommand(OrcaNoteCommandContext context) {
  return OrcaToolCommand(
    context: context,
    metadata: const ToolMetadata(
      name: 'parse_datetime',
      title: 'Parse Date And Time',
      summary: 'Parse a local date/time string into a timestamp.',
      description:
          'Parses a date/time string using local time and returns both a Unix timestamp in seconds and a formatted local datetime string. Supports ISO strings, natural language in English, and now.',
      fields: <ToolFieldMetadata>[
        ToolFieldMetadata(
          name: 'text',
          description: 'The date/time string to parse.',
          required: true,
        ),
        ToolFieldMetadata(
          name: 'referenceTimestamp',
          description:
              'Optional Unix timestamp in seconds used as the reference time for relative expressions.',
          required: false,
        ),
      ],
      requiredFields: <String>['text'],
      examples: <ToolExample>[
        ToolExample(
          description: 'Parse a natural-language date and time.',
          command:
              "orcanote parse_datetime --input '{\"text\":\"next friday 9am\"}'",
        ),
        ToolExample(
          description:
              'Parse a relative expression using a fixed reference timestamp and keep raw JSON.',
          command:
              "orcanote parse_datetime --input '{\"text\":\"3 days later\",\"referenceTimestamp\":1778932800}' --json",
        ),
      ],
    ),
  );
}
