class BrocadeUPCLookup {
  String upc;
  String? brand;
  String? label;

  BrocadeUPCLookup({required this.upc, this.brand, this.label});

  factory BrocadeUPCLookup.fromJson(Map<String, dynamic> json) {
    return BrocadeUPCLookup(
      upc: json['gtin14'],
      brand: json['brand_name'],
      label: json['name'],
    );
  }
}
