import 'package:flutter/material.dart';
import 'package:qinject/qinject.dart';

import 'src/interfaces/api_service_interface.dart';
import 'src/models/settings.dart';
import 'src/servics/api_service.dart';
import 'src/servics/data_service.dart';
import 'src/servics/database_service.dart';
import 'src/servics/file_service.dart';
import 'src/views/barcode/barcode_view.dart';
import 'src/views/setup/setup_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Qinject.registerSingleton(() => FileService());
  Qinject.registerSingleton(() => "pantry_manager_ui.db");

  final qinjector = Qinject.instance();
  final fileService = qinjector.use<void, FileService>();
  final fileExists = await fileService.fileExists(FileService.settingsName);

  Settings settings;

  if (fileExists) {
    settings = await fileService.readSettings();

    Qinject.registerSingleton(() => settings);
  } else {
    settings = Settings(isLocal: false, isSetup: false);
    Qinject.registerSingleton(() => settings);
  }

  Qinject.registerSingleton(() => DatabaseService(qinjector));

  if (settings.isLocal) {
    Qinject.registerSingleton<IApiService>(() => ApiService(qinjector));
  } else {
    Qinject.registerSingleton<IApiService>(
        () => DataService(qinjector.use<void, DatabaseService>()));
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final qinjector = Qinject.instance();
    final Settings settings = qinjector.use<void, Settings>();

    return MaterialApp(
      title: 'Pantry Manager UI',
      theme: ThemeData.dark(
        useMaterial3: true,
      ),
      home: settings.isSetup ? const BarcodeView() : const SettignsView(),
    );
  }
}
