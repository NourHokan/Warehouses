import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/medicine.dart';
import '../models/warehouse.dart';
import '../providers/data_provider.dart';
import '../providers/user_provider.dart';
import '../theme/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';
import 'add_medicine_manual_screen.dart';

class CategoriesScreen extends StatelessWidget {
  final Warehouse warehouse;

  const CategoriesScreen({
    Key? key,
    required this.warehouse,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'أقسام الأدوية لـ ${warehouse.name}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
          ),
        ),
        backgroundColor: AppColors.primaryGreen,
        centerTitle: true,
      ),
      body: StreamBuilder<List<Medicine>>(
        stream: dataProvider.medicinesStreamByWarehouse(warehouse.id),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
                child: Text('خطأ في جلب الأدوية:\n${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final medicines = snapshot.data ?? [];
          final localMedicines =
              medicines.where((m) => m.type == MedicineType.local).toList();
          final foreignMedicines =
              medicines.where((m) => m.type == MedicineType.foreign).toList();
          final accessories = medicines
              .where((m) => m.type == MedicineType.accessories)
              .toList();
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildCategoryCard(
                context,
                'الأدوية الوطنية',
                localMedicines,
                Icons.medication,
              ),
              const SizedBox(height: 16),
              _buildCategoryCard(
                context,
                'الأدوية الأجنبية',
                foreignMedicines,
                Icons.medication_outlined,
              ),
              const SizedBox(height: 16),
              _buildCategoryCard(
                context,
                'الإكسسوار',
                accessories,
                Icons.medical_services,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    String title,
    List<Medicine> medicines,
    IconData icon,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MedicinesListScreen(
                title: title,
                warehouseId: warehouse.id,
                medicines: medicines,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Icon(
                  icon,
                  color: AppColors.primaryGreen,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${medicines.length} منتج',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MedicinesListScreen extends StatefulWidget {
  final String title;
  final String warehouseId;
  final List<Medicine> medicines;

  const MedicinesListScreen({
    Key? key,
    required this.title,
    required this.warehouseId,
    required this.medicines,
  }) : super(key: key);

  @override
  State<MedicinesListScreen> createState() => _MedicinesListScreenState();
}

class _MedicinesListScreenState extends State<MedicinesListScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    const allowedEmails = [
      'nourhokan001@gmail.com',
      'admin@gmail.com',
      'admin1@gmail.com',
      'admin12@gmail.com',
      'admin123@gmail.com',
      'admin1234@gmail.com',
    ];
    final canEdit = allowedEmails.contains(userProvider.currentUser?.email);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
          ),
        ),
        backgroundColor: AppColors.primaryGreen,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'إضافة دواء يدوي',
            onPressed: () {
              MedicineType type = MedicineType.local;
              if (widget.title == 'الأدوية الأجنبية') {
                type = MedicineType.foreign;
              } else if (widget.title == 'الإكسسوار') {
                type = MedicineType.accessories;
              }
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => AddMedicineManualScreen(
                    warehouseId: widget.warehouseId,
                    type: type,
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'بحث',
            onPressed: () async {
              final query = await showDialog<String>(
                context: context,
                builder: (context) {
                  final controller = TextEditingController(text: _searchQuery);
                  return AlertDialog(
                    title: const Text('بحث عن دواء'),
                    content: TextField(
                      controller: controller,
                      decoration: const InputDecoration(
                          hintText: 'اسم الدواء أو جزء منه'),
                      autofocus: true,
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, ''),
                        child: const Text('مسح'),
                      ),
                      ElevatedButton(
                        onPressed: () =>
                            Navigator.pop(context, controller.text),
                        child: const Text('بحث'),
                      ),
                    ],
                  );
                },
              );
              if (query != null) {
                setState(() {
                  _searchQuery = query;
                });
              }
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Medicine>>(
        stream: Provider.of<DataProvider>(context)
            .medicinesStreamByWarehouse(widget.warehouseId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
                child: Text('خطأ في تحميل الأدوية: ${snapshot.error}'));
          }
          final medicines = snapshot.data ?? [];
          final filteredMedicines = medicines.where((medicine) {
            final query = _searchQuery.trim().toLowerCase();
            return _filterByType(medicine, widget.title) &&
                (query.isEmpty ||
                    medicine.name.toLowerCase().contains(query) ||
                    medicine.arabicName.toLowerCase().contains(query));
          }).toList();
          if (filteredMedicines.isEmpty) {
            return Center(
              child: Text(
                _searchQuery.isEmpty
                    ? 'لا توجد أدوية في هذا القسم.'
                    : 'لا توجد نتائج للبحث عن "$_searchQuery"',
                style: const TextStyle(
                    fontSize: 18, color: AppColors.textSecondary),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredMedicines.length,
            itemBuilder: (context, index) {
              final medicine = filteredMedicines[index];
              return Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Icon(
                          Icons.medication,
                          color: AppColors.primaryGreen,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              medicine.arabicName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              medicine.description,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                                'السعر: \$${medicine.price}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'الكمية المتوفرة: ${medicine.stock}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final whatsappNumber = medicine.whatsappNumber;

                          if (whatsappNumber == null ||
                              whatsappNumber.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('لا يوجد رقم واتساب متاح لهذا الدواء'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          String cleanNumber =
                              whatsappNumber.replaceAll(RegExp(r'[^0-9+]'), '');
                          if (cleanNumber.startsWith('+')) {
                            cleanNumber = cleanNumber.substring(1);
                          }
                          final waMeUrl =
                              'https://wa.me/$cleanNumber?text=${Uri.encodeComponent('مرحباً، أود طلب دواء: ${medicine.arabicName} (1 قطعة)')}';
                          try {
                            if (await canLaunchUrl(Uri.parse(waMeUrl))) {
                              await launchUrl(Uri.parse(waMeUrl),
                                  mode: LaunchMode.externalApplication);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'لا يمكن فتح واتساب عبر المتصفح أو التطبيق. تأكد من وجود تطبيق واتساب أو جرب من متصفح آخر.'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    Text('حدث خطأ أثناء محاولة فتح واتساب: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.shopping_cart),
                        label: const Text('طلب عبر واتساب'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                      if (canEdit) ...[
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          tooltip: 'تعديل الدواء',
                          onPressed: () {
                            _showEditMedicineDialog(context, medicine);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          tooltip: 'حذف الدواء',
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('حذف الدواء'),
                                content: const Text(
                                    'هل أنت متأكد من حذف هذا الدواء؟'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('إلغاء'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      Provider.of<DataProvider>(context,
                                              listen: false)
                                          .deleteMedicine(medicine.id);
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text('تم حذف الدواء بنجاح'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                    ),
                                    child: const Text('حذف',
                                        style: TextStyle(color: Colors.white)),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  bool _filterByType(Medicine m, String title) {
    if (title == 'الأدوية الوطنية') return m.type == MedicineType.local;
    if (title == 'الأدوية الأجنبية') return m.type == MedicineType.foreign;
    if (title == 'الإكسسوار') return m.type == MedicineType.accessories;
    return true;
  }

  void _showEditMedicineDialog(BuildContext context, Medicine medicine) {
    final nameController = TextEditingController(text: medicine.name);
    final arabicNameController =
        TextEditingController(text: medicine.arabicName);
    final descriptionController =
        TextEditingController(text: medicine.description);
    final priceController =
        TextEditingController(text: medicine.price.toString());
    final stockController =
        TextEditingController(text: medicine.stock.toString());
    final whatsappController =
        TextEditingController(text: medicine.whatsappNumber);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تعديل الدواء'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'الاسم الإنجليزي'),
              ),
              TextField(
                controller: arabicNameController,
                decoration: const InputDecoration(labelText: 'الاسم العربي'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'الوصف'),
              ),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'السعر'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: stockController,
                decoration: const InputDecoration(labelText: 'الكمية'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: whatsappController,
                decoration:
                    const InputDecoration(labelText: 'رقم الواتساب'),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              final updatedMedicine = medicine.copyWith(
                name: nameController.text,
                arabicName: arabicNameController.text,
                description: descriptionController.text,
                price: double.tryParse(priceController.text) ?? medicine.price,
                stock: int.tryParse(stockController.text) ?? medicine.stock,
                whatsappNumber: whatsappController.text.isEmpty
                    ? null
                    : whatsappController.text,
              );
              await Provider.of<DataProvider>(context, listen: false)
                  .updateMedicine(updatedMedicine);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم تعديل الدواء بنجاح'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text('حفظ', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class MedicineSearchDelegate extends SearchDelegate<Medicine?> {
  final List<Medicine> medicines;
  MedicineSearchDelegate(this.medicines);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () => query = '',
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = medicines
        .where((m) =>
            m.name.toLowerCase().contains(query.toLowerCase()) ||
            m.arabicName.toLowerCase().contains(query.toLowerCase()))
        .toList();
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final medicine = results[index];
        return ListTile(
          title: Text(medicine.arabicName),
          subtitle: Text(medicine.name),
          onTap: () => close(context, medicine),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = medicines
        .where((m) =>
            m.name.toLowerCase().contains(query.toLowerCase()) ||
            m.arabicName.toLowerCase().contains(query.toLowerCase()))
        .toList();
    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final medicine = suggestions[index];
        return ListTile(
          title: Text(medicine.arabicName),
          subtitle: Text(medicine.name),
          onTap: () => close(context, medicine),
        );
      },
    );
  }
}
