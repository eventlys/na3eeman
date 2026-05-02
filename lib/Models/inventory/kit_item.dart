enum KitUrgency { high, medium, low }

class KitItem {
  final int id;
  final String name;
  final String description;
  final String icon;
  final KitUrgency urgency;
  final DateTime lastMaintained;

  KitItem({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.urgency,
    required this.lastMaintained,
  });

  factory KitItem.fromJson(Map<String, dynamic> json) {
    return KitItem(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String,
      urgency: KitUrgency.values.firstWhere(
        (e) => e.name == json['urgency'].toString().toLowerCase(),
        orElse: () => KitUrgency.low,
      ),
      lastMaintained: DateTime.parse(json['last_maintained'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'urgency': urgency.name,
      'last_maintained': lastMaintained.toIso8601String(),
    };
  }
}
