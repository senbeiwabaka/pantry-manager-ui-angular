import 'package:flutter/material.dart';
import 'package:pantry_manager_ui/src/servics/data_service.dart';
import 'package:pantry_manager_ui/src/servics/database_service.dart';
import 'package:qinject/qinject.dart';
import 'package:validators/validators.dart';

import '../interfaces/api_service_interface.dart';
import '../models/settings.dart';
import '../servics/api_service.dart';
import '../servics/file_service.dart';
import '../servics/logger.dart';
import '../views/barcode/barcode_view.dart';

class SetupPage extends StatefulWidget {
  const SetupPage({super.key});

  @override
  State<SetupPage> createState() => _SetupPageState();
}

class _SetupPageState extends State<SetupPage> {
  final _logger = getLogger();

  bool _setupLocally = false;
  var _url = '';

  TextEditingController textController = TextEditingController();

  bool _isButtonEnabled() {
    final url = Uri.tryParse(_url);

    return _setupLocally && url != null && url.isAbsolute && isURL(_url) ||
        !_setupLocally && _url == '';
  }

  @override
  Widget build(BuildContext context) {
    var childrenWidgets = <Widget>[];

    _logger.d("_setupLocally: $_setupLocally");

    childrenWidgets.add(
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Checkbox(
            value: _setupLocally,
            onChanged: (newValue) {
              _logger.d("new value: $newValue");

              if (newValue != null) {
                setState(() {
                  _setupLocally = newValue;
                });
              }

              setState(() {
                _url = '';
              });
            },
          ),
          const Text("Setup locally?")
        ],
      ),
    );

    if (_setupLocally) {
      childrenWidgets.add(Padding(
        padding: const EdgeInsets.fromLTRB(0.00, 10.00, 0.00, 10.00),
        child: SizedBox(
          width: 300,
          child: TextField(
            decoration: const InputDecoration(border: OutlineInputBorder()),
            autofocus: false,
            keyboardType: TextInputType.url,
            controller: textController,
            onChanged: (value) {
              setState(() {
                _url = value;
              });
            },
          ),
        ),
      ));
    }

    childrenWidgets.add(
      ElevatedButton(
          onPressed: _isButtonEnabled()
              ? () async {
                  final qinjector = Qinject.instance();
                  final Settings settings = qinjector.use<void, Settings>();
                  final DatabaseService databaseService =
                      qinjector.use<void, DatabaseService>();

                  settings.isLocal = _setupLocally;
                  settings.isSetup = true;

                  if (_setupLocally) {
                    settings.url = _url;

                    Qinject.registerSingleton<IApiService>(
                        () => ApiService(qinjector));
                  } else {
                    await databaseService.initDatabase();

                    Qinject.registerSingleton<IApiService>(
                        () => DataService(databaseService));
                  }

                  final FileService fileService =
                      qinjector.use<void, FileService>();

                  await fileService.writeSettings(settings);

                  if (context.mounted) {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) =>
                            const BarcodeView()));
                  }
                }
              : null,
          child: const Text("Complete")),
    );

    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: childrenWidgets,
      ),
    );
  }
}
