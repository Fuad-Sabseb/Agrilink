class WoredaModel {
  final String id;
  final String name;
  final String nameAm;
  final String nameOm;
  final String zone;
  final bool isActive;

  const WoredaModel({
    required this.id,
    required this.name,
    required this.nameAm,
    required this.nameOm,
    required this.zone,
    this.isActive = true,
  });

  factory WoredaModel.fromJson(Map<String, dynamic> json) {
    return WoredaModel(
      id: json['id'] as String,
      name: json['name'] as String,
      nameAm: json['nameAm'] as String? ?? json['name'] as String,
      nameOm: json['nameOm'] as String? ?? json['name'] as String,
      zone: json['zone'] as String,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'nameAm': nameAm,
      'nameOm': nameOm,
      'zone': zone,
      'isActive': isActive,
    };
  }

  String getLocalizedName(String localeCode) {
    switch (localeCode) {
      case 'am':
        return nameAm;
      case 'om':
        return nameOm;
      default:
        return name;
    }
  }

  WoredaModel copyWith({
    String? id,
    String? name,
    String? nameAm,
    String? nameOm,
    String? zone,
    bool? isActive,
  }) {
    return WoredaModel(
      id: id ?? this.id,
      name: name ?? this.name,
      nameAm: nameAm ?? this.nameAm,
      nameOm: nameOm ?? this.nameOm,
      zone: zone ?? this.zone,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WoredaModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'WoredaModel(id: $id, name: $name, zone: $zone)';
}
