class TouchedItem {
  final String type;
  final String id;
  final List<String> classes;
  final String name;
  final String fullEl;

  TouchedItem({
    required this.type,
    required this.id,
    required this.classes,
    required this.name,
    required this.fullEl,
  });

  factory TouchedItem.fromJson(Map<String, dynamic> json) => _$TouchedItemFromJson(json);
}

TouchedItem _$TouchedItemFromJson(Map<String, dynamic> json) =>
    TouchedItem(
        type: json["type"] != null ? json["type"] as String : "",
        id: json["id"] != null ? json["id"] as String : "",
        classes: json["classes"] != null ? List<String>.from(json["classes"]) : [],
        name: json["name"] != null ? json["name"] as String : "",
        fullEl: json["fullEl"] != null ? json["fullEl"] as String : "",
    );