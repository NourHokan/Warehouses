import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/warehouse.dart';
import '../providers/data_provider.dart';
import '../providers/user_provider.dart';
import '../theme/app_colors.dart';
import 'categories_screen.dart';

class WarehousesListScreen extends StatefulWidget {
  final String? governorateId;
  const WarehousesListScreen({Key? key, this.governorateId}) : super(key: key);

  @override
  State<WarehousesListScreen> createState() => _WarehousesListScreenState();
}

class _WarehousesListScreenState extends State<WarehousesListScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _whatsappController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _showAddWarehouseDialog(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    final _formKey = GlobalKey<FormState>();
    final _nameController = TextEditingController();
    final _addressController = TextEditingController();
    final _whatsappController = TextEditingController();
    final _emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إضافة مستودع جديد'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'اسم المستودع'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'يرجى إدخال اسم المستودع';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(labelText: 'العنوان'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'يرجى إدخال العنوان';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _whatsappController,
                  decoration: const InputDecoration(labelText: 'رقم الواتساب'),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'يرجى إدخال رقم الواتساب';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _emailController,
                  decoration:
                      const InputDecoration(labelText: 'البريد الإلكتروني'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'يرجى إدخال البريد الإلكتروني';
                    }
                    if (!value.contains('@')) {
                      return 'يرجى إدخال بريد إلكتروني صحيح';
                    }
                    return null;
                  },
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
              if (_formKey.currentState!.validate()) {
                final newWarehouse = Warehouse(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: _nameController.text,
                  address: _addressController.text,
                  whatsappNumber: _whatsappController.text,
                  email: _emailController.text,
                  governorateId: widget.governorateId ?? '',
                );
                await dataProvider.addWarehouse(newWarehouse);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تمت إضافة المستودع بنجاح'),
                    backgroundColor: AppColors.primaryGreen,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
            ),
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  void _showEditWarehouseDialog(BuildContext context, Warehouse warehouse) {
    _nameController.text = warehouse.name;
    _addressController.text = warehouse.address;
    _whatsappController.text = warehouse.whatsappNumber;
    _emailController.text = warehouse.email;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تعديل المستودع'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'اسم المستودع'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'يرجى إدخال اسم المستودع';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(labelText: 'العنوان'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'يرجى إدخال العنوان';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _whatsappController,
                  decoration: const InputDecoration(labelText: 'رقم الواتساب'),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'يرجى إدخال رقم الواتساب';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _emailController,
                  decoration:
                      const InputDecoration(labelText: 'البريد الإلكتروني'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'يرجى إدخال البريد الإلكتروني';
                    }
                    if (!value.contains('@')) {
                      return 'يرجى إدخال بريد إلكتروني صحيح';
                    }
                    return null;
                  },
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
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                final updatedWarehouse = Warehouse(
                  id: warehouse.id,
                  name: _nameController.text,
                  address: _addressController.text,
                  whatsappNumber: _whatsappController.text,
                  email: _emailController.text,
                  governorateId: warehouse.governorateId,
                );
                Provider.of<DataProvider>(context, listen: false)
                    .updateWarehouse(updatedWarehouse);
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
            ),
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Warehouse warehouse) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف مستودع ${warehouse.name}؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Provider.of<DataProvider>(context, listen: false)
                  .deleteWarehouse(warehouse.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primaryGreen, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchWhatsApp(String whatsappNumber, {String? message}) async {
    String cleanNumber = whatsappNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    String waMeNumber =
        cleanNumber.startsWith('+') ? cleanNumber.substring(1) : cleanNumber;
    final waMeUrl = message == null
        ? 'https://wa.me/$waMeNumber'
        : 'https://wa.me/$waMeNumber?text=${Uri.encodeComponent(message)}';
    try {
      if (await canLaunchUrl(Uri.parse(waMeUrl))) {
        await launchUrl(Uri.parse(waMeUrl),
            mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'لا يمكن فتح واتساب عبر المتصفح. تأكد من وجود اتصال بالإنترنت.'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('حدث خطأ أثناء محاولة فتح واتساب.'),
          ),
        );
      }
    }
  }

  Future<void> _launchEmail(String email) async {
    final url = 'mailto:$email';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  bool _canEditWarehouses(String? email) {
    const allowedEmails = [
      'nourhokan001@gmail.com',
      'admin@gmail.com',
      'admin1@gmail.com',
      'admin12@gmail.com',
      'admin123@gmail.com',
      'admin1234@gmail.com',
    ];
    return email != null && allowedEmails.contains(email);
  }

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    // تصفية المستودعات حسب المحافظة إذا تم تمرير governorateId
    // final warehouses = widget.governorateId == null
    //     ? dataProvider.warehouses
    //     : dataProvider.getWarehousesByGovernorate(widget.governorateId!);
    // لم يعد هناك حاجة لهذا المتغير، حيث يتم جلب المستودعات من StreamBuilder مباشرة

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'المستودعات',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
          ),
        ),
        backgroundColor: AppColors.primaryGreen,
        centerTitle: true,
        actions: [
          // إظهار زر إضافة مستودع للجميع
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'إضافة مستودع جديد',
            onPressed: () => _showAddWarehouseDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'بحث عن مستودع',
            onPressed: () async {
              showSearch<Warehouse?>(
                context: context,
                delegate: WarehouseSearchDelegate(dataProvider.warehouses),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Warehouse>>(
        stream: dataProvider.warehousesStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
                child: Text('خطأ في جلب البيانات: \n${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          var warehouses = snapshot.data ?? [];
          // تصفية المستودعات حسب المحافظة إذا تم تمرير governorateId
          if (widget.governorateId != null) {
            warehouses = warehouses
                .where((w) => w.governorateId == widget.governorateId)
                .toList();
          }
          if (warehouses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'لا توجد مستودعات',
                    style: TextStyle(fontSize: 18, color: AppColors.textSecondary),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 24),
                    child: ElevatedButton.icon(
                      onPressed: () => _showAddWarehouseDialog(context),
                      icon: const Icon(Icons.add),
                      label: const Text('إضافة مستودع جديد'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: warehouses.length,
            itemBuilder: (context, index) {
              final warehouse = warehouses[index];
              return Card(
                  elevation: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CategoriesScreen(
                            warehouse: warehouse,
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color:
                                      AppColors.primaryGreen.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: const Icon(
                                  Icons.store,
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
                                      warehouse.name,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      warehouse.address,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (_canEditWarehouses(
                                  userProvider.currentUser?.email))
                                PopupMenuButton<String>(
                                  onSelected: (value) {
                                    if (value == 'edit') {
                                      _showEditWarehouseDialog(
                                          context, warehouse);
                                    } else if (value == 'delete') {
                                      _showDeleteConfirmation(
                                          context, warehouse);
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: 'edit',
                                      child: Row(
                                        children: [
                                          Icon(Icons.edit,
                                              color: AppColors.primaryGreen),
                                          SizedBox(width: 8),
                                          Text('تعديل'),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: 'delete',
                                      child: Row(
                                        children: [
                                          Icon(Icons.delete, color: Colors.red),
                                          SizedBox(width: 8),
                                          Text('حذف'),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildInfoRow(
                                  Icons.message,
                                  warehouse.whatsappNumber,
                                  () => _launchWhatsApp(
                                    warehouse.whatsappNumber,
                                    message:
                                        'مرحباً، أود الاستفسار عن المستودع: ${warehouse.name}',
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          _buildInfoRow(
                            Icons.email,
                            warehouse.email,
                            () => _launchEmail(warehouse.email),
                          ),
                        ],
                      ),
                    ),
                  ));
            },
          );
        },
      ),
    );
  }
}

class WarehouseSearchDelegate extends SearchDelegate<Warehouse?> {
  final List<Warehouse> warehouses;
  WarehouseSearchDelegate(this.warehouses);

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
    final results = warehouses
        .where((w) =>
            w.name.toLowerCase().contains(query.toLowerCase()) ||
            w.address.toLowerCase().contains(query.toLowerCase()))
        .toList();
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final warehouse = results[index];
        return ListTile(
          title: Text(warehouse.name),
          subtitle: Text(warehouse.address),
          onTap: () => close(context, warehouse),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = warehouses
        .where((w) =>
            w.name.toLowerCase().contains(query.toLowerCase()) ||
            w.address.toLowerCase().contains(query.toLowerCase()))
        .toList();
    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final warehouse = suggestions[index];
        return ListTile(
          title: Text(warehouse.name),
          subtitle: Text(warehouse.address),
          onTap: () => close(context, warehouse),
        );
      },
    );
  }
}
