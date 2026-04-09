import 'dart:convert';
import 'dart:io';

import 'package:mcp_dart/mcp_dart.dart';

Future<void> main(List<String> arguments) async {
  if (arguments.isEmpty) return;

  final token = arguments.first;
  final client = McpClient(
    const Implementation(name: 'orcanote-discovery', version: '1.0.0'),
  );

  final transport = StreamableHttpClientTransport(
    Uri.parse('http://localhost:18672/mcp'),
    opts: StreamableHttpClientTransportOptions(
      requestInit: <String, Object>{
        'headers': <String, String>{'Authorization': 'Bearer $token'},
      },
    ),
  );

  try {
    await client.connect(transport);
    final result = await client.listTools();
    stdout.writeln(const JsonEncoder.withIndent('  ').convert(result.toJson()));
  } finally {
    await client.close();
  }
}
