import 'package:flutter/material.dart';

import 'package:advanced_datatable/datatable.dart';
import 'package:http/http.dart' as http;

import '../datasources/pantry_search.dart';

class PantryPage extends StatefulWidget {
  const PantryPage({super.key});

  @override
  State<PantryPage> createState() => _PantryPageState();
}

class _PantryPageState extends State<PantryPage> {
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
                source.reset();
              },
              child: const Text("Cancel")),
          const SizedBox(width: 10.0),
          ElevatedButton(
              onPressed: () async {
                var items = source.getItemsToUpdate();

                for (var item in items) {
                  await http.post(Uri.parse(
                      "http://docker-database.localdomain:8000/pantry-manager/groceries/standard-quantity/${item.upc}/${item.standardQuantity}"));
                }

                source.reset();
              },
              child: const Text("Update")),
        ],
      ),
    ]);
  }
}
