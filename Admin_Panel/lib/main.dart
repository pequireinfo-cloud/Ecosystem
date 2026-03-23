import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pequire_admin_panel/firebase_options.dart';
import 'package:pequire_admin_panel/features/auth/screens/admin_login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: PequireAdminApp()));
}

class PequireAdminApp extends StatelessWidget {
  const PequireAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pequire Admin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF025EF3),
          primary: const Color(0xFF025EF3),
          secondary: const Color(0xFF0F172A),
        ),
        textTheme: GoogleFonts.interTextTheme(),
      ),
      home: const AdminLoginScreen(),
    );
  }
}
