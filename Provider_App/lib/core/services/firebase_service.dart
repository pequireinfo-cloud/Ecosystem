import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:pequire_provider_app/firebase_options.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  FirebaseAuth get auth => FirebaseAuth.instance;
  FirebaseFirestore get firestore => FirebaseFirestore.instance;

  Future<void> initialize() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      
      // Set persistence and other configs if needed
      firestore.settings = const Settings(persistenceEnabled: true);
      debugPrint("Firebase initialized successfully");
    } catch (e) {
      debugPrint("Firebase initialization failed: $e");
    }
  }

  // Placeholder for OTP verification
  Future<void> verifyPhoneNumber(String phoneNumber, Function(String) onCodeSent) async {
    // Implementation for real phone auth
    // For now, we'll keep the UI flow logic but hook into this soon
  }
}
