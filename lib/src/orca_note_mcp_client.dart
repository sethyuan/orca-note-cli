import 'dart:async';
import 'dart:io';

import 'package:mcp_dart/mcp_dart.dart';

import 'config_store.dart';
import 'constants.dart';

/// Runs [action] with the environment proxy bypassed for loopback URLs.
///
/// Dart's `HttpClient` defaults to `HttpClient.findProxyFromEnvironment`, so a
/// shell that exports `HTTP_PROXY`/`HTTPS_PROXY`/`ALL_PROXY` (common on dev
/// machines) sends the request to the local MCP server through that proxy and
/// ends up with `McpError 0: Error POSTing to endpoint (HTTP 502)`. The MCP
/// server only listens on the local machine, so loopback has to go DIRECT while
/// any other endpoint keeps honouring the environment.
Future<T> _withLoopbackProxyBypass<T>(Future<T> Function() action) {
  return HttpOverrides.runZoned(
    action,
    findProxyFromEnvironment: (uri, environment) {
      if (_isLoopbackHost(uri.host)) return 'DIRECT';
      return HttpClient.findProxyFromEnvironment(uri, environment: environment);
    },
  );
}

bool _isLoopbackHost(String host) {
  if (host == 'localhost') return true;
  final address = InternetAddress.tryParse(host);
  return address != null && address.isLoopback;
}

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

    return _withLoopbackProxyBypass(() async {
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
    });
  }
}
