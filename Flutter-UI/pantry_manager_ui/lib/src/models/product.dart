import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final String upc;
  final String? label;
  final String? brand;
  final String? imageUrl;

  const Product({
    required this.upc,
    this.label,
    this.brand,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [upc, label, brand, imageUrl];

  @override
  bool get stringify => true;

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
