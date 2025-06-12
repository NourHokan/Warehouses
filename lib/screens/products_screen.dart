import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/warehouse.dart';
import '../models/medicine.dart';
import '../providers/data_provider.dart';
import '../providers/user_provider.dart';
import '../theme/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../screens/auth_gate.dart';

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
                    companyId: '', // Assuming companyId is not set here
                    warehouseId: widget.warehouse.id,
                    type: MedicineType.local, // Assuming type is local
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
              } else {
                // If search is dismissed without selection, clear the query
                setState(() {
                  _searchQuery = '';
                });
              }
            },
          ),
          if (userProvider.currentUser != null)
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'تسجيل الخروج',
              onPressed: () {
                Provider.of<UserProvider>(context, listen: false).logout();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const AuthGate()),
                  (route) => false,
                );
              },
            ),
        ],
      ),
      floatingActionButton: canManageProducts
          ? FloatingActionButton(
              onPressed: _showAddProductDialog,
              backgroundColor: AppColors.primaryGreen,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
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

          if (_searchQuery.isNotEmpty && filteredMedicines.isEmpty) {
            return Center(
              child: Text(
                'لا توجد نتائج للبحث عن "$_searchQuery"',
                style: const TextStyle(fontSize: 18, color: AppColors.textSecondary),
              ),
            );
          } else if (_searchQuery.isEmpty && filteredMedicines.isEmpty) {
             return const Center(
              child: Text(
                'لا توجد منتجات بعد لهذا المستودع.',
                style: TextStyle(fontSize: 18, color: AppColors.textSecondary),
              ),
            );
          }


          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredMedicines.length,
            itemBuilder: (context, index) {
              final medicine = filteredMedicines[index];
              return LayoutBuilder(
                builder: (context, constraints) {
                  final isNarrow = constraints.maxWidth < 400;
                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: isNarrow
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Center(
                                  child: Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryGreen.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: const Icon(
                                      Icons.medical_services,
                                      color: AppColors.primaryGreen,
                                      size: 34,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  medicine.arabicName,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                  textDirection: TextDirection.rtl,
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
                                  textDirection: TextDirection.rtl,
                                ),
                                const SizedBox(height: 8),
                                
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.green[50],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.attach_money, size: 16, color: AppColors.primaryGreen),
                                          const SizedBox(width: 2),
                                          Text(
                                            '${medicine.price}',
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.primaryGreen,
                                            ),
                                            textDirection: TextDirection.rtl,
                                          ),
                                          const Text(' دولار', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.blue[50],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.inventory_2, size: 16, color: Colors.blue),
                                          const SizedBox(width: 2),
                                          Text(
                                            '${medicine.stock}',
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blue,
                                            ),
                                            textDirection: TextDirection.rtl,
                                          ),
                                          const Text(' متوفر', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    PopupMenuButton<String>(
                                      icon: const Icon(Icons.more_vert, size: 22),
                                      onSelected: (value) {
                                        if (value == 'edit') {
                                          _showAddProductDialog(medicine: medicine);
                                        } else if (value == 'delete') {
                                          _deleteProduct(medicine.id);
                                        }
                                      },
                                      itemBuilder: (context) => [
                                        const PopupMenuItem(
                                          value: 'edit',
                                          child: Text('تعديل'),
                                        ),
                                        const PopupMenuItem(
                                          value: 'delete',
                                          child: Text('حذف', style: TextStyle(color: Colors.red)),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 2),
                                    IconButton(
                                      icon: const FaIcon(FontAwesomeIcons.whatsapp, color: Colors.green, size: 20),
                                      tooltip: 'طلب عبر واتساب',
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      onPressed: () async {
                                        final whatsappNumber = medicine.whatsappNumber.isNotEmpty
                                            ? medicine.whatsappNumber
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
                                    ),
                                  ],
                                ),
                              ],
                            )
                          : Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryGreen.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Icon(
                                    Icons.medical_services,
                                    color: AppColors.primaryGreen,
                                    size: 34,
                                  ),
                                ),
                                const SizedBox(width: 18),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        medicine.arabicName,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textPrimary,
                                        ),
                                        textDirection: TextDirection.rtl,
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
                                        textDirection: TextDirection.rtl,
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.green[50],
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Row(
                                              children: [
                                                const Icon(Icons.attach_money, size: 16, color: AppColors.primaryGreen),
                                                const SizedBox(width: 2),
                                                Text(
                                                  '${medicine.price}',
                                                  style: const TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                    color: AppColors.primaryGreen,
                                                  ),
                                                  textDirection: TextDirection.rtl,
                                                ),
                                                const Text(' دولار', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.blue[50],
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Row(
                                              children: [
                                                const Icon(Icons.inventory_2, size: 16, color: Colors.blue),
                                                const SizedBox(width: 2),
                                                Text(
                                                  '${medicine.stock}',
                                                  style: const TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.blue,
                                                  ),
                                                  textDirection: TextDirection.rtl,
                                                ),
                                                const Text(' متوفر', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: () async {
                                        final whatsappNumber = medicine.whatsappNumber.isNotEmpty
                                            ? medicine.whatsappNumber
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
                                        final waMeUrl = 'https://wa.me/' + cleanNumber + '?text=' + Uri.encodeComponent('مرحباً، أود طلب المنتج: ${medicine.arabicName} المتوفر في مستودع ${widget.warehouse.name}');
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
                                      icon: const FaIcon(FontAwesomeIcons.whatsapp, color: Colors.white, size: 18),
                                      label: const Text('طلب عبر واتساب', style: TextStyle(fontWeight: FontWeight.bold)),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green[700],
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                        textStyle: const TextStyle(fontSize: 15),
                                      ),
                                    ),
                                    if (canManageProducts)
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit, color: AppColors.primaryGreen, size: 20),
                                            tooltip: 'تعديل المنتج',
                                            onPressed: () => _showAddProductDialog(medicine: medicine),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete, color: Colors.red, size: 20),
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
          );
        },
      ),
    );
  }
}

// --- MedicineSearchDelegate Implementation ---
class MedicineSearchDelegate extends SearchDelegate<Medicine?> {
  final List<Medicine> medicines;

  MedicineSearchDelegate(this.medicines);

  @override
  String get searchFieldLabel => 'ابحث عن دواء';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          showSuggestions(context);
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = medicines
        .where((medicine) =>
            medicine.arabicName.toLowerCase().contains(query.toLowerCase()) ||
            medicine.name.toLowerCase().contains(query.toLowerCase()))
        .toList();

    if (results.isEmpty) {
      return Center(
        child: Text('لا توجد نتائج للبحث عن "$query"',
            style: const TextStyle(fontSize: 18, color: AppColors.textSecondary)),
      );
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final medicine = results[index];
        return ListTile(
          title: Text(medicine.arabicName),
          subtitle: Text(medicine.description),
          onTap: () {
            close(context, medicine);
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestionList = query.isEmpty
        ? []
        : medicines
            .where((medicine) =>
                medicine.arabicName.toLowerCase().contains(query.toLowerCase()) ||
                medicine.name.toLowerCase().contains(query.toLowerCase()))
            .toList();

    return ListView.builder(
      itemCount: suggestionList.length,
      itemBuilder: (context, index) {
        final medicine = suggestionList[index];
        return ListTile(
          title: Text(medicine.arabicName),
          subtitle: Text(medicine.description),
          onTap: () {
            query = medicine.arabicName;
            showResults(context);
          },
        );
      },
    );
  }
}