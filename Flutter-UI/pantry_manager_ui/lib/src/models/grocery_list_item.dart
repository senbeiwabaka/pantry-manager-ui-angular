class GroceryListItem {
  final String upc;
  String? label;
  int quantity;
  bool shopped;
  int standardQuantity;
  int count;

  GroceryListItem({
    required this.upc,
    required this.quantity,
    required this.shopped,
    required this.standardQuantity,
    required this.count,
    this.label,
  });

  @override
  String toString() {
    return "upc: $upc, label: $label,";
  }

  factory GroceryListItem.fromJson(Map<String, dynamic> json) {
    var groceryitem = GroceryListItem(
      upc: json['upc'],
      label: json['label'],
      quantity: json['quantity'],
      shopped: json['shopped'],
      standardQuantity: json['standard_quantity'],
      count: json['count'],
    );

    return groceryitem;
  }
}
