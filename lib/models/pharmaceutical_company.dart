import 'medicine.dart';

class PharmaceuticalCompany {
  final String id;
  final String name;
  final String arabicName;
  final String description;
  final List<Medicine> medicines;

  PharmaceuticalCompany({
    required this.id,
    required this.name,
    required this.arabicName,
    required this.description,
    required this.medicines,
  });

  PharmaceuticalCompany copyWith({
    String? id,
    String? name,
    String? arabicName,
    String? description,
    List<Medicine>? medicines,
  }) {
    return PharmaceuticalCompany(
      id: id ?? this.id,
      name: name ?? this.name,
      arabicName: arabicName ?? this.arabicName,
      description: description ?? this.description,
      medicines: medicines ?? this.medicines,
    );
  }
}
