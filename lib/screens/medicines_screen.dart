import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/medicine.dart'; // تأكد من أن هذا المسار صحيح
import '../models/warehouse.dart'; // تأكد من أن هذا المسار صحيح
import '../providers/data_provider.dart'; // تأكد من أن هذا المسار صحيح

class MedicinesScreen extends StatefulWidget {
  final String userEmail;
  final String warehouseEmail;
  final List<Medicine> medicines;
  final Warehouse warehouse;

  const MedicinesScreen({
    super.key,
    required this.userEmail,
    required this.warehouseEmail,
    required this.medicines,
    required this.warehouse,
  });

  @override
  State<MedicinesScreen> createState() => _MedicinesScreenState();
}

class _MedicinesScreenState extends State<MedicinesScreen> {
  String selectedType = 'الكل';

  String _getMedicineType(MedicineType type) {
    switch (type) {
      case MedicineType.local:
        return 'وطني';
      case MedicineType.foreign:
        return 'أجنبي';
      case MedicineType.accessories:
        return 'إكسسوار';
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isOwner = widget.userEmail == widget.warehouseEmail;
    List<String> types = ['الكل', 'وطني', 'أجنبي', 'إكسسوار'];

    List<Medicine> filteredMedicines = selectedType == 'الكل'
        ? widget.medicines
        : widget.medicines
            .where((m) => _getMedicineType(m.type) == selectedType)
            .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'المنتجات المتوفرة',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green.shade700,
        actions: [
          if (isOwner)
            IconButton(
              icon: const Icon(Icons.add, color: Colors.white),
              tooltip: 'إضافة دواء جديد',
              onPressed: () => _showAddMedicineDialog(context),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: DropdownButtonFormField<String>(
              value: selectedType,
              isExpanded: true,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedType = value;
                  });
                }
              },
              items: types.map((type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(type, textAlign: TextAlign.center),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: filteredMedicines.length,
              itemBuilder: (context, index) {
                final medicine = filteredMedicines.elementAt(index);

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      // بما أن الواجهة عربية (RTL)، العنصر الأول في الـ Row يظهر يميناً
                      // والعنصر الأخير يظهر يساراً.
                      children: [
                        // -- الجزء الأيمن: تفاصيل الدواء (مرن ويأخذ كل المساحة المتاحة) --
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                medicine.arabicName,
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                medicine.description,
                                textAlign: TextAlign.right,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'السعر: \$${medicine.price.toStringAsFixed(2)}',
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.green.shade800,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 10), // مسافة فاصلة

                        // --- الجزء الأيسر: الأزرار (في عمود ذو عرض ثابت ومحدد) ---
                        // هذا هو الجزء الذي يحدد ترتيب الأزرار وحجم أيقونة الواتساب.
                        SizedBox(
                          width: 30, // تحديد عرض ثابت لضمان أن الأزرار لا تخرج عن نطاقها
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (isOwner) ...[
                                // إذا كان المستخدم مالكًا، أظهر زري التعديل والحذف
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blueAccent),
                                  onPressed: () { /* Edit logic */ },
                                  tooltip: 'تعديل',
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                                  onPressed: () { /* Delete logic */ },
                                  tooltip: 'حذف',
                                ),
                              ] else ...[
                                IconButton(
                                  icon: const Icon(Icons.add_shopping_cart, color: Colors.blue, size: 20),
                                  onPressed: () => _addToCart(medicine),
                                  tooltip: 'إضافة إلى السلة',
                                ),
                                // تمت إزالة أيقونة الواتساب نهائياً بناءً على طلبك
                              ]
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: isOwner
          ? FloatingActionButton(
              onPressed: () {
                _showAddMedicineDialog(context);
              },
              backgroundColor: Colors.green.shade700,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  void _addToCart(Medicine medicine) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text("تمت إضافة ${medicine.arabicName} إلى السلة!"),
          backgroundColor: Colors.blue.shade700),
    );
  }

  void _showAddMedicineDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final arabicNameController = TextEditingController();
    final descriptionController = TextEditingController();
    final priceController = TextEditingController();
    final stockController = TextEditingController();
    MedicineType selectedMedicineType = MedicineType.local;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إضافة دواء جديد'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: arabicNameController,
                  decoration: const InputDecoration(labelText: 'الاسم بالعربية'),
                  validator: (v) => v == null || v.isEmpty ? 'الحقل مطلوب' : null,
                ),
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'الاسم بالإنجليزية'),
                  validator: (v) => v == null || v.isEmpty ? 'الحقل مطلوب' : null,
                ),
                TextFormField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'الوصف'),
                  validator: (v) => v == null || v.isEmpty ? 'الحقل مطلوب' : null,
                ),
                TextFormField(
                  controller: priceController,
                  decoration: const InputDecoration(labelText: 'السعر بالدولار'),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'الحقل مطلوب';
                    if (double.tryParse(v) == null) return 'أدخل رقمًا صحيحًا'; // تم إصلاح هذا السطر ليكون كاملاً
                    return null;
                  },
                ),
                TextFormField(
                  controller: stockController,
                  decoration: const InputDecoration(labelText: 'الكمية'),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'الحقل مطلوب';
                    if (int.tryParse(v) == null) return 'أدخل رقمًا صحيحًا';
                    return null;
                  },
                ),
                DropdownButtonFormField<MedicineType>(
                  value: selectedMedicineType,
                  decoration: const InputDecoration(labelText: 'النوع'),
                  items: MedicineType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(_getMedicineType(type)),
                    );
                  }).toList(),
                  onChanged: (type) {
                    if (type != null) selectedMedicineType = type;
                  },
                  validator: (v) => v == null ? 'اختر نوعًا' : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final newMedicine = Medicine(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: nameController.text,
                  arabicName: arabicNameController.text,
                  description: descriptionController.text,
                  price: double.parse(priceController.text),
                  stock: int.parse(stockController.text),
                  companyId: '',
                  warehouseId: widget.warehouse.id,
                  type: selectedMedicineType,
                  whatsappNumber: widget.warehouse.whatsappNumber,
                );

                final dataProvider = Provider.of<DataProvider>(context, listen: false);
                await dataProvider.addMedicine(newMedicine);

                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تمت إضافة الدواء بنجاح'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade700,
              foregroundColor: Colors.white,
            ),
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }
}