import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../providers/user_provider.dart';
import 'login_screen.dart';
import 'welcome_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});
  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  String? userEmail;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userEmail = prefs.getString('user_email');
      loading = false;
    });
    // تحميل المستخدم في UserProvider
    if (userEmail != null) {
      final name = prefs.getString('user_name') ?? '';
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.login(
        User(id: userEmail!, name: name, email: userEmail!, phone: '', role: UserRole.user),
      );
    }
  }

  void _onLoginSuccess() {
    _checkLogin();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    if (userEmail == null) {
      return LoginScreen(onLoginSuccess: _onLoginSuccess);
    }
    return const WelcomeScreen();
  }
}
