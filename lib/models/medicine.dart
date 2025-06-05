import 'dart:convert';

enum MedicineType {
  local, // أدوية وطنية
  foreign, // أدوية أجنبية
  accessories // إكسسوار
}

class Medicine {
  final String id;
  final String name;
  final String arabicName;
  final String description;
  final double price; // السعر بالدولار
  final int stock;
  final String companyId;
  final String warehouseId;
  final MedicineType type;
  final String whatsappNumber;

  Medicine({
    required this.id,
    required this.name,
    required this.arabicName,
    required this.description,
    required this.price, // السعر بالدولار
    required this.stock,
    required this.companyId,
    required this.warehouseId,
    required this.type,
    required this.whatsappNumber,
  });

  Medicine copyWith({
    String? id,
    String? name,
    String? arabicName,
    String? description,
    double? price,
    int? stock,
    String? companyId,
    String? warehouseId,
    MedicineType? type,
    String? whatsappNumber,
  }) {
    return Medicine(
      id: id ?? this.id,
      name: name ?? this.name,
      arabicName: arabicName ?? this.arabicName,
      description: description ?? this.description,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      companyId: companyId ?? this.companyId,
      warehouseId: warehouseId ?? this.warehouseId,
      type: type ?? this.type,
      whatsappNumber: whatsappNumber ?? this.whatsappNumber,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'arabicName': arabicName,
      'description': description,
      'price': price, // السعر بالدولار
      'stock': stock,
      'companyId': companyId,
      'warehouseId': warehouseId,
      'type': type.toString().split('.').last,
      'whatsappNumber': whatsappNumber,
    };
  }

  factory Medicine.fromJson(Map<String, dynamic> json) {
    return Medicine(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      arabicName: json['arabicName']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      price: (json['price'] is int)
        ? (json['price'] as int).toDouble()
        : (json['price'] is String)
          ? double.tryParse(json['price']) ?? 0
          : (json['price'] ?? 0).toDouble(),
      stock: int.tryParse(json['stock']?.toString() ?? '0') ?? 0,
      companyId: json['companyId']?.toString() ?? '',
      warehouseId: json['warehouseId']?.toString() ?? '',
      type: MedicineType.values.firstWhere(
        (e) => e.toString().split('.').last == (json['type']?.toString() ?? ''),
        orElse: () => MedicineType.local,
      ),
      whatsappNumber: json['whatsappNumber']?.toString() ?? '',
    );
  }
}
