import 'package:equatable/equatable.dart';

class GroceryListItem extends Equatable {
  final String upc;
  final String? label;
  final int quantity;
  final bool shopped;
  final int standardQuantity;
  final int count;

  const GroceryListItem({
    required this.upc,
    required this.quantity,
    required this.shopped,
    required this.standardQuantity,
    required this.count,
    this.label,
  });

  @override
  List<Object?> get props =>
      [upc, label, quantity, shopped, standardQuantity, count];

  @override
  bool get stringify => true;

  factory GroceryListItem.fromMap(Map<String, dynamic> map) {
    return GroceryListItem.fromJson(map);
  }

  factory GroceryListItem.fromJson(Map<String, dynamic> json) {
    var shopped = false;

    if (json['shopped'] == bool) {
      shopped = json['shopped'];
    } else {
      shopped = json['shopped'] == 1;
    }

    var groceryitem = GroceryListItem(
      upc: json['upc'],
      label: json['label'],
      quantity: json['quantity'],
      shopped: shopped,
      standardQuantity: json['standard_quantity'],
      count: json['count'],
    );

    return groceryitem;
  }
}
