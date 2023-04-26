import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/grocery_list_item.dart';

Future<List<GroceryListItem>> getAllInventory() async {
  var groceryItemLookupUrl = Uri.parse(
      "http://docker-database.localdomain:8000/pantry-manager/groceries/all");
  var response = await http.get(groceryItemLookupUrl);

  if (response.statusCode == 200) {
    return (jsonDecode(response.body) as List)
        .map((data) => GroceryListItem.fromJson(data))
        .toList();
  }

  return List.empty();
}
