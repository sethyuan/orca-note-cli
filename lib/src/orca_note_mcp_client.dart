import 'dart:async';

import 'package:mcp_dart/mcp_dart.dart';

import 'config_store.dart';
import 'constants.dart';

class OrcaNoteMcpClient {
  OrcaNoteMcpClient({OrcaNoteConfigStore? configStore, Uri? endpoint})
    : _configStore = configStore ?? OrcaNoteConfigStore(),
      _endpoint = endpoint ?? Uri.parse('http://localhost:18672/mcp');

  final OrcaNoteConfigStore _configStore;
  final Uri _endpoint;

  Future<CallToolResult> callTool(
    String toolName,
    Map<String, dynamic> arguments,
  ) async {
    return _withClient((client) async {
      return client
          .callTool(CallToolRequest(name: toolName, arguments: arguments))
          .timeout(const Duration(seconds: 30));
    });
  }

  Future<ListToolsResult> listTools() async {
    return _withClient((client) async {
      return client.listTools().timeout(const Duration(seconds: 15));
    });
  }

  Future<T> _withClient<T>(Future<T> Function(McpClient client) action) async {
    final config = await _configStore.load();
    final token = config.token?.trim();
    if (token == null || token.isEmpty) {
      throw StateError(
        'No Orca Note token configured. Run "orcanote config set-token <token>" first.',
      );
    }

    final client = McpClient(
      const Implementation(name: 'orcanote', version: packageVersion),
    );

    final transport = StreamableHttpClientTransport(
      _endpoint,
      opts: StreamableHttpClientTransportOptions(
        requestInit: <String, Object>{
          'headers': <String, String>{'Authorization': 'Bearer $token'},
        },
      ),
    );

    try {
      await client.connect(transport);
      return await action(client);
    } finally {
      await client.close();
    }
  }
}
