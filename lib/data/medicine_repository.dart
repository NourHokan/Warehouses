import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/medicine.dart';

class MedicineRepository {
  static const String _storageKey = 'medicines';

  /// استرجاع جميع الأدوية المخزنة
  Future<List<Medicine>> getAllMedicines() async {
    final prefs = await SharedPreferences.getInstance();
    final medicinesJson = prefs.getStringList(_storageKey) ?? [];
    return medicinesJson
        .map((jsonStr) => Medicine.fromJson(json.decode(jsonStr)))
        .toList();
  }

  /// إضافة دواء جديد وحفظه
  Future<void> addMedicine(Medicine medicine) async {
    final prefs = await SharedPreferences.getInstance();
    final medicines = prefs.getStringList(_storageKey) ?? [];
    medicines.add(json.encode(medicine.toJson()));
    await prefs.setStringList(_storageKey, medicines);
  }

  /// حذف جميع الأدوية (اختياري)
  Future<void> clearAllMedicines() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}

class SharedPreferences {
  static Future getInstance() async {}
}
