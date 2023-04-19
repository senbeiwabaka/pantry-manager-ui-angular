import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:advanced_datatable/advanced_datatable_source.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:pantry_manager_ui/src/models/paged_data.dart';
import 'package:pantry_manager_ui/src/servics/logger.dart';

import '../models/grocery_list_item.dart';

class PantrySearchDataSource extends AdvancedDataTableSource<GroceryListItem> {
  final log = getLogger();

  final _items = <int, GroceryListItem>{};

  @override
  DataRow? getRow(int index) {
    final currentRowData = lastDetails!.rows[index];

    return DataRow(cells: [
      DataCell(
        Text(currentRowData.count.toString()),
      ),
      DataCell(
        Text(currentRowData.label.toString()),
      ),
      DataCell(
        Text(currentRowData.upc.toString()),
        showEditIcon: true,
      ),
      DataCell(
        EditableText(
          controller: TextEditingController(
              text: currentRowData.standardQuantity.toString()),
          focusNode: FocusNode(),
          style: const TextStyle(color: Colors.black),
          cursorColor: Colors.black,
          backgroundCursorColor: Colors.white,
          autofocus: false,
          keyboardType: TextInputType.number,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly
          ],
          onChanged: (value) {
            log.d("edit textbox onchange value: $value");
            log.d("edit textbox onchange value: $index");
            _updateData(value, index, currentRowData);
          },
        ),
        showEditIcon: true,
      ),
    ]);
  }

  @override
  int get selectedRowCount => 0;

  @override
  Future<RemoteDataSourceDetails<GroceryListItem>> getNextPage(
      NextPageRequest pageRequest) async {
    _items.clear();

    var productLookupUrl = Uri.parse(
        "http://docker-database.localdomain:8000/pantry-manager/groceries?page=${pageRequest.offset}&length=${pageRequest.pageSize}");

    var response = await http.get(productLookupUrl);
    dynamic pagedData;

    if (response.statusCode == 200) {
      pagedData =
          PagedData<GroceryListItem>.fromJson(jsonDecode(response.body));
    } else {
      pagedData = PagedData<GroceryListItem>(
        count: 0,
        data: List.empty(),
      );
    }

    return RemoteDataSourceDetails(
      pagedData.count,
      pagedData.data,
    );
  }

  void reset() {
    _items.clear();

    forceRemoteReload = true;
    notifyListeners();
  }

  List<GroceryListItem> getItemsToUpdate() {
    return _items.values.toList();
  }

  void _updateData(String value, int index, GroceryListItem item) {
    item.standardQuantity = int.parse(value);

    if (_items.containsKey(index)) {
      _items.update(index, (value) => item);
    } else {
      _items.putIfAbsent(index, () => item);
    }
  }
}
