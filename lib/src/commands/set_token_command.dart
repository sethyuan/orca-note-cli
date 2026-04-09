import 'dart:io';

import 'package:args/command_runner.dart';

import '../command_context.dart';

class SetTokenCommand extends Command<int> {
  SetTokenCommand(this.context);

  final OrcaNoteCommandContext context;

  @override
  String get name => 'set-token';

  @override
  String get description =>
      'Save the Bearer token used for Orca Note MCP authentication.';

  @override
  String get invocation => 'orcanote config set-token <token>';

  @override
  String get usage {
    return '${super.usage}\n\n'
        'Examples:\n'
        '  orcanote config set-token secret_token\n\n'
        'The token is saved to ${context.configStore.configFilePath}';
  }

  @override
  Future<int> run() async {
    if (argResults?['help'] == true) {
      stdout.writeln(usage);
      return 0;
    }

    final rest = argResults?.rest ?? const <String>[];
    if (rest.length != 1) {
      throw UsageException('Expected exactly one token argument.', usage);
    }

    await context.configStore.saveToken(rest.first);
    stdout.writeln('Saved token to ${context.configStore.configFilePath}');
    return 0;
  }
}
