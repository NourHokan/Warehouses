import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/warehouse.dart';
import '../models/medicine.dart';
import '../providers/data_provider.dart';
import '../providers/user_provider.dart';
import '../theme/app_colors.dart';
import 'package:url_launcher/url_launcher.dart'; // تأكد من إضافة هذه الحزمة في pubspec.yaml
import 'dart:io' show Platform;

class ProductsScreen extends StatefulWidget {
  final Warehouse warehouse;

  const ProductsScreen({
    Key? key,
    required this.warehouse,
  }) : super(key: key);

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  String _searchQuery = ''; // متغير لحالة البحث

  // دالة لإظهار مربع حوار إضافة/تعديل المنتج
  void _showAddProductDialog({Medicine? medicine}) {
    final nameController = TextEditingController(text: medicine?.name ?? '');
    final arabicNameController =
        TextEditingController(text: medicine?.arabicName ?? '');
    final descriptionController =
        TextEditingController(text: medicine?.description ?? '');
    final priceController = TextEditingController(
        text: medicine != null ? medicine.price.toString() : '');
    final stockController = TextEditingController(
        text: medicine != null ? medicine.stock.toString() : '');
    final whatsappController = TextEditingController(
        text: medicine?.whatsappNumber ?? widget.warehouse.whatsappNumber);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(medicine == null ? 'إضافة منتج جديد' : 'تعديل المنتج'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration:
                    const InputDecoration(labelText: 'اسم المنتج بالإنجليزية'),
              ),
              TextField(
                controller: arabicNameController,
                decoration:
                    const InputDecoration(labelText: 'اسم المنتج بالعربية'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'وصف المنتج'),
              ),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'السعر بالدولار'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: stockController,
                decoration: const InputDecoration(labelText: 'الكمية المتوفرة'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: whatsappController,
                decoration: const InputDecoration(labelText: 'رقم الواتساب للطلب'),
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
            onPressed: () {
              if (nameController.text.isNotEmpty &&
                  arabicNameController.text.isNotEmpty &&
                  priceController.text.isNotEmpty &&
                  stockController.text.isNotEmpty &&
                  whatsappController.text.isNotEmpty) {
                final dataProvider =
                    Provider.of<DataProvider>(context, listen: false);
                if (medicine == null) {
                  final newMedicine = Medicine(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: nameController.text,
                    arabicName: arabicNameController.text,
                    description: descriptionController.text,
                    price: double.tryParse(priceController.text) ?? 0,
                    stock: int.tryParse(stockController.text) ?? 0,
                    companyId: '',
                    warehouseId: widget.warehouse.id,
                    type: MedicineType.local,
                    whatsappNumber: whatsappController.text,
                  );
                  dataProvider.addMedicine(newMedicine);
                } else {
                  final updatedMedicine = medicine.copyWith(
                    name: nameController.text,
                    arabicName: arabicNameController.text,
                    description: descriptionController.text,
                    price: double.tryParse(priceController.text) ?? 0,
                    stock: int.tryParse(stockController.text) ?? 0,
                    whatsappNumber: whatsappController.text,
                  );
                  dataProvider.updateMedicine(updatedMedicine);
                }
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(medicine == null ? 'تم إضافة المنتج بنجاح' : 'تم تعديل المنتج بنجاح'),
                    backgroundColor: AppColors.primaryGreen,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('يرجى ملء جميع الحقول المطلوبة'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
            ),
            child: Text(medicine == null ? 'إضافة' : 'حفظ'),
          ),
        ],
      ),
    );
  }

  // دالة لحذف المنتج
  void _deleteProduct(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف المنتج'),
        content: const Text('هل أنت متأكد من حذف هذا المنتج؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Provider.of<DataProvider>(context, listen: false)
                  .deleteMedicine(id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم حذف المنتج بنجاح'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  // دالة لفتح واتساب
  Future<void> _launchWhatsApp(String whatsappNumber, {String? message}) async {
    String cleanNumber = whatsappNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    if (cleanNumber.startsWith('+')) {
      cleanNumber = cleanNumber.substring(1);
    }
    final waMeUrl = message == null
        ? 'https://wa.me/$cleanNumber'
        : 'https://wa.me/$cleanNumber?text=${Uri.encodeComponent(message)}';

    debugPrint('Attempting to launch WhatsApp with URL: $waMeUrl');
    debugPrint('Cleaned WhatsApp Number: $cleanNumber');

    try {
      if (await canLaunchUrl(Uri.parse(waMeUrl))) {
        await launchUrl(Uri.parse(waMeUrl), mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('لا يمكن فتح واتساب. تأكد من وجود تطبيق واتساب أو جرب من متصفح آخر.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ أثناء محاولة فتح واتساب: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      debugPrint('Error launching WhatsApp: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final dataProvider = Provider.of<DataProvider>(context);
    final canManageProducts = userProvider.canManageMedicines();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'منتجات ${widget.warehouse.name}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
          ),
        ),
        backgroundColor: AppColors.primaryGreen,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'بحث عن دواء',
            onPressed: () async {
              final medicines = await dataProvider.medicinesStreamByWarehouse(widget.warehouse.id).first;
              final result = await showSearch<Medicine?>(
                context: context,
                delegate: MedicineSearchDelegate(medicines),
              );
              if (result != null) {
                setState(() {
                  _searchQuery = result.arabicName;
                });
              }
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Medicine>>(
        stream: dataProvider.medicinesStreamByWarehouse(widget.warehouse.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            debugPrint('Error loading medicines from Firestore: ${snapshot.error}');
            return Center(child: Text('خطأ في تحميل المنتجات: ${snapshot.error}'));
          }

          // تم تعديل هذا الجزء لتبسيط منطق عرض "لا توجد بيانات" / "لا توجد نتائج بحث"
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'لا توجد منتجات بعد لهذا المستودع.',
                style: TextStyle(fontSize: 18, color: AppColors.textSecondary),
              ),
            );
          }

          final List<Medicine> allMedicines = snapshot.data!;
          final List<Medicine> filteredMedicines = allMedicines
              .where((m) =>
                  m.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  m.arabicName.toLowerCase().contains(_searchQuery.toLowerCase()))
              .toList();

          if (filteredMedicines.isEmpty) {
            // إذا كانت القائمة المفلترة فارغة، فهذا يعني أن البحث لم يسفر عن نتائج
            // (لأن الحالة التي تكون فيها `allMedicines` فارغة تمت معالجتها أعلاه)
            return Center(
              child: Text(
                'لا توجد نتائج للبحث عن "$_searchQuery"',
                style: const TextStyle(fontSize: 18, color: AppColors.textSecondary),
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
                          Icons.medical_services,
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
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'السعر: ${medicine.price} دولار',
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
                      const SizedBox(width: 8), // مسافة صغيرة قبل الأزرار
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () async {
                              final whatsappNumber = medicine.whatsappNumber?.isNotEmpty == true
                                ? medicine.whatsappNumber!
                                : widget.warehouse.whatsappNumber;
                              if (whatsappNumber.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('لا يوجد رقم واتساب لهذا المنتج أو المستودع'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }
                              String cleanNumber = whatsappNumber.replaceAll(RegExp(r'[^0-9+]'), '');
                              if (cleanNumber.startsWith('+')) {
                                cleanNumber = cleanNumber.substring(1);
                              }
                              final waMeUrl = 'https://wa.me/$cleanNumber?text=${Uri.encodeComponent('مرحباً، أود طلب المنتج: ${medicine.arabicName} المتوفر في مستودع ${widget.warehouse.name}')}';
                              try {
                                await launchUrl(Uri.parse(waMeUrl), mode: LaunchMode.platformDefault);
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('حدث خطأ أثناء محاولة فتح واتساب: $e'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
                            icon: const Icon(Icons.shopping_cart, size: 18),
                            label: const Text('طلب'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryGreen,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                          ),
                          if (canManageProducts) // إذا كان المستخدم لديه صلاحية الإدارة
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: AppColors.primaryGreen),
                                  tooltip: 'تعديل المنتج',
                                  onPressed: () => _showAddProductDialog(medicine: medicine),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  tooltip: 'حذف المنتج',
                                  onPressed: () => _deleteProduct(medicine.id),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: canManageProducts
          ? FloatingActionButton(
              onPressed: () => _showAddProductDialog(),
              backgroundColor: AppColors.primaryGreen,
              child: const Icon(Icons.add, color: Colors.white), // تحديد لون الأيقونة للتباين
            )
          : null,
    );
  }
}

// MedicineSearchDelegate لم يتم تغييره لأنه لم يكن به مشاكل واضحة من هذا الكود
// وهو مصمم لآلية بحث مختلفة (اختيار عنصر من القائمة بدلاً من فلترة القائمة الحالية)
// يفضل استخدام SearchDelegate مع showSearch بدلاً من AlertDialog للبحث المتقدم في المستقبل (كما هو مذكور في التعليق الأصلي)
class MedicineSearchDelegate extends SearchDelegate<Medicine?> {
  final List<Medicine> medicines; // يفترض أن يتم تمرير قائمة الأدوية هنا
  // أو أن يقوم Delegate بجلبها بنفسه إذا كان سيستخدم بشكل مستقل

  MedicineSearchDelegate(this.medicines);

  @override
  String get searchFieldLabel => 'ابحث عن اسم الدواء...';


  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          showSuggestions(context); // عرض الاقتراحات بعد مسح النص
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null), // إغلاق البحث بدون نتيجة
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // هذا الجزء يُبنى عندما يقوم المستخدم بالضغط على "بحث" في لوحة المفاتيح
    final results = medicines.where((m) =>
      m.name.toLowerCase().contains(query.toLowerCase()) ||
      m.arabicName.toLowerCase().contains(query.toLowerCase())
    ).toList();

    if (results.isEmpty) {
      return const Center(child: Text('لا توجد نتائج مطابقة.'));
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final medicine = results[index];
        return ListTile(
          title: Text(medicine.arabicName),
          subtitle: Text(medicine.name),
          onTap: () => close(context, medicine), // إغلاق البحث مع إعادة الدواء المختار
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // هذا الجزء يُبنى أثناء كتابة المستخدم في حقل البحث
    final suggestions = medicines.where((m) =>
      m.name.toLowerCase().contains(query.toLowerCase()) ||
      m.arabicName.toLowerCase().contains(query.toLowerCase())
    ).toList();

    if (query.isEmpty) {
        // يمكن عرض قائمة مبدئية أو رسالة توجيهية هنا
        return const Center(child: Text('ابدأ الكتابة للبحث عن دواء.'));
    }
    if (suggestions.isEmpty) {
      return const Center(child: Text('لا توجد اقتراحات مطابقة.'));
    }

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final medicine = suggestions[index];
        return ListTile(
          title: Text(medicine.arabicName),
          subtitle: Text(medicine.name),
          onTap: () {
            query = medicine.arabicName; // يمكن وضع الاسم في حقل البحث
            showResults(context); // عرض النتائج مباشرة أو
            // close(context, medicine); // إغلاق البحث مع إعادة الدواء المختار
          },
        );
      },
    );
  }
}