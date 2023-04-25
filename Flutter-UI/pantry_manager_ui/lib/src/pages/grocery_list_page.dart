import 'package:advanced_datatable/datatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../datasources/groceries.dart';
import '../views/grocery/create_grocery_list_view.dart';

class GroceryListPage extends StatefulWidget {
  const GroceryListPage({super.key});

  @override
  State<GroceryListPage> createState() => _GroceryListPageState();
}

class _GroceryListPageState extends State<GroceryListPage> {
  final _source = GroceriesDataSource();
  final _formKey = GlobalKey<FormState>();

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
        source: _source,
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
        showCheckboxColumn: true,
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(0.00, 15.00, 0.00, 30.00),
        child: Form(
            key: _formKey,
            child: Column(
              children: [
                const Text("Add Item to List"),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 200.00,
                      child: TextFormField(
                        decoration:
                            const InputDecoration(hintText: "Add Item..."),
                        // The validator receives the text that the user has entered.
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter some text';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(
                      width: 100.00,
                    ),
                    SizedBox(
                      width: 200.00,
                      child: TextFormField(
                        initialValue: "1",
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        // The validator receives the text that the user has entered.
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter some text';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(
                      width: 100.00,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Validate returns true if the form is valid, or false otherwise.
                        if (_formKey.currentState!.validate()) {
                          // If the form is valid, display a snackbar. In the real world,
                          // you'd often call a server or save the information in a database.
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Processing Data')),
                          );
                        }
                      },
                      child: const Text('Add'),
                    ),
                  ],
                ),
              ],
            )),
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext context) =>
                      const CreateGroceryListView()));
            },
            child: const Text('Edit List'),
          ),
          const SizedBox(
            width: 100.00,
          ),
          ElevatedButton(
            onPressed: () {},
            child: const Text('All Done!'),
          ),
        ],
      )
    ]);
  }
}
