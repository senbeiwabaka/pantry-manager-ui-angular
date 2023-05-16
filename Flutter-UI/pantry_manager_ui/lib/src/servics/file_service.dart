import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/settings.dart';

class FileService {
  static String settingsName = "settings.json";

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> localFile(String name) async {
    final path = await _localPath;
    return File('$path/$name');
  }

  Future<bool> fileExists(String name) async {
    final path = await _localPath;
    return File('$path/$name').exists();
  }

  Future<Settings> readSettings() async {
    try {
      final file = await localFile(settingsName);

      // Read the file
      final contents = await file.readAsString();

      return Settings.fromJson(jsonDecode(contents));
    } catch (e) {
      // If encountering an error, return 0
      return Settings(isLocal: false, isSetup: false);
    }
  }

  Future<File> writeSettings(Settings settings) async {
    final file = await localFile(settingsName);

    // Write the file
    return file.writeAsString(jsonEncode(Settings.toJson(settings)));
  }
}
