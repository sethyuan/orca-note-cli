import 'dart:convert';

class OrcaNoteOutputFormatter {
  static String formatJson(Object? value) {
    return const JsonEncoder.withIndent('  ').convert(value);
  }

  static String formatText(Object? value) {
    final buffer = StringBuffer();
    _writeValue(buffer, value, 0, null);
    return buffer.toString().trimRight();
  }

  static String formatBlockText(Object? value) {
    final texts = <String>[];
    _collectBlockText(value, texts);
    return texts.join('\n').trimRight();
  }

  static void _writeValue(
    StringBuffer buffer,
    Object? value,
    int indent,
    String? label,
  ) {
    final prefix = ' ' * indent;
    if (value is Map) {
      final entries = value.entries
          .where((entry) => entry.key != "success" && entry.key != "repoId")
          .toList(growable: false);
      if (entries.isEmpty) {
        buffer.writeln(label == null ? '{}' : '$prefix$label: {}');
        return;
      }

      if (label != null) {
        buffer.writeln('$prefix$label:');
      }

      for (final entry in entries) {
        final key = entry.key.toString();
        final child = entry.value;
        if (_isScalar(child)) {
          buffer.writeln(
            '${' ' * (label == null ? indent : indent + 2)}$key: ${_scalarToString(child)}',
          );
        } else {
          _writeValue(buffer, child, label == null ? indent : indent + 2, key);
        }
      }
      return;
    }

    if (value is List) {
      if (value.isEmpty) {
        buffer.writeln(label == null ? '[]' : '$prefix$label: []');
        return;
      }

      if (label != null) {
        buffer.writeln('$prefix$label:');
      }

      for (final item in value) {
        final itemPrefix = ' ' * (label == null ? indent : indent + 2);
        if (_isScalar(item)) {
          buffer.writeln('$itemPrefix- ${_scalarToString(item)}');
        } else if (item is Map) {
          buffer.writeln('$itemPrefix-');
          _writeValue(
            buffer,
            item,
            (label == null ? indent : indent + 2) + 2,
            null,
          );
        } else if (item is List) {
          buffer.writeln('$itemPrefix-');
          _writeValue(
            buffer,
            item,
            (label == null ? indent : indent + 2) + 2,
            null,
          );
        } else {
          buffer.writeln('$itemPrefix- ${item.toString()}');
        }
      }
      return;
    }

    final rendered = _scalarToString(value);
    if (label == null) {
      buffer.writeln(rendered);
    } else {
      buffer.writeln('$prefix$label: $rendered');
    }
  }

  static bool _isScalar(Object? value) {
    return value == null || value is String || value is num || value is bool;
  }

  static void _collectBlockText(Object? value, List<String> texts) {
    if (value is Map) {
      final textValue = value['text'];
      if (textValue != null) {
        if (_isScalar(textValue)) {
          final text = _scalarToString(textValue).trimRight();
          if (text.isNotEmpty) {
            texts.add(text);
          }
        } else {
          _collectBlockText(textValue, texts);
        }
      }

      for (final entry in value.entries) {
        final key = entry.key.toString();
        if (key == 'text' ||
            key == 'id' ||
            key == 'blockId' ||
            key == 'success' ||
            key == 'repoId') {
          continue;
        }

        final child = entry.value;
        if (child is Map || child is List) {
          _collectBlockText(child, texts);
        }
      }
      return;
    }

    if (value is List) {
      for (final item in value) {
        _collectBlockText(item, texts);
      }
      return;
    }

    if (_isScalar(value)) {
      final text = _scalarToString(value).trimRight();
      if (text.isNotEmpty) {
        texts.add(text);
      }
    }
  }

  static String _scalarToString(Object? value) {
    if (value == null) {
      return 'null';
    }

    if (value is String) {
      return value;
    }

    return value.toString();
  }
}
