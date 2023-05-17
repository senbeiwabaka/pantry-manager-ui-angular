import 'package:equatable/equatable.dart';

import 'product.dart';

class InventoryItem extends Equatable {
  final int count;
  final int numberUsedInPast30Days;
  final bool onGroceryList;
  final Product product;

  const InventoryItem({
    required this.count,
    required this.numberUsedInPast30Days,
    required this.onGroceryList,
    required this.product,
  });

  @override
  List<Object?> get props =>
      [count, numberUsedInPast30Days, onGroceryList, product];

  @override
  bool get stringify => true;

  factory InventoryItem.fromMap(Map<String, dynamic> map) {
    return InventoryItem.fromJson(map);
  }

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    var isOnGroceryList = false;

    if (json['on_grocery_list'] == bool) {
      isOnGroceryList = json['on_grocery_list'];
    } else {
      isOnGroceryList = json['on_grocery_list'] == 1;
    }

    Product product;
    if (json["product"] != null) {
      product = Product.fromJson(json["product"]);
    } else {
      product = Product(
          upc: json["upc"],
          label: json["label"],
          brand: json["brand"],
          imageUrl: json["image_url"]);
    }

    return InventoryItem(
      count: json['count'],
      numberUsedInPast30Days: json['number_used_in_past_30_days'],
      onGroceryList: isOnGroceryList,
      product: product,
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
