import 'dart:convert';

import 'package:mcp_dart/mcp_dart.dart';

Map<String, dynamic> parseJsonObject(String? input) {
  if (input == null || input.trim().isEmpty) {
    return <String, dynamic>{};
  }

  final decoded = jsonDecode(input);
  if (decoded is! Map) {
    throw const FormatException('--input must be a JSON object.');
  }

  return Map<String, dynamic>.from(decoded);
}

Object? decodeToolPayload(CallToolResult result) {
  if (result.content.isEmpty) {
    return <String, dynamic>{'isError': result.isError, 'content': <Object?>[]};
  }

  final decodedContent = result.content.map(_decodeContentItem).toList();
  if (decodedContent.length == 1) {
    return decodedContent.first;
  }

  return decodedContent;
}

Object? _decodeContentItem(Object item) {
  if (item is TextContent) {
    final text = item.text.trim();
    if (text.isEmpty) {
      return '';
    }

    try {
      return jsonDecode(text);
    } catch (_) {
      return item.text;
    }
  }

  final dynamic dynamicItem = item;
  try {
    return dynamicItem.toJson() as Object?;
  } catch (_) {
    return dynamicItem.toString();
  }
}
