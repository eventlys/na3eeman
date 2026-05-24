class PackageModel {
  final int id;
  final String name;
  final String description;
  final String price;
  final int salonId;
  final List<String> includedServices;
  final bool isActive;

  const PackageModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.salonId,
    this.includedServices = const [],
    this.isActive = true,
  });

  factory PackageModel.fromMap(Map<String, dynamic> map) {
    return PackageModel(
      id: map['id'] as int? ?? 0,
      name: map['package_name'] as String? ?? 'Special Package',
      description: map['package_description'] as String? ?? '',
      price: map['package_price']?.toString() ?? '0.00',
      salonId: map['salon'] as int? ?? 0,
      includedServices: map['options_names'] != null
          ? List<String>.from(map['options_names'] as List)
          : [],
      isActive: map['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'package_name': name,
      'package_description': description,
      'package_price': double.tryParse(price)?.toStringAsFixed(2) ?? '0.00',
      'salon': salonId,
      'options': [], // Backend expects a list of Option IDs
    };
    if (id != 0) {
      map['id'] = id;
    }
    return map;
  }

  PackageModel copyWith({
    int? id,
    String? name,
    String? description,
    String? price,
    int? salonId,
    List<String>? includedServices,
    bool? isActive,
  }) {
    return PackageModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      salonId: salonId ?? this.salonId,
      includedServices: includedServices ?? this.includedServices,
      isActive: isActive ?? this.isActive,
    );
  }
}
