enum UserRole {
  admin, // مشرف النظام
  warehouseOwner, // صاحب مستودع
  user // مستخدم عادي
}

class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final UserRole role;
  final String? warehouseId; // معرف المستودع إذا كان صاحب مستودع
  final List<String>
      allowedEmails; // قائمة البريد الإلكتروني المسموح لهم بالوصول

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.warehouseId,
    this.allowedEmails = const [],
  });

  // التحقق من الصلاحيات
  bool canManageWarehouse(String warehouseId) {
    if (role == UserRole.admin) return true;
    if (role == UserRole.warehouseOwner && this.warehouseId == warehouseId)
      return true;
    return false;
  }

  bool canManageMedicines(String warehouseId) {
    return canManageWarehouse(warehouseId);
  }

  bool canManageCompanies() {
    return role == UserRole.admin;
  }

  bool canChat() => true; // جميع المستخدمين يمكنهم التواصل
  bool canOrder() => true; // جميع المستخدمين يمكنهم الطلب

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    UserRole? role,
    String? warehouseId,
    List<String>? allowedEmails,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      warehouseId: warehouseId ?? this.warehouseId,
      allowedEmails: allowedEmails ?? this.allowedEmails,
    );
  }
}
