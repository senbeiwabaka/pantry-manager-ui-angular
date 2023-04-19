import 'package:flutter/material.dart';

import 'package:advanced_datatable/datatable.dart';
import 'package:pantry_manager_ui/src/datasources/pantry_search.dart';

class Pantry extends StatefulWidget {
  const Pantry({super.key});

  @override
  State<Pantry> createState() => _PantryState();
}

class _PantryState extends State<Pantry> {
  var rowsPerPage = AdvancedPaginatedDataTable.defaultRowsPerPage;

  final srouce = PantrySearchDataSource();

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
        source: srouce,
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
    ]);
  }
}
