class Settings {
  final bool isLocal;
  String? url;

  Settings({
    required this.isLocal,
    this.url,
  });

  @override
  String toString() {
    return "isLocal: $isLocal, url: $url, ";
  }

  factory Settings.fromJson(Map<String, dynamic> json) {
    return Settings(
      isLocal: json['isLocal'],
      url: json['url'],
    );
  }

  static Map<String, dynamic> toJson(Settings product) {
    return {
      'isLocal': product.isLocal,
      'url': product.url,
    };
  }
}
