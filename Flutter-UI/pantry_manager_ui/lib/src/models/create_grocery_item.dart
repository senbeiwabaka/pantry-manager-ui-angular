class CreateGroceryItem {
  final String upc;
  final String? label;
  int quantity;
  bool shopped;
  int standardQuantity;
  int count;

  CreateGroceryItem({
    required this.upc,
    required this.quantity,
    required this.shopped,
    required this.standardQuantity,
    required this.count,
    this.label,
  });
}
