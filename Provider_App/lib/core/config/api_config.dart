import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:descope/descope.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';

class ApiConfig {
  // Production Backend URL
  static const String baseUrl = 'https://api.pequire.com/api/';
  
  // Descope Project ID
  static const String descopeProjectId = 'P3CyZF9IZxcIXXxhQ3fZLgWJmuy5';

  // State management (Session)
  static String? currentProviderId;
  
  // Shared Headers
  static Map<String, String> get headers => {
    'ngrok-skip-browser-warning': 'true',
    'Bypass-Tunnel-Reminder': 'true',
    'Content-Type': 'application/json',
  };

  // Common logout function
  static Future<void> logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (_) {}
    try {
      Descope.sessionManager.clearSession();
    } catch (_) {}
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_provider_id');
    await prefs.remove('kyc_status');
    currentProviderId = null;
    
    if (context.mounted) {
      context.go('/login');
    }
  }
}
