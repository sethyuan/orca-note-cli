import 'dart:convert';

import 'output_formatter.dart';

/// Name of the MCP tool wrapped by the `invoke_commands` command.
const String invokeCommandsToolName = 'invoke_commands';

/// Same limits the desktop `invoke_commands` tool enforces, checked locally so
/// a bad payload fails fast with a readable message instead of a round trip.
const int maxInvokeCommands = 20;
const int maxInvokeCommandArgsLength = 20000;
const int maxInvokeCommandsPayloadLength = 256 * 1024;

/// Reshapes the `--input` object of `invoke_commands` into the shape the MCP
/// tool expects.
///
/// `commands[].args` may be written as a native JSON array (`[1234, "after"]`),
/// which is far easier to type and quote than a JSON-encoded string, or as an
/// already encoded array string (`"[1234,\"after\"]"`), which is what the MCP
/// schema itself asks for. Both are accepted; arrays are encoded here.
///
/// Throws [FormatException] with a human readable message when the input cannot
/// be turned into a valid tool call.
Map<String, dynamic> normalizeInvokeCommandsInput(Map<String, dynamic> input) {
  final normalized = <String, dynamic>{...input};

  final rawCommands = normalized['commands'];
  if (rawCommands == null) {
    throw const FormatException(
      'Missing required input field: commands (a JSON array of {id, args}).',
    );
  }
  if (rawCommands is! List) {
    throw const FormatException('commands must be a JSON array.');
  }
  if (rawCommands.isEmpty) {
    throw const FormatException('commands must not be empty.');
  }
  if (rawCommands.length > maxInvokeCommands) {
    throw FormatException(
      'commands has ${rawCommands.length} items; at most $maxInvokeCommands '
      'are allowed per call.',
    );
  }

  final commands = <Map<String, dynamic>>[];
  for (var index = 0; index < rawCommands.length; index += 1) {
    final entry = rawCommands[index];
    if (entry is! Map) {
      throw FormatException(
        'commands[$index] must be a JSON object with "id" and "args".',
      );
    }

    final unknownFields = entry.keys
        .where((key) => key != 'id' && key != 'args')
        .toList(growable: false);
    if (unknownFields.isNotEmpty) {
      throw FormatException(
        'commands[$index] has unknown field(s): ${unknownFields.join(', ')}. '
        'Only "id" and "args" are supported.',
      );
    }

    final id = entry['id'];
    if (id is! String || id.trim().isEmpty) {
      throw FormatException('commands[$index].id must be a non-empty string.');
    }

    commands.add(<String, dynamic>{
      'id': id.trim(),
      'args': _normalizeCommandArgs(entry['args'], index),
    });
  }
  normalized['commands'] = commands;

  final panelId = normalized['panelId'];
  if (panelId != null) {
    if (panelId is! String) {
      throw const FormatException('panelId must be a string.');
    }
    if (panelId.trim().isEmpty) {
      normalized.remove('panelId');
    } else {
      normalized['panelId'] = panelId.trim();
    }
  }

  for (final flag in const <String>['undoable', 'focus']) {
    final value = normalized[flag];
    if (value == null) {
      normalized.remove(flag);
      continue;
    }
    if (value is! bool) {
      throw FormatException('$flag must be a boolean.');
    }
  }

  final payloadLength = jsonEncode(commands).length;
  if (payloadLength > maxInvokeCommandsPayloadLength) {
    throw FormatException(
      'The commands payload is too large ($payloadLength characters; at most '
      '$maxInvokeCommandsPayloadLength are allowed).',
    );
  }

  return normalized;
}

String? _normalizeCommandArgs(Object? rawArgs, int index) {
  if (rawArgs == null) return null;

  if (rawArgs is List) {
    final encoded = jsonEncode(rawArgs);
    _checkArgsLength(encoded, index);
    return encoded;
  }

  if (rawArgs is String) {
    final trimmed = rawArgs.trim();
    if (trimmed.isEmpty) return null;
    _checkArgsLength(trimmed, index);

    final Object? decoded;
    try {
      decoded = jsonDecode(trimmed);
    } on FormatException {
      throw FormatException(
        'commands[$index].args is not valid JSON. Pass a JSON array, e.g. '
        '[1234, "after"], or leave args out when the command takes none.',
      );
    }
    if (decoded is! List) {
      throw FormatException(
        'commands[$index].args must decode to a JSON array. Command arguments '
        'are positional, e.g. [1234, "after"].',
      );
    }

    return trimmed;
  }

  throw FormatException(
    'commands[$index].args must be a JSON array or a JSON-encoded array '
    'string, got ${rawArgs.runtimeType}.',
  );
}

void _checkArgsLength(String args, int index) {
  if (args.length > maxInvokeCommandArgsLength) {
    throw FormatException(
      'commands[$index].args is ${args.length} characters long; at most '
      '$maxInvokeCommandArgsLength are allowed per command.',
    );
  }
}

/// Renders the `invoke_commands` payload as text.
///
/// The generic formatter cannot be used here: the interesting part of this
/// payload is a list of per command results plus warnings, not a nested object.
String renderInvokeCommandsText(Object? payload) {
  if (payload is! Map) {
    return OrcaNoteOutputFormatter.formatText(payload);
  }

  final results = payload['results'];
  if (results is! List) {
    return _renderToolFailure(payload);
  }

  final buffer = StringBuffer(_header(payload, results.length));

  final idWidth = results
      .map((result) => _resultField(result, 'id').length)
      .fold(0, (width, length) => length > width ? length : width);

  for (final result in results) {
    if (result is! Map) {
      buffer.writeln('  ${result.toString()}');
      continue;
    }

    final status = _resultField(result, 'status');
    final id = _resultField(result, 'id');
    final code = _resultField(result, 'code');
    final error = _resultField(result, 'error');

    final line = StringBuffer()
      ..write('  ')
      ..write(_statusLabel(status).padRight(8))
      ..write(id.padRight(idWidth));
    if (code.isNotEmpty) {
      line
        ..write('  ')
        ..write(code);
    }
    buffer.writeln(line.toString().trimRight());

    if (error.isNotEmpty) {
      buffer.writeln('${' ' * 10}$error');
    }
  }

  buffer
    ..writeln()
    ..writeln(_counters(payload, results.length));

  final warnings = payload['warnings'];
  if (warnings is List && warnings.isNotEmpty) {
    buffer
      ..writeln()
      ..writeln('Warnings:');
    for (final warning in warnings) {
      buffer.writeln('  - $warning');
    }
  }

  return buffer.toString().trimRight();
}

/// Exit code for an `invoke_commands` run.
///
/// The desktop tool reports `success: false` as soon as one command failed or
/// was skipped, and a skipped command means nothing happened — so anything but
/// a fully successful run has to be a non-zero exit code.
int invokeCommandsExitCode({required Object? payload, required bool isError}) {
  if (isError) return 1;
  if (payload is Map && payload['success'] == false) return 1;
  return 0;
}

String _header(Map payload, int count) {
  final repoId = payload['repoId'];
  final parts = <String>[];

  final windowId = payload['windowId'];
  if (windowId != null) {
    parts.add('window $windowId');
  }

  parts.add(switch (payload['windowSelection']) {
    'focused' => 'focused window',
    'first' => 'first window, not focused',
    _ => 'window selection unknown',
  });

  final panelId = payload['panelId'];
  parts.add(
    panelId is String && panelId.isNotEmpty ? 'panel $panelId' : 'active panel',
  );

  parts.add(payload['undoable'] == true ? 'undoable' : 'not undoable');

  final repo = repoId is String && repoId.isNotEmpty ? ' in repo $repoId' : '';
  final commandWord = count == 1 ? 'command' : 'commands';
  return 'Invoked $count $commandWord$repo (${parts.join(', ')})\n\n';
}

String _counters(Map payload, int total) {
  int countOf(String status) => payload['results'] is List
      ? (payload['results'] as List)
            .where(
              (result) =>
                  result is Map && _resultField(result, 'status') == status,
            )
            .length
      : 0;

  final ok = payload['okCount'] ?? countOf('ok');
  final skipped = payload['skippedCount'] ?? countOf('skipped');
  final failed =
      payload['failedCount'] ?? (total - countOf('ok') - countOf('skipped'));

  return '$ok ok, $skipped skipped, $failed failed';
}

String _statusLabel(String status) {
  return switch (status) {
    'ok' => 'ok',
    'skipped' => 'skipped',
    'error' => 'error',
    _ => status.isEmpty ? 'unknown' : status,
  };
}

String _resultField(Object? result, String field) {
  if (result is! Map) return '';
  final value = result[field];
  return value == null ? '' : '$value';
}

String _renderToolFailure(Map payload) {
  final error = payload['error'];
  if (error is Map) {
    final code = _resultField(error, 'code');
    final message = _resultField(error, 'message');
    if (code.isNotEmpty && message.isNotEmpty) {
      return 'error [$code]: $message';
    }
    if (message.isNotEmpty) return 'error: $message';
    if (code.isNotEmpty) return 'error [$code]';
  } else if (error != null) {
    return 'error: $error';
  }

  return OrcaNoteOutputFormatter.formatText(payload);
}
