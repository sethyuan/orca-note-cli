import 'dart:convert';
import 'dart:io';

class OrcaNoteConfig {
  const OrcaNoteConfig({this.token});

  factory OrcaNoteConfig.fromJson(Map<String, dynamic> json) {
    return OrcaNoteConfig(token: json['token'] as String?);
  }

  final String? token;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{if (token != null) 'token': token};
  }
}

class OrcaNoteConfigStore {
  String get configDirectoryPath {
    if (Platform.isWindows) {
      final appData = Platform.environment['APPDATA'];
      if (appData == null || appData.isEmpty) {
        throw const FormatException(
          'APPDATA is not set; cannot resolve the config directory.',
        );
      }
      return '$appData${Platform.pathSeparator}orcanote';
    }

    final home = Platform.environment['HOME'];
    if (home == null || home.isEmpty) {
      throw const FormatException(
        'HOME is not set; cannot resolve the config directory.',
      );
    }

    return '$home/.config/orcanote';
  }

  String get configFilePath {
    return '$configDirectoryPath${Platform.pathSeparator}config.json';
  }

  Future<OrcaNoteConfig> load() async {
    final file = File(configFilePath);
    if (!await file.exists()) {
      return const OrcaNoteConfig();
    }

    final contents = await file.readAsString();
    if (contents.trim().isEmpty) {
      return const OrcaNoteConfig();
    }

    final decoded = jsonDecode(contents);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException(
        'The config file is invalid: expected a JSON object.',
      );
    }

    return OrcaNoteConfig.fromJson(decoded);
  }

  Future<void> saveToken(String token) async {
    final normalizedToken = token.trim();
    if (normalizedToken.isEmpty) {
      throw const FormatException('Token cannot be empty.');
    }

    final directory = Directory(configDirectoryPath);
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    final file = File(configFilePath);
    await file.writeAsString(
      const JsonEncoder.withIndent(
        '  ',
      ).convert(OrcaNoteConfig(token: normalizedToken).toJson()),
      flush: true,
    );
  }
}
