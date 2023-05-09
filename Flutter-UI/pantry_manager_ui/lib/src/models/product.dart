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

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product.fromJson(map);
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      upc: json['upc'],
      label: json['label'],
      brand: json['brand'],
      imageUrl: json['image_url'],
    );
  }

  static Map<String, dynamic> toJson(Product product) {
    return {
      'upc': product.upc,
      'label': product.label,
      'brand': product.brand,
      'image_url': product.imageUrl,
    };
  }
}
