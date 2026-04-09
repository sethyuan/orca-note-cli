import 'config_store.dart';
import 'orca_note_mcp_client.dart';

class OrcaNoteCommandContext {
  OrcaNoteCommandContext({required this.configStore, required this.mcpClient});

  final OrcaNoteConfigStore configStore;
  final OrcaNoteMcpClient mcpClient;
}
