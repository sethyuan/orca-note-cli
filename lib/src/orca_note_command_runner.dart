import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';

import 'command_context.dart';
import 'commands/config_command.dart';
import 'constants.dart';
import 'tools/tool_registry.dart';

class OrcaNoteCommandRunner extends CommandRunner<int> {
  OrcaNoteCommandRunner({required this.context})
    : super(
        'orcanote',
        'CLI wrapper for Orca Note MCP tools over Streamable HTTP.',
      ) {
    argParser.addFlag(
      'version',
      negatable: false,
      help: 'Print the current CLI version.',
    );

    addCommand(ConfigCommand(context));

    for (final command in createToolCommands(context)) {
      addCommand(command);
    }
  }

  final OrcaNoteCommandContext context;

  @override
  String get usage {
    return '${super.usage}\n\nQuick start:\n'
        '  orcanote config set-token <token>\n'
        '  orcanote get_today_journal --repo <repoId>\n'
        "  orcanote get_blocks_text --repo <repoId> --input '{\"blockIds\":[12345]}'";
  }

  @override
  Future<int?> runCommand(ArgResults topLevelResults) async {
    if (topLevelResults['version'] == true) {
      stdout.writeln(packageVersion);
      return 0;
    }

    return super.runCommand(topLevelResults);
  }
}
