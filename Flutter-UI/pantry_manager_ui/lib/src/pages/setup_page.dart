import 'package:flutter/material.dart';
import 'package:qinject/qinject.dart';
import 'package:validators/validators.dart';

import '../models/settings.dart';
import '../servics/file_service.dart';
import '../views/barcode/barcode_view.dart';

class SetupPage extends StatefulWidget {
  const SetupPage({super.key});

  @override
  State<SetupPage> createState() => _SetupPageState();
}

class _SetupPageState extends State<SetupPage> {
  var _setupLocally = false;
  var _url = '';

  late TextEditingController _noteController;

  bool _isButtonEnabled() {
    final url = Uri.tryParse(_url);

    return _setupLocally && url != null && url.isAbsolute && isURL(_url) ||
        !_setupLocally && _url == '';
  }

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController.fromValue(
      TextEditingValue(
        text: _url,
      ),
    );
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var childrenWidgets = <Widget>[];

    childrenWidgets.add(
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Checkbox(
            value: _setupLocally,
            onChanged: (newValue) {
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
            controller: _noteController,
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

                  settings.isLocal = _setupLocally;
                  settings.isSetup = true;

                  if (_setupLocally) {
                    settings.url = _url;
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

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: childrenWidgets,
    );
  }
}
