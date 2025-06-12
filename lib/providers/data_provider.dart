import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import '../models/cart.dart';
import '../models/medicine.dart';
import '../models/warehouse.dart';
import '../models/governorate.dart';
import '../models/pharmaceutical_company.dart';

class DataProvider with ChangeNotifier {
  final supabase = Supabase.instance.client;

  final List<Governorate> _governorates = [
    Governorate(
      id: '1',
      name: 'Aleppo',
      arabicName: 'حلب',
      warehouseIds: [],
    ),
  ];

  final List<PharmaceuticalCompany> _companies = [
    PharmaceuticalCompany(
      id: '1',
      name: 'Syrian Pharmaceutical Industries',
      arabicName: 'الصناعات الدوائية السورية',
      description: 'شركة رائدة في مجال الصناعات الدوائية',
      medicines: [],
    ),
    PharmaceuticalCompany(
      id: '2',
      name: 'Medico',
      arabicName: 'ميديكو',
      description: 'شركة متخصصة في الأدوية البشرية',
      medicines: [],
    ),
  ];

  List<Warehouse> _warehouses = [];
  List<Warehouse> get warehouses => _warehouses;

  List<Medicine> _medicines = [];

  final Map<String, Cart> _userCarts = {};

  // Getters
  List<Governorate> get governorates => _governorates;
  List<PharmaceuticalCompany> get companies => _companies;
  List<Medicine> get medicines => _medicines;

  // --- Supabase: مزامنة المستودعات ---
  Stream<List<Warehouse>> get warehousesStream {
    return supabase
        .from('warehouses')
        .stream(primaryKey: ['id'])
        .map((maps) => maps.map((data) => Warehouse.fromJson(data)).toList());
  }

  Future<void> fetchWarehouses() async {
    final data = await supabase.from('warehouses').select();
    _warehouses = (data as List).map((e) => Warehouse.fromJson(e)).toList();
    notifyListeners();
  }

  Future<void> addWarehouse(Warehouse warehouse) async {
    final response = await supabase.from('warehouses').insert(warehouse.toJson()).select();
    print('Supabase addWarehouse response:');
    print(response);
  }

  Future<void> updateWarehouse(Warehouse warehouse) async {
    await supabase.from('warehouses').update(warehouse.toJson()).eq('id', warehouse.id);
  }

  Future<void> deleteWarehouse(String id) async {
    await supabase.from('warehouses').delete().eq('id', id);
  }

  // --- Supabase: مزامنة الأدوية ---
  Future<void> fetchMedicines() async {
    final data = await supabase.from('medicines').select();
    _medicines = (data as List).map((e) => Medicine.fromJson(e)).toList();
    notifyListeners();
  }

  Future<void> addMedicine(Medicine medicine) async {
    await supabase.from('medicines').insert(medicine.toJson());
    await fetchMedicines();
  }

  Future<void> updateMedicine(Medicine medicine) async {
    await supabase.from('medicines').update(medicine.toJson()).eq('id', medicine.id);
    await fetchMedicines();
  }

  Future<void> deleteMedicine(String id) async {
    await supabase.from('medicines').delete().eq('id', id);
    await fetchMedicines();
  }

  // --- Supabase: تسجيل المستخدمين ---
  Future<void> registerOrLoginUser(String email, String name) async {
    final data = await supabase.from('users').select().eq('email', email);
    if ((data as List).isEmpty) {
      await supabase.from('users').insert({'email': email, 'name': name});
    }
  }

  // Helper methods
  List<Medicine> getMedicinesByCompany(String companyId) {
    return _medicines.where((m) => m.companyId == companyId).toList();
  }

  // --- Supabase: جلب الأدوية حسب المستودع ---
  Stream<List<Medicine>> medicinesStreamByWarehouse(String warehouseId) {
    return supabase
        .from('medicines')
        .stream(primaryKey: ['id'])
        .eq('warehouseId', warehouseId)
        .map((maps) => maps.map((data) => Medicine.fromJson(data)).toList());
  }

  List<Medicine> getMedicinesByWarehouse(String warehouseId) {
    return _medicines.where((m) => m.warehouseId == warehouseId).toList();
  }

  // إذا لم يعد هناك حقل governorateId في Warehouse، اجعل الدالة تعيد كل المستودعات دائماً
  List<Warehouse> getWarehousesByGovernorate(String governorateId) {
    return _warehouses;
  }

  void removeFromCart(String userId, String medicineId) {}

  getUserCart(String userId) {}

  void addToCart(String userId, medicine) {}

  void clearCart(String id) {}

  void addGovernorate(Governorate newGovernorate) {}

  void deleteGovernorate(String id) {}

  // رفع ملف إلى مستودع (شركات أو غيره) في Supabase Storage
  Future<String?> uploadFileToCompanyStorage(String filePath, String fileName) async {
    final fileBytes = await File(filePath).readAsBytes();
    final response = await Supabase.instance.client.storage
        .from('companies')
        .uploadBinary(fileName, fileBytes, fileOptions: const FileOptions(upsert: true));
    if (response.isNotEmpty) {
      final publicUrl = Supabase.instance.client.storage.from('companies').getPublicUrl(fileName);
      return publicUrl;
    }
    return null;
  }

  // جلب جميع الملفات من مستودع "شركات"
  Future<List<String>> listCompanyFiles() async {
    final response = await Supabase.instance.client.storage.from('companies').list();
    return response.map((f) => Supabase.instance.client.storage.from('companies').getPublicUrl(f.name)).toList();
  }
}

// عند إضافة أو تعديل أو عرض الأدوية، السعر هو بالدولار فقط (price بالدولار)
