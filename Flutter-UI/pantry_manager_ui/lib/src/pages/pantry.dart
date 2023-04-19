import 'package:flutter/material.dart';

import 'package:advanced_datatable/datatable.dart';
import 'package:http/http.dart' as http;

import '../datasources/pantry_search.dart';
import '../servics/logger.dart';

class Pantry extends StatefulWidget {
  const Pantry({super.key});

  @override
  State<Pantry> createState() => _PantryState();
}

class _PantryState extends State<Pantry> {
  final log = getLogger();
  final source = PantrySearchDataSource();

  var rowsPerPage = AdvancedPaginatedDataTable.defaultRowsPerPage;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      AdvancedPaginatedDataTable(
        columns: const [
          DataColumn(label: Text('On hand')),
          DataColumn(label: Text('Item')),
          DataColumn(label: Text('UPC')),
          DataColumn(label: Text('Add to weekly list')),
        ],
        source: source,
        addEmptyRows: false,
        showFirstLastButtons: true,
        rowsPerPage: rowsPerPage,
        availableRowsPerPage: const [1, 2, 5, 10, 20],
        onRowsPerPageChanged: (newRowsPerPage) {
          if (newRowsPerPage != null) {
            setState(() {
              rowsPerPage = newRowsPerPage;
            });
          }
        },
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
              onPressed: () {
                log.d("Cancel button pressed");

                source.reset();
              },
              child: const Text("Cancel")),
          const SizedBox(width: 10.0),
          ElevatedButton(
              onPressed: () async {
                log.d("Update button pressed");
                var items = source.getItemsToUpdate();

                for (var item in items) {
                  var response = await http.post(Uri.parse(
                      "http://docker-database.localdomain:8000/pantry-manager/groceries/standard-quantity/${item.upc}/${item.standardQuantity}"));

                  log.d(
                      "standard quantity set response: ${response.statusCode}");
                }

                source.reset();

                log.d("items $items");
              },
              child: const Text("Update")),
        ],
      ),
    ]);
  }
}
