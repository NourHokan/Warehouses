import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onLoginSuccess;
  const LoginScreen({required this.onLoginSuccess, Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final nameController = TextEditingController();
  bool isLoading = false;
  String? error;

  Future<void> login() async {
    setState(() { isLoading = true; error = null; });
    final email = emailController.text.trim();
    final name = nameController.text.trim();
    if (email.isEmpty || name.isEmpty) {
      setState(() { error = 'يرجى إدخال البريد الإلكتروني والاسم'; isLoading = false; });
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_email', email);
    await prefs.setString('user_name', name);
    widget.onLoginSuccess();
    setState(() { isLoading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('تسجيل الدخول'),
        backgroundColor: AppColors.primaryGreen,
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'البريد الإلكتروني',),
                textAlign: TextAlign.right,
              ),
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'الاسم',),
                textAlign: TextAlign.right,
              ),
              if (error != null) Text(error!, style: TextStyle(color: Colors.red)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: isLoading ? null : login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: isLoading ? const CircularProgressIndicator(color: Colors.white,) : const Text(
                  'دخول',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
