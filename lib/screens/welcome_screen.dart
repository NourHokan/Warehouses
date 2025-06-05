import 'package:flutter/material.dart';
import '../theme/app_colors.dart'; // تأكد من أن AppColors معرف بشكل صحيح
import 'governorates_screen.dart'; // تأكد من أن GovernoratesScreen موجودة

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, // تأكد من أن AppColors.background معرف
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // شعار التطبيق
              Container(
                width: 150,
                height: 150,
                decoration: const BoxDecoration(
                  color: AppColors.primaryGreen, // تأكد من أن AppColors.primaryGreen معرف
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.medical_services,
                  size: 80,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 40),
              // عنوان التطبيق
              const Text(
                'السوق الدواء السوري',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryGreen, // تأكد من أن AppColors.primaryGreen معرف
                ),
              ),
              const SizedBox(height: 20),
              // وصف التطبيق
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'منصة متكاملة لإدارة مستودعات الأدوية في سوريا',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: AppColors.textSecondary, // تأكد من أن AppColors.textSecondary معرف
                  ),
                ),
              ),
              const SizedBox(height: 60),
              // زر البدء
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/governorates');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen, // تأكد من أن AppColors.primaryGreen معرف
                  padding: const EdgeInsets.symmetric(
                    horizontal: 50,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'ابدأ الآن',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}