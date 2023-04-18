import 'package:advanced_datatable/datatable.dart';
import 'package:flutter/material.dart';
import 'package:pantry_manager_ui/src/datasources/groceries.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  var rowsPerPage = AdvancedPaginatedDataTable.defaultRowsPerPage;

  final srouce = GroceriesDataSource();

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      AdvancedPaginatedDataTable(
        columns: [
          const DataColumn(label: const Text('')),
          const DataColumn(label: const Text('Label')),
          const DataColumn(label: const Text('Quantity')),
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
