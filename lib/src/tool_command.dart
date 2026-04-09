import 'dart:io';

import 'package:args/command_runner.dart';

import 'command_context.dart';
import 'json_support.dart';
import 'output_formatter.dart';
import 'tool_metadata.dart';

class OrcaToolCommand extends Command<int> {
  OrcaToolCommand({required this.context, required this.metadata}) {
    argParser
      ..addOption(
        'repo',
        abbr: 'r',
        help:
            'Orca Note repository ID. This is sent to the MCP tool as repoId.',
      )
      ..addOption(
        'input',
        help:
            'JSON object string with additional tool arguments except repoId.',
      )
      ..addFlag(
        'json',
        negatable: false,
        help: 'Print the raw tool JSON payload instead of formatted text.',
      );
  }

  final OrcaNoteCommandContext context;
  final ToolMetadata metadata;

  @override
  String get name => metadata.name;

  @override
  String get description => metadata.summary;

  @override
  String get invocation {
    return "orcanote ${metadata.name} --repo=<repoId> [--input='{...}'] [--json]";
  }

  @override
  String get usage {
    final buffer = StringBuffer(super.usage);
    buffer
      ..writeln()
      ..writeln(metadata.description);

    if (metadata.fields.isNotEmpty) {
      buffer
        ..writeln()
        ..writeln('Input JSON fields:');
      for (final field in metadata.fields) {
        final origin = field.providedByRepoFlag ? ' Provided via --repo.' : '';
        final requiredLabel = field.required ? 'required' : 'optional';
        buffer.writeln(
          '  ${field.name} ($requiredLabel): ${field.description}$origin',
        );
      }
    }

    if (metadata.examples.isNotEmpty) {
      buffer
        ..writeln()
        ..writeln('Examples:');
      for (final example in metadata.examples) {
        buffer
          ..writeln('  ${example.description}')
          ..writeln('    ${example.command}');
      }
    }

    return buffer.toString().trimRight();
  }

  @override
  Future<int> run() async {
    if (argResults?['help'] == true) {
      stdout.writeln(usage);
      return 0;
    }

    final repoId = (argResults?['repo'] as String?)?.trim();
    if (repoId == null || repoId.isEmpty) {
      throw UsageException('Missing required option --repo.', usage);
    }

    final arguments = parseJsonObject(argResults?['input'] as String?);

    if (arguments.containsKey('repoId') && arguments['repoId'] != repoId) {
      throw UsageException(
        'Do not pass repoId inside --input; use --repo for the repository ID.',
        usage,
      );
    }

    final fullArguments = <String, dynamic>{...arguments, 'repoId': repoId};

    final unknownFields = fullArguments.keys
        .where((field) => !metadata.fieldNames.contains(field))
        .toList(growable: false);
    if (unknownFields.isNotEmpty) {
      throw UsageException(
        'Unknown input field(s): ${unknownFields.join(', ')}.',
        usage,
      );
    }

    final missingFields = metadata.requiredFields
        .where((field) => !fullArguments.containsKey(field))
        .toList(growable: false);
    if (missingFields.isNotEmpty) {
      throw UsageException(
        'Missing required input field(s): ${missingFields.join(', ')}.',
        usage,
      );
    }

    final result = await context.mcpClient.callTool(
      metadata.name,
      fullArguments,
    );
    final payload = decodeToolPayload(result);
    final useJson = argResults?['json'] == true;
    final rendered = useJson
        ? OrcaNoteOutputFormatter.formatJson(payload)
        : OrcaNoteOutputFormatter.formatText(payload);

    final sink = result.isError == true ? stderr : stdout;
    sink.writeln(rendered);

    return result.isError == true ? 1 : 0;
  }
}
