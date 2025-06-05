import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/medicine.dart'; // استيراد نموذج الدواء الرئيسي
import '../models/warehouse.dart'; // إضافة استيراد نموذج المستودع
import '../providers/data_provider.dart'; // استيراد مزود البيانات

class MedicinesScreen extends StatefulWidget {
  final String userEmail;
  final String warehouseEmail;
  final List<Medicine> medicines;
  final Warehouse warehouse; // إضافة المستودع كمعامل

  const MedicinesScreen({
    super.key,
    required this.userEmail,
    required this.warehouseEmail,
    required this.medicines,
    required this.warehouse, // إضافة المستودع كمعامل مطلوب
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
        backgroundColor: Colors.green[700],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              value: selectedType,
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
                  child: Text(type),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredMedicines.length,
              itemBuilder: (context, index) {
                final medicine = filteredMedicines[index];
                final whatsappNumber = widget.warehouse.whatsappNumber;

                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    title: Container(
                      width: double.infinity,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(
                          medicine.arabicName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          medicine.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 14),
                        ),
                        Text(
                          'السعر: \$${medicine.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.green[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    isThreeLine: false,
                    trailing: isOwner
                        ? IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              // صفحة تعديل الدواء هنا
                            },
                          )
                        : PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'whatsapp') {
                                if (whatsappNumber != null &&
                                    whatsappNumber.isNotEmpty) {
                                  _launchWhatsApp(whatsappNumber,
                                      message:
                                          "مرحباً، أود الاستفسار عن المنتج: ${medicine.arabicName}");
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            "لا يوجد رقم واتساب متاح للمستودع")),
                                  );
                                }
                              } else if (value == 'cart') {
                                _addToCart(medicine);
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'cart',
                                child: Row(
                                  children: [
                                    Icon(Icons.shopping_cart,
                                        color: Colors.green),
                                    SizedBox(width: 8),
                                    Text('إضافة إلى السلة'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'whatsapp',
                                child: Row(
                                  children: [
                                    Icon(Icons.chat, color: Colors.green),
                                    SizedBox(width: 8),
                                    Text('تواصل عبر واتساب'),
                                  ],
                                ),
                              ),
                            ],
                            icon: const Icon(Icons.more_vert),
                          ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _launchWhatsApp(String whatsappNumber, {String? message}) async {
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

  void _addToCart(Medicine medicine) {
    // تنفيذ وهمي لإضافة المنتج إلى السلة
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("تمت إضافة ${medicine.arabicName} إلى السلة!")),
    );
  }
}
