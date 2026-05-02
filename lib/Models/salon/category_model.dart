
class Category {
  final int id;
  final String name;
  final String nameEn;
  final String icon;
  final String? image;
  final String targetGender;

  Category({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.icon,
    this.image,
    required this.targetGender,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      nameEn: json['name_en'],
      icon: json['icon'],
      image: json['image'],
      targetGender: json['target_gender'] ?? 'all',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'name_en': nameEn,
      'icon': icon,
      'image': image,
      'target_gender': targetGender,
    };
  }
}
