import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pequire_provider_app/firebase_options.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> initialize() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    // Set persistence and other configs if needed
    _firestore.settings = const Settings(persistenceEnabled: true);
  }

  FirebaseAuth get auth => _auth;
  FirebaseFirestore get firestore => _firestore;

  // Placeholder for OTP verification
  Future<void> verifyPhoneNumber(String phoneNumber, Function(String) onCodeSent) async {
    // Implementation for real phone auth
    // For now, we'll keep the UI flow logic but hook into this soon
  }
}
