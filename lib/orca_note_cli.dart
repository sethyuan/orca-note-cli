import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:mcp_dart/mcp_dart.dart';

import 'src/command_context.dart';
import 'src/config_store.dart';
import 'src/orca_note_command_runner.dart';
import 'src/orca_note_mcp_client.dart';

Future<int> runOrcaNoteCli(List<String> arguments) async {
  silenceMcpLogs();

  final context = OrcaNoteCommandContext(
    configStore: OrcaNoteConfigStore(),
    mcpClient: OrcaNoteMcpClient(),
  );
  final runner = OrcaNoteCommandRunner(context: context);

  if (arguments.isEmpty) {
    stdout.writeln(runner.usage);
    return 0;
  }

  try {
    final result = await runner.run(arguments);
    return result ?? 0;
  } on UsageException catch (error) {
    stderr.writeln(error);
    return 64;
  } on StateError catch (error) {
    stderr.writeln(error.message);
    return 1;
  } on FormatException catch (error) {
    stderr.writeln(error.message);
    return 1;
  } catch (error) {
    stderr.writeln('Command failed: $error');
    return 1;
  }
}
