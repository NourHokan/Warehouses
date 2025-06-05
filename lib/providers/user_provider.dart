import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class UserProvider with ChangeNotifier {
  User? _currentUser;
  bool _isAdmin = false;

  User? get currentUser => _currentUser;
  bool get isAdmin => _isAdmin;

  // قائمة البريد الإلكتروني المسموح لهم بالصلاحيات
  static const List<String> allowedEmails = [
    'nourhokan001@gmail.com',
    'admin@gmail.com',
    'admin1@gmail.com',
    'admin12@gmail.com',
    'admin123@gmail.com',
    'admin1234@gmail.com',
  ];

  // تسجيل الدخول
  void login(User user) {
    _currentUser = user;
    _isAdmin = allowedEmails.contains(user.email);
    notifyListeners();
  }

  // تسجيل الخروج
  void logout() {
    _currentUser = null;
    _isAdmin = false;
    notifyListeners();
  }

  void setAdmin(bool value) {
    _isAdmin = value;
    notifyListeners();
  }

  // التحقق من الصلاحيات
  bool canManageWarehouses() => _isAdmin;
  bool canManageProducts() => _isAdmin;
  bool canManageCompanies() => _isAdmin;
  bool canManageMedicines() => _isAdmin;
  bool canChat() => true;
  bool canOrder() => true;

  // تحقق من الصلاحية بناءً على البريد فقط
  bool isAuthorizedByEmail() {
    if (_currentUser != null) {
      return allowedEmails.contains(_currentUser!.email);
    }
    return false;
  }

  // تحميل المستخدم من SharedPreferences عند بدء التطبيق (اختياري)
  Future<void> loadUserFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('user_email');
    final name = prefs.getString('user_name') ?? '';
    if (email != null) {
      login(User(id: email, name: name, email: email, phone: '', role: UserRole.user));
    }
  }
}