class HaircutStyle {
  final int id;
  final String name;
  final String styleType; // 'AVATAR', 'UPLOAD', 'CELEBRITY'
  final String? imageUrl;
  final String? avatarId;
  final bool isPublic;
  final int? createdById;
  final DateTime? createdAt;

  HaircutStyle({
    required this.id,
    required this.name,
    required this.styleType,
    this.imageUrl,
    this.avatarId,
    this.isPublic = false,
    this.createdById,
    this.createdAt,
  });

  factory HaircutStyle.fromJson(Map<String, dynamic> json) {
    return HaircutStyle(
      id: json['id'] as int,
      name: json['name'] as String,
      styleType: json['style_type'] as String,
      imageUrl: json['image'] as String?,
      avatarId: json['avatar_id'] as String?,
      isPublic: json['is_public'] as bool? ?? false,
      createdById: json['created_by'] as int?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'style_type': styleType,
      'image': imageUrl,
      'avatar_id': avatarId,
      'is_public': isPublic,
      'created_by': createdById,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  String get displayType {
    switch (styleType) {
      case 'AVATAR':
        return '3D Avatar';
      case 'UPLOAD':
        return 'Uploaded Photo';
      case 'CELEBRITY':
        return 'Celebrity Reference';
      default:
        return styleType;
    }
  }

  bool get isUserCreated => !isPublic && createdById != null;
  bool get isSystemStyle => isPublic;

  HaircutStyle copyWith({
    int? id,
    String? name,
    String? styleType,
    String? imageUrl,
    String? avatarId,
    bool? isPublic,
    int? createdById,
    DateTime? createdAt,
  }) {
    return HaircutStyle(
      id: id ?? this.id,
      name: name ?? this.name,
      styleType: styleType ?? this.styleType,
      imageUrl: imageUrl ?? this.imageUrl,
      avatarId: avatarId ?? this.avatarId,
      isPublic: isPublic ?? this.isPublic,
      createdById: createdById ?? this.createdById,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
