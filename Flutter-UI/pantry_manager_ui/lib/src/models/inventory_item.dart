import 'package:pantry_manager_ui/src/models/product.dart';

class InventoryItem {
  int count;
  int numberUsedInPast30Days;
  bool onGroceryList;
  Product product;

  InventoryItem({
    required this.count,
    required this.numberUsedInPast30Days,
    required this.onGroceryList,
    required this.product,
  });

  @override
  String toString() {
    return "count: $count, number used in past 30 days: $numberUsedInPast30Days, on grocery list: $onGroceryList, product.upc: ${product.upc}";
  }

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      count: json['count'],
      numberUsedInPast30Days: json['number_used_in_past_30_days'],
      onGroceryList: json['on_grocery_list'],
      product: Product.fromJson(json['product']),
    );
  }

  static Map<String, dynamic> toJson(InventoryItem inventoryItem) {
    return {
      'count': inventoryItem.count,
      'number_used_in_past_30_days': inventoryItem.numberUsedInPast30Days,
      'on_grocery_list': inventoryItem.onGroceryList,
      'product': Product.toJson(inventoryItem.product),
    };
  }
}
