import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'theme/app_colors.dart';
import 'providers/user_provider.dart';
import 'providers/data_provider.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/governorates_screen.dart';
import 'screens/warehouses_list_screen.dart';
// import 'screens/categories_screen.dart'; // لم نعد نستخدمها في routes
import 'screens/welcome_screen.dart';
import 'screens/auth_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://zkpwdpvqflnfkrwskdan.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InprcHdkcHZxZmxuZmtyd3NrZGFuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDk1NTgyOTgsImV4cCI6MjA2NTEzNDI5OH0.5xAECKxede723YdPsBWxV4sxwfX11BPkKEMccnNuMtY',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => DataProvider()),
      ],
      child: MaterialApp(
        title: 'سوق الأدوية السوري',
        theme: ThemeData(
          primarySwatch: Colors.green,
          textTheme: GoogleFonts.cairoTextTheme(),
          scaffoldBackgroundColor: AppColors.background,
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.primaryGreen,
            elevation: 0,
            centerTitle: true,
            titleTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          cardTheme: CardThemeData(
            color: AppColors.cardBackground,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primaryGreen,
            ),
          ),
        ),
        home: const AuthGate(),
        routes: {
          '/welcome': (context) => const WelcomeScreen(),
          '/governorates': (context) => GovernoratesScreen(),
          '/warehouses': (context) => WarehousesListScreen(),
          // '/categories': (context) => CategoriesScreen(warehouseId: ''), // حذف هذا المسار
        },
      ),
    );
  }
}
