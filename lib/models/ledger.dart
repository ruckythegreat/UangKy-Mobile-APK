class Ledger {
  Ledger({
    required this.id,
    required this.name,
    required this.type,
    required this.icon,
    required this.color,
  });

  final String id;
  final String name;
  final String type;
  final String icon;
  final String color;

  Ledger copyWith({
    String? id,
    String? name,
    String? type,
    String? icon,
    String? color,
  }) {
    return Ledger(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      icon: icon ?? this.icon,
      color: color ?? this.color,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type,
        'icon': icon,
        'color': color,
      };

  factory Ledger.fromJson(Map<String, dynamic> json) {
    return Ledger(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      icon: json['icon'] as String,
      color: json['color'] as String,
    );
  }
}
