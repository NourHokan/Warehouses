import 'warehouse.dart';

class Governorate {
  final String id;
  final String name;
  final String arabicName;
  final List<String> warehouseIds;
  final List<Warehouse> warehouses;

  Governorate({
    required this.id,
    required this.name,
    required this.arabicName,
    required this.warehouseIds,
    this.warehouses = const [],
  });

  Governorate copyWith({
    String? id,
    String? name,
    String? arabicName,
    List<String>? warehouseIds,
    List<Warehouse>? warehouses,
  }) {
    return Governorate(
      id: id ?? this.id,
      name: name ?? this.name,
      arabicName: arabicName ?? this.arabicName,
      warehouseIds: warehouseIds ?? this.warehouseIds,
      warehouses: warehouses ?? this.warehouses,
    );
  }
}
