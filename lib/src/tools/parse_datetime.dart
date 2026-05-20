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
          'Parses a date/time string using local time and returns both a Unix timestamp in seconds and a formatted local datetime string.',
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
      sections: <ToolSectionMetadata>[
        ToolSectionMetadata(
          title: 'Input shape',
          body:
              '{\n'
              '  "text": "3 days later",\n'
              '  "referenceTimestamp": 1778932800\n'
              '}',
        ),
        ToolSectionMetadata(
          title: 'Notes',
          body:
              '- text is required.\n'
              '- referenceTimestamp is optional and must be a Unix timestamp in seconds.\n'
              '- Supports ISO strings, natural language in English, and now for the current local date and time.',
        ),
        ToolSectionMetadata(
          title: 'Success output',
          body:
              '{\n'
              '  "success": true,\n'
              '  "timestamp": 1779199200,\n'
              '  "formattedDatetime": "2026-05-18 09:20:00 +08:00"\n'
              '}',
        ),
        ToolSectionMetadata(
          title: 'Failure output',
          body:
              '{\n'
              '  "success": false,\n'
              '  "error": "Error parsing date/time: Could not parse date/time string: not a date"\n'
              '}',
        ),
      ],
      examples: <ToolExample>[
        ToolExample(
          description: 'Parse a local date/time string.',
          command:
              "orcanote parse_datetime --input '{\"text\":\"3 days later\",\"referenceTimestamp\":1778932800}'",
        ),
        ToolExample(
          description: 'Parse a natural-language date and keep raw JSON.',
          command:
              "orcanote parse_datetime --input '{\"text\":\"next friday 9am\"}' --json",
        ),
      ],
    ),
  );
}
