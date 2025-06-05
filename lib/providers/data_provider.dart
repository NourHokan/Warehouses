import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cart.dart';
import '../models/medicine.dart';
import '../models/warehouse.dart';
import '../models/governorate.dart';
import '../models/pharmaceutical_company.dart';

class DataProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

  // --- Firestore: مزامنة المستودعات ---
  Stream<List<Warehouse>> get warehousesStream {
    return _firestore.collection('warehouses').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Warehouse.fromJson(doc.data()))
          .toList();
    });
  }

  // Deprecated: use warehousesStream for real-time updates
  Future<void> fetchWarehouses() async {
    final snapshot = await _firestore.collection('warehouses').get();
    _warehouses =
        snapshot.docs.map((doc) => Warehouse.fromJson(doc.data())).toList();
    notifyListeners();
  }

  Future<void> addWarehouse(Warehouse warehouse) async {
    await _firestore
        .collection('warehouses')
        .doc(warehouse.id)
        .set(warehouse.toJson());
    // No need to call fetchWarehouses();
  }

  Future<void> updateWarehouse(Warehouse warehouse) async {
    await _firestore
        .collection('warehouses')
        .doc(warehouse.id)
        .update(warehouse.toJson());
    // No need to call fetchWarehouses();
  }

  Future<void> deleteWarehouse(String id) async {
    await _firestore.collection('warehouses').doc(id).delete();
    // No need to call fetchWarehouses();
  }

  // --- Firestore: مزامنة الأدوية ---
  Future<void> fetchMedicines() async {
    final snapshot = await _firestore.collection('medicines').get();
    _medicines =
        snapshot.docs.map((doc) => Medicine.fromJson(doc.data())).toList();
    notifyListeners();
  }

  Future<void> addMedicine(Medicine medicine) async {
    await _firestore
        .collection('medicines')
        .doc(medicine.id)
        .set(medicine.toJson());
    await fetchMedicines();
  }

  Future<void> updateMedicine(Medicine medicine) async {
    await _firestore
        .collection('medicines')
        .doc(medicine.id)
        .update(medicine.toJson());
    await fetchMedicines();
  }

  Future<void> deleteMedicine(String id) async {
    await _firestore.collection('medicines').doc(id).delete();
    await fetchMedicines();
  }

  // --- Firestore: تسجيل المستخدمين ---
  Future<void> registerOrLoginUser(String email, String name) async {
    final userDoc = _firestore.collection('users').doc(email);
    final doc = await userDoc.get();
    if (!doc.exists) {
      await userDoc.set({'email': email, 'name': name});
    }
    // يمكنك هنا تحميل بيانات المستخدم أو حفظها في الذاكرة
  }

  // Helper methods
  List<Medicine> getMedicinesByCompany(String companyId) {
    return _medicines.where((m) => m.companyId == companyId).toList();
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

  // --- Firestore: مزامنة الأدوية بشكل فوري ---
  Stream<List<Medicine>> medicinesStreamByWarehouse(String warehouseId) {
    return _firestore
        .collection('medicines')
        .where('warehouseId', isEqualTo: warehouseId)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Medicine.fromJson(doc.data())).toList());
  }
}

// عند إضافة أو تعديل أو عرض الأدوية، السعر هو بالدولار فقط (price بالدولار)
