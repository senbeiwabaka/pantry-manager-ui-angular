import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:advanced_datatable/advanced_datatable_source.dart';
import 'package:http/http.dart' as http;
import 'package:pantry_manager_ui/src/models/paged_data.dart';

import '../models/grocery_list_item.dart';

class GroceriesDataSource extends AdvancedDataTableSource<GroceryListItem> {
  @override
  DataRow? getRow(int index) {
    final currentRowData = lastDetails!.rows[index];

    return DataRow(onSelectChanged: (value) {}, cells: [
      DataCell(
        Checkbox(
          value: false,
          onChanged: (value) {},
        ),
      ),
      DataCell(
        Text(currentRowData.label.toString()),
      ),
      DataCell(Text(currentRowData.quantity.toString())),
    ]);
  }

  @override
  int get selectedRowCount => 0;

  @override
  Future<RemoteDataSourceDetails<GroceryListItem>> getNextPage(
      NextPageRequest pageRequest) async {
    var productLookupUrl = Uri.parse(
        "http://docker-database.localdomain:8000/pantry-manager/groceries/shopping-list?page=${pageRequest.offset}&length=${pageRequest.pageSize}");

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
}
