import 'package:flutter/material.dart';
import 'package:pantry_manager_ui/src/models/settings.dart';
import 'package:qinject/qinject.dart';

import 'src/servics/file_service.dart';
import 'src/views/barcode/barcode_view.dart';
import 'src/views/setup/setup_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Qinject.registerSingleton(() => FileService());

  final qinjector = Qinject.instance();
  final fileService = qinjector.use<void, FileService>();

  final fileExists = await fileService.fileExists();

  if (fileExists) {
    var settings = await fileService.readSettings();

    Qinject.registerSingleton(() => settings);
  } else {
    Qinject.registerSingleton(() => Settings(isLocal: false, isSetup: false));
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
