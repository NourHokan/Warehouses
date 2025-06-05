import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/medicine.dart';
import '../providers/data_provider.dart';
import '../providers/user_provider.dart';
import '../theme/app_colors.dart';

class AddMedicineManualScreen extends StatefulWidget {
  final String warehouseId;
  final MedicineType type;
  const AddMedicineManualScreen(
      {Key? key, required this.warehouseId, required this.type})
      : super(key: key);

  @override
  State<AddMedicineManualScreen> createState() =>
      _AddMedicineManualScreenState();
}

class _AddMedicineManualScreenState extends State<AddMedicineManualScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _arabicNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _whatsappController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _arabicNameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _whatsappController.dispose();
    super.dispose();
  }

  void _addMedicine() {
    if (!_formKey.currentState!.validate()) return;
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    final newMedicine = Medicine(
      id: DateTime.now().toString(),
      name: _nameController.text.trim(),
      arabicName: _arabicNameController.text.trim(),
      description: _descriptionController.text.trim(),
      price: double.tryParse(_priceController.text) ?? 0,
      stock: int.tryParse(_stockController.text) ?? 0,
      companyId: '', // يمكن تعديله لاحقاً حسب الحاجة
      warehouseId: widget.warehouseId,
      type: widget.type, whatsappNumber: _whatsappController.text.trim(),
    );
    dataProvider.addMedicine(newMedicine);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تمت إضافة الدواء بنجاح'),
        backgroundColor: AppColors.primaryGreen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final allowedEmails = [
      'nourhokan001@gmail.com',
      'admin@gmail.com',
      'admin1@gmail.com',
      'admin12@gmail.com',
      'admin123@gmail.com',
      'admin1234@gmail.com',
    ];
    final canEdit = allowedEmails.contains(userProvider.currentUser?.email);
    return Scaffold(
      appBar: AppBar(
        title: const Text('إضافة دواء'),
        backgroundColor: AppColors.primaryGreen,
      ),
      body: canEdit
          ? Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                          labelText: 'اسم الدواء (بالإنجليزية)'),
                      validator: (value) => value == null || value.isEmpty
                          ? 'يرجى إدخال اسم الدواء'
                          : null,
                      textAlign: TextAlign.right,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _arabicNameController,
                      decoration: const InputDecoration(
                        labelText: 'اسم الدواء (بالعربية)',
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? 'يرجى إدخال اسم الدواء بالعربية'
                          : null,
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontSize: 16),
                      maxLines: 1,
                      textDirection: TextDirection.rtl,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration:
                          const InputDecoration(labelText: 'وصف الدواء'),
                      maxLines: 3,
                      textAlign: TextAlign.right,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(labelText: 'السعر بالدولار'),
                      keyboardType: TextInputType.number,
                      validator: (value) => value == null || value.isEmpty
                          ? 'يرجى إدخال السعر بالدولار'
                          : null,
                      textAlign: TextAlign.right,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _stockController,
                      decoration:
                          const InputDecoration(labelText: 'الكمية المتوفرة'),
                      keyboardType: TextInputType.number,
                      validator: (value) => value == null || value.isEmpty
                          ? 'يرجى إدخال الكمية'
                          : null,
                      textAlign: TextAlign.right,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _whatsappController,
                      decoration: const InputDecoration(labelText: 'رقم الواتساب للطلب'),
                      keyboardType: TextInputType.phone,
                      validator: (value) => value == null || value.isEmpty ? 'يرجى إدخال رقم الواتساب' : null,
                      textAlign: TextAlign.right,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _addMedicine,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: const Text(
                        'إضافة',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : const Center(
              child: Text(
                'ليس لديك صلاحية إضافة الأدوية',
                style: TextStyle(fontSize: 18, color: Colors.red),
              ),
            ),
    );
  }
}
