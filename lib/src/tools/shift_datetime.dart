import '../command_context.dart';
import '../tool_command.dart';
import '../tool_metadata.dart';

OrcaToolCommand createShiftDatetimeCommand(OrcaNoteCommandContext context) {
  return OrcaToolCommand(
    context: context,
    metadata: const ToolMetadata(
      name: 'shift_datetime',
      title: 'Shift Date And Time',
      summary: 'Apply a relative offset to a Unix timestamp.',
      description:
          'Applies a relative offset to a base Unix timestamp in seconds and returns both the resulting timestamp and a formatted local datetime string.',
      fields: <ToolFieldMetadata>[
        ToolFieldMetadata(
          name: 'baseTimestamp',
          description: 'The base Unix timestamp in seconds.',
          required: true,
        ),
        ToolFieldMetadata(
          name: 'amount',
          description:
              'The signed amount to add to the base timestamp. Use negative values for past times.',
          required: true,
        ),
        ToolFieldMetadata(
          name: 'unit',
          description:
              'The offset unit: s=seconds, m=minutes, h=hours, d=days, w=weeks, M=months, y=years.',
          required: true,
        ),
      ],
      requiredFields: <String>['baseTimestamp', 'amount', 'unit'],
      sections: <ToolSectionMetadata>[
        ToolSectionMetadata(
          title: 'Input shape',
          body:
              '{\n'
              '  "baseTimestamp": 1778932800,\n'
              '  "amount": -3,\n'
              '  "unit": "d"\n'
              '}',
        ),
        ToolSectionMetadata(
          title: 'Valid unit values',
          body:
              '- s\n'
              '- m\n'
              '- h\n'
              '- d\n'
              '- w\n'
              '- M\n'
              '- y',
        ),
        ToolSectionMetadata(
          title: 'Success output',
          body:
              '{\n'
              '  "success": true,\n'
              '  "timestamp": 1778673600,\n'
              '  "formattedDatetime": "2026-05-12 09:20:00 +08:00"\n'
              '}',
        ),
        ToolSectionMetadata(
          title: 'Failure output',
          body:
              '{\n'
              '  "success": false,\n'
              '  "error": "Error shifting date/time: ..."\n'
              '}',
        ),
      ],
      examples: <ToolExample>[
        ToolExample(
          description: 'Shift a timestamp three days into the past.',
          command:
              "orcanote shift_datetime --input '{\"baseTimestamp\":1778932800,\"amount\":-3,\"unit\":\"d\"}'",
        ),
        ToolExample(
          description:
              'Shift a timestamp forward by two weeks and keep raw JSON.',
          command:
              "orcanote shift_datetime --input '{\"baseTimestamp\":1778932800,\"amount\":2,\"unit\":\"w\"}' --json",
        ),
      ],
    ),
  );
}
