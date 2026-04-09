import 'dart:io';

import 'package:args/command_runner.dart';

import '../command_context.dart';
import 'set_token_command.dart';

class ConfigCommand extends Command<int> {
  ConfigCommand(this.context) {
    addSubcommand(SetTokenCommand(context));
  }

  final OrcaNoteCommandContext context;

  @override
  String get name => 'config';

  @override
  String get description => 'Manage saved CLI configuration.';

  @override
  String get usage {
    return '${super.usage}\nConfig file: ${context.configStore.configFilePath}';
  }

  @override
  Future<int> run() async {
    stdout.writeln(usage);
    return 0;
  }
}
