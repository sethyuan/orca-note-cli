import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:mcp_dart/mcp_dart.dart';

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
    final repoSegment = metadata.requiresRepo ? ' --repo <repoId>' : '';
    return "orcanote ${metadata.name}$repoSegment [--input '{...}'] [--json]";
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

    if (metadata.sections.isNotEmpty) {
      for (final section in metadata.sections) {
        buffer
          ..writeln()
          ..writeln('${section.title}:')
          ..writeln(section.body);
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

  /// Hook for tools that need to reshape or pre-validate the `--input` object
  /// before the generic field checks run. The returned map is what gets sent to
  /// the MCP tool, so throw a [UsageException] when the input is invalid.
  Map<String, dynamic> normalizeArguments(Map<String, dynamic> arguments) {
    return arguments;
  }

  /// Hook for tools that need their own human readable rendering. Only used when
  /// `--json` is not passed; `--json` always prints the raw payload.
  String renderText(Object? payload) {
    return metadata.name == 'get_blocks_text'
        ? OrcaNoteOutputFormatter.formatBlockText(payload)
        : OrcaNoteOutputFormatter.formatText(payload);
  }

  /// Hook for tools whose failure cannot be read from `isError` alone.
  int exitCodeFor({required Object? payload, required bool isError}) {
    return isError ? 1 : 0;
  }

  @override
  Future<int> run() async {
    if (argResults?['help'] == true) {
      stdout.writeln(usage);
      return 0;
    }

    try {
      final repoId = (argResults?['repo'] as String?)?.trim();
      if (metadata.requiresRepo && (repoId == null || repoId.isEmpty)) {
        throw UsageException('Missing required option --repo.', usage);
      }
      if (!metadata.requiresRepo && repoId != null && repoId.isNotEmpty) {
        throw UsageException(
          'Option --repo is not supported for this tool.',
          usage,
        );
      }

      final arguments = normalizeArguments(
        parseJsonObject(argResults?['input'] as String?),
      );

      if (arguments.containsKey('repoId') && arguments['repoId'] != repoId) {
        throw UsageException(
          'Do not pass repoId inside --input; use --repo for the repository ID.',
          usage,
        );
      }

      final fullArguments = <String, dynamic>{...arguments};
      if (metadata.requiresRepo) {
        fullArguments['repoId'] = repoId;
      }

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
          : renderText(payload);

      final isError = result.isError == true;
      final sink = isError ? stderr : stdout;
      sink.writeln(rendered);

      if (isError) {
        stderr.writeln();
        stderr.writeln(usage);
      }

      return exitCodeFor(payload: payload, isError: isError);
    } on UsageException catch (error) {
      stderr.writeln(error.message);
      stderr.writeln();
      stderr.writeln(error.usage);
      return 64;
    } on McpError catch (error) {
      stderr.writeln(error);
      stderr.writeln();
      stderr.writeln(usage);
      return 1;
    } on FormatException catch (error) {
      stderr.writeln(error.message);
      stderr.writeln();
      stderr.writeln(usage);
      return 1;
    } catch (error) {
      stderr.writeln('Command failed: $error');
      stderr.writeln();
      stderr.writeln(usage);
      return 1;
    }
  }
}
