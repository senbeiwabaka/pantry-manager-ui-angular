import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/settings.dart';

class FileService {
  final String settingsName = "settings.json";

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/$settingsName');
  }

  Future<bool> get fileExists async {
    final path = await _localPath;
    return File('$path/$settingsName').exists();
  }

  Future<Settings> readSettings() async {
    try {
      final file = await _localFile;

      // Read the file
      final contents = await file.readAsString();

      return jsonDecode(contents);
    } catch (e) {
      // If encountering an error, return 0
      return Settings(isLocal: false);
    }
  }

  Future<File> writeCounter(Settings settings) async {
    final file = await _localFile;

    // Write the file
    return file.writeAsString(jsonEncode(settings));
  }
}
