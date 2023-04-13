class Product {
  final String upc;
  String? label;
  String? brand;
  String? imageUrl;

  Product({
    required this.upc,
    this.label,
    this.brand,
    this.imageUrl,
  });

  @override
  String toString() {
    return "upc: $upc, brand: $brand, label: $label, image: $imageUrl";
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      upc: json['upc'],
      label: json['label'],
      brand: json['brand'],
      imageUrl: json['image_url'],
    );
  }
}
