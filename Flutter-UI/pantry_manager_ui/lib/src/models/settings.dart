class Settings {
  bool isLocal;
  bool isSetup;
  String? url;

  Settings({
    required this.isLocal,
    required this.isSetup,
    this.url,
  });

  @override
  String toString() {
    return "isLocal: $isLocal, url: $url, isSetup: $isSetup,";
  }

  factory Settings.fromJson(Map<String, dynamic> json) {
    return Settings(
      isLocal: json['isLocal'],
      isSetup: json['isSetup'],
      url: json['url'],
    );
  }

  static Map<String, dynamic> toJson(Settings settings) {
    return {
      'isLocal': settings.isLocal,
      'isSetup': settings.isSetup,
      'url': settings.url,
    };
  }
}
