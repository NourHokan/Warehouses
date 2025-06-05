import 'dart:convert';

class Warehouse {
  final String id;
  final String name;
  final String address;
  final String whatsappNumber;
  final String email;
  final String governorateId;

  Warehouse({
    required this.id,
    required this.name,
    required this.address,
    required this.whatsappNumber,
    required this.email,
    required this.governorateId,
  });

  factory Warehouse.fromJson(Map<String, dynamic> json) {
    return Warehouse(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      whatsappNumber: json['whatsappNumber']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      governorateId: json['governorateId']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'whatsappNumber': whatsappNumber,
      'email': email,
      'governorateId': governorateId,
    };
  }
}