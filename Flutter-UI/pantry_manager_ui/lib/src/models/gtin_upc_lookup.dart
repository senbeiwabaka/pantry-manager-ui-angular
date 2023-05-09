class GtinUPCLookup {
  String upc;
  String? brand;
  String? label;

  GtinUPCLookup({required this.upc, this.brand, this.label});

  factory GtinUPCLookup.fromJson(Map<String, dynamic> json) {
    return GtinUPCLookup(
      upc: json['gtin14'],
      brand: json['brand_name'],
      label: json['name'],
    );
  }
}
