import 'package:args/command_runner.dart';

import '../command_context.dart';
import '../invoke_commands_support.dart';
import '../tool_command.dart';
import '../tool_metadata.dart';

/// `invoke_commands` needs three things the generic tool command cannot do:
/// it rewrites `commands[].args` into the JSON-encoded strings the MCP tool
/// expects, it renders the per command results, and it exits non-zero when the
/// desktop reports `success: false` (which also happens for skipped commands).
class InvokeCommandsCommand extends OrcaToolCommand {
  InvokeCommandsCommand({required super.context, required super.metadata});

  /// Short usage for input problems: the full help is long and the caller only
  /// needs to know the shape plus where the reference is.
  String get inputUsage {
    return "orcanote ${metadata.name} --repo <repoId> --input "
        "'{\"commands\":[{\"id\":\"<command ID>\",\"args\":[1234]}]}'\n\n"
        'Run "orcanote ${metadata.name} --help" for the full input reference.';
  }

  @override
  Map<String, dynamic> normalizeArguments(Map<String, dynamic> arguments) {
    try {
      return normalizeInvokeCommandsInput(arguments);
    } on FormatException catch (error) {
      throw UsageException(error.message, inputUsage);
    }
  }

  @override
  String renderText(Object? payload) {
    return renderInvokeCommandsText(payload);
  }

  @override
  int exitCodeFor({required Object? payload, required bool isError}) {
    return invokeCommandsExitCode(payload: payload, isError: isError);
  }
}

OrcaToolCommand createInvokeCommandsCommand(OrcaNoteCommandContext context) {
  return InvokeCommandsCommand(
    context: context,
    metadata: const ToolMetadata(
      name: invokeCommandsToolName,
      title: 'Invoke App Commands',
      summary: 'Run Orca Note app commands in a window of an open repository.',
      description:
          'Runs one or more Orca Note commands inside the window of the given repository and reports the status of every command. '
          'This is the way to do things the content tools cannot do: change a block type, toggle a task, delete blocks by ID, set block properties, manage aliases and references, or drive the app UI.',
      fields: <ToolFieldMetadata>[
        ToolFieldMetadata(
          name: 'repoId',
          description: 'The repository ID.',
          required: true,
          providedByRepoFlag: true,
        ),
        ToolFieldMetadata(
          name: 'commands',
          description:
              'Array of commands to run in order: {"id": "<command ID>", "args": <optional positional arguments>}. '
              'At most $maxInvokeCommands per call.',
          required: true,
        ),
        ToolFieldMetadata(
          name: 'panelId',
          description:
              'Optional panel ID inside that window to run editor commands in. '
              'When omitted, the window\'s active panel is used.',
          required: false,
        ),
        ToolFieldMetadata(
          name: 'undoable',
          description:
              'Whether the changes are added to the window\'s undo history. Defaults to false.',
          required: false,
        ),
        ToolFieldMetadata(
          name: 'focus',
          description:
              'Raise and focus the target window before running. Defaults to false. '
              'Only needed for commands that act on the current caret or selection.',
          required: false,
        ),
      ],
      requiredFields: <String>['repoId', 'commands'],
      sections: <ToolSectionMetadata>[
        ToolSectionMetadata(
          title: 'Input shape',
          body:
              '{\n'
              '  "commands": [\n'
              '    {"id": "core.editor.makeHeading2", "args": [1234]},\n'
              '    {"id": "core.editor.toggleTaskState", "args": [1235]},\n'
              '    {"id": "core.editor.formatBold"}\n'
              '  ],\n'
              '  "panelId": "optional-panel-id",\n'
              '  "undoable": false,\n'
              '  "focus": false\n'
              '}',
        ),
        ToolSectionMetadata(
          title: 'Command arguments',
          body:
              '- Command arguments are positional and are written as a JSON array: args: [1234, "after"].\n'
              '- An already JSON-encoded array string is accepted too, args: "[1234, \\"after\\"]", so payloads copied from another MCP client work unchanged.\n'
              '- Leave args out (or use null) when a command takes no arguments.\n'
              '- Only the arguments after the editor context belong here. Do not pass the editor, panel, cursor or root block arguments — the app fills those in.\n'
              '- The command ID namespace and the arguments each command expects are app internals.',
        ),
        ToolSectionMetadata(
          title: 'Limits',
          body:
              '- At most $maxInvokeCommands commands per call.\n'
              '- At most $maxInvokeCommandArgsLength characters per args array.\n'
              '- At most 256 KB for the whole commands payload.\n'
              '- The call times out after 15 seconds. A single very slow command can hit that; split slow commands into their own call.\n'
              '- Run several commands in one call instead of one call per command: every command is paced by the app (about 200 ms each).',
        ),
        ToolSectionMetadata(
          title: 'Per-command status',
          body:
              '- ok: the command ran.\n'
              '- skipped: the app refused to run it, nothing changed. An editor command that acts on the caret is skipped when its panel editor does not have focus; pass focus: true, or pass the target block ID as an argument to make the command cursor-free.\n'
              '- error: the command failed; code tells why.',
        ),
        ToolSectionMetadata(
          title: 'Error codes',
          body:
              'Per command:\n'
              '- unknown_command: no such command ID in the running app.\n'
              '- command_denied: the command takes the app or its window away from the user and is blocked for external agents.\n'
              '- panel_not_found: the panelId does not exist in that window.\n'
              '- command_failed: the command threw.\n'
              '- invalid_command_id, invalid_args, args_too_long: the entry itself was rejected.\n\n'
              'Whole call:\n'
              '- unknown_repo: no configured repository has that ID.\n'
              '- repo_not_open: the repository exists but has no open window. Open it in Orca Note first; this tool never opens windows.\n'
              '- too_many_commands, payload_too_large, invalid_commands: the payload was rejected.\n'
              '- timeout, window_closed, send_failed, invalid_result, renderer_error: the window did not answer in time or went away.',
        ),
        ToolSectionMetadata(
          title: 'Notes',
          body:
              '- The repository must already have an open window in Orca Note.\n'
              '- The window is never raised unless focus is true, so nothing steals the user\'s attention by default.\n'
              '- undoable defaults to false: the changes are not added to the window\'s undo history. Pass undoable: true when the user should be able to undo them.\n'
              '- core.quitApp, core.closeWindow and core.checkForUpdates are blocked.\n'
              '- Unknown command IDs do not stop the rest of the batch; every command reports its own status.\n'
              '- The exit code is 0 only when every command ran: a skipped or failed command exits with 1.',
        ),
        ToolSectionMetadata(
          title: 'Text output',
          body:
              'Invoked 3 commands in repo my-repo (window 8388652, focused window, active panel, not undoable)\n\n'
              '  ok      core.editor.makeHeading2\n'
              '  skipped core.editor.toggleTaskState        editor_not_focused\n'
              '          The panel editor does not have focus, so this command would do nothing\n'
              '  error   core.editor.missingCommand         unknown_command\n'
              '          No command named "core.editor.missingCommand"\n\n'
              '1 ok, 1 skipped, 1 failed\n\n'
              'Warnings:\n'
              '  - 1 command(s) were skipped because the panel editor has no focus. Re-run them with focus: true.\n\n'
              'Pass --json to print the raw payload instead.',
        ),
        ToolSectionMetadata(
          title: 'Failure output',
          body:
              '{\n'
              '  "success": false,\n'
              '  "repoId": "my-repo",\n'
              '  "error": {\n'
              '    "code": "repo_not_open",\n'
              '    "message": "Repository \\"my-repo\\" has no open window"\n'
              '  }\n'
              '}',
        ),
      ],
      examples: <ToolExample>[
        ToolExample(
          description:
              'Change a block type and toggle a task in one call, without touching focus.',
          command:
              "orcanote invoke_commands --repo my-repo --input '{\"commands\":[{\"id\":\"core.editor.makeHeading2\",\"args\":[1234]},{\"id\":\"core.editor.toggleTaskState\",\"args\":[1235]}]}'",
        ),
        ToolExample(
          description:
              'Run selection based commands and give the user an undo entry.',
          command:
              "orcanote invoke_commands --repo my-repo --input '{\"commands\":[{\"id\":\"core.editor.formatBold\"}],\"focus\":true,\"undoable\":true}'",
        ),
        ToolExample(
          description: 'Keep the raw JSON payload, e.g. for scripting.',
          command:
              "orcanote invoke_commands --repo my-repo --input '{\"commands\":[{\"id\":\"core.editor.toggleTaskState\",\"args\":[1235]}]}' --json",
        ),
        ToolExample(
          description:
              'Send a longer batch from a file without nested quoting problems.',
          command:
              'orcanote invoke_commands --repo my-repo --input '
              '"\$(cat commands.json)"',
        ),
      ],
    ),
  );
}
