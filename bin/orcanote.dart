import 'dart:io';

import 'package:orca_note_cli/orca_note_cli.dart';

Future<void> main(List<String> arguments) async {
  exitCode = await runOrcaNoteCli(arguments);
}
