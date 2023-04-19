import 'package:advanced_datatable/datatable.dart';
import 'package:flutter/material.dart';
import 'package:pantry_manager_ui/src/datasources/groceries.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  final srouce = GroceriesDataSource();

  var rowsPerPage = AdvancedPaginatedDataTable.defaultRowsPerPage;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      AdvancedPaginatedDataTable(
        columns: const [
          DataColumn(label: Text("")),
          DataColumn(label: Text('Label')),
          DataColumn(label: Text('Quantity')),
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
