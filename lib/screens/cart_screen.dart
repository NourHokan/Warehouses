import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../models/cart.dart';

import '../providers/data_provider.dart';
import '../providers/user_provider.dart';
import '../theme/app_colors.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _isLoading = false;

  String _formatPrice(double price) {
    return price.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  Future<void> _launchWhatsApp(String phoneNumber, String message) async {
    try {
      // تنظيف رقم الهاتف من أي رموز غير ضرورية
      String cleanNumber = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
      // إزالة الرمز + إذا كان موجوداً
      if (cleanNumber.startsWith('+')) {
        cleanNumber = cleanNumber.substring(1);
      }

      // محاولة فتح تطبيق الواتساب مباشرة
      final whatsappUrl =
          'whatsapp://send?phone=$cleanNumber&text=${Uri.encodeComponent(message)}';

      if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
        await launchUrl(Uri.parse(whatsappUrl),
            mode: LaunchMode.externalApplication);
      } else {
        // إذا فشل فتح التطبيق، نستخدم الرابط البديل
        final webUrl =
            'https://wa.me/$cleanNumber?text=${Uri.encodeComponent(message)}';
        if (await canLaunchUrl(Uri.parse(webUrl))) {
          await launchUrl(Uri.parse(webUrl),
              mode: LaunchMode.externalApplication);
        } else {
          throw 'لا يمكن فتح WhatsApp';
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatWhatsAppMessage(List<CartItem> items, double totalPrice) {
    final itemsList = items
        .map((item) =>
            '- ${item.medicine.arabicName} (${item.quantity} قطعة) - ${_formatPrice(item.medicine.price * item.quantity)} ل.س')
        .join('\n');

    return '''
مرحباً، أود طلب الأدوية التالية:

$itemsList

المجموع: ${_formatPrice(totalPrice)} ل.س

شكراً لكم
''';
  }

  Future<void> _showDeleteConfirmation(BuildContext context,
      String medicineName, String userId, String medicineId) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف $medicineName من السلة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      final dataProvider = Provider.of<DataProvider>(context, listen: false);
      dataProvider.removeFromCart(userId, medicineId);
    }
  }

  Future<bool> _showOrderConfirmation(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الطلب'),
        content: const Text(
            'هل أنت متأكد من إتمام الطلب؟ سيتم إرسال الطلب عبر WhatsApp.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('تأكيد',
                style: TextStyle(color: AppColors.primaryGreen)),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  void _updateCartItemQuantity(
      String userId, String medicineId, int newQuantity) {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    if (newQuantity <= 0) {
      dataProvider.removeFromCart(userId, medicineId);
    } else {
      // إزالة العنصر الحالي وإضافته مرة أخرى بالكمية الجديدة
      dataProvider.removeFromCart(userId, medicineId);
      final cart = dataProvider.getUserCart(userId);
      final item = cart.items.firstWhere(
        (item) => item.medicine.id == medicineId,
        orElse: () => throw 'لم يتم العثور على الدواء',
      );
      for (var i = 0; i < newQuantity; i++) {
        dataProvider.addToCart(userId, item.medicine);
      }
    }
  }

  Future<void> _confirmAndSendOrder(BuildContext context, Cart cart) async {
    if (cart.items.isEmpty) return;

    final confirmed = await _showOrderConfirmation(context);
    if (!confirmed) return;

    setState(() => _isLoading = true);

    try {
      final dataProvider = Provider.of<DataProvider>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      final warehouse = dataProvider.warehouses.firstWhere(
        (w) => w.id == cart.items.first.medicine.warehouseId,
        orElse: () => throw 'لم يتم العثور على المستودع',
      );

      final message = _formatWhatsAppMessage(cart.items, cart.totalPrice);
      await _launchWhatsApp(warehouse.whatsappNumber, message);

      dataProvider.clearCart(userProvider.currentUser!.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إرسال الطلب بنجاح'),
            backgroundColor: AppColors.primaryGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final dataProvider = Provider.of<DataProvider>(context);
    final cart = dataProvider.getUserCart(userProvider.currentUser!.id);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'سلة المشتريات',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
          ),
        ),
        backgroundColor: AppColors.primaryGreen,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryGreen,
              ),
            )
          : cart.items.isEmpty
              ? const Center(
                  child: Text(
                    'السلة فارغة',
                    style:
                        TextStyle(fontSize: 18, color: AppColors.textSecondary),
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: cart.items.length,
                        itemBuilder: (context, index) {
                          final item = cart.items[index];
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
                                      color: AppColors.primaryGreen
                                          .withOpacity(0.1),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.medicine.arabicName,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'السعر: ${_formatPrice(item.medicine.price)} ل.س',
                                          style: const TextStyle(
                                            fontSize: 13, // أصغر من السابق
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            IconButton(
                                              icon: const Icon(
                                                  Icons.remove_circle_outline,
                                                  size: 18),
                                              onPressed: () {
                                                _updateCartItemQuantity(
                                                  userProvider.currentUser!.id,
                                                  item.medicine.id,
                                                  item.quantity - 1,
                                                );
                                              },
                                            ),
                                            Text(
                                              '${item.quantity}',
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                  Icons.add_circle_outline,
                                                  size: 18),
                                              onPressed: () {
                                                _updateCartItemQuantity(
                                                  userProvider.currentUser!.id,
                                                  item.medicine.id,
                                                  item.quantity + 1,
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  // قائمة ثلاث نقاط مع حذف وتعديل وزر واتساب صغير
                                  Column(
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          PopupMenuButton<String>(
                                            icon: const Icon(Icons.more_vert,
                                                size: 22),
                                            onSelected: (value) {
                                              if (value == 'delete') {
                                                _showDeleteConfirmation(
                                                  context,
                                                  item.medicine.arabicName,
                                                  userProvider.currentUser!.id,
                                                  item.medicine.id,
                                                );
                                              } else if (value == 'edit') {
                                                // منطق التعديل (يمكنك إضافة نافذة تعديل)
                                              }
                                            },
                                            itemBuilder: (context) => [
                                              const PopupMenuItem(
                                                value: 'edit',
                                                child: Text('تعديل'),
                                              ),
                                              const PopupMenuItem(
                                                value: 'delete',
                                                child: Text('حذف',
                                                    style: TextStyle(
                                                        color: Colors.red)),
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
                                              final dataProvider =
                                                  Provider.of<DataProvider>(
                                                      context,
                                                      listen: false);
                                              final warehouse = dataProvider
                                                  .warehouses
                                                  .firstWhere(
                                                (w) => w.id == item.medicine.warehouseId,
                                                orElse: () => throw 'لم يتم العثور على المستودع',
                                              );
                                              final message = _formatWhatsAppMessage(
                                                  [item],
                                                  item.medicine.price *
                                                      item.quantity);
                                              await _launchWhatsApp(
                                                  warehouse.whatsappNumber,
                                                  message);
                                            },
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
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, -5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'المجموع:',
                                style: TextStyle(
                                  fontSize: 15, // أصغر من السابق
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${_formatPrice(cart.totalPrice)} ل.س',
                                style: TextStyle(
                                  fontSize: 15, // أصغر من السابق
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryGreen,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () =>
                                _confirmAndSendOrder(context, cart),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryGreen,
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            child: const Text(
                              'تأكيد الطلب',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}
