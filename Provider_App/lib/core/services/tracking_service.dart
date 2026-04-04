import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class TrackingService {
  static final TrackingService _instance = TrackingService._internal();
  factory TrackingService() => _instance;
  TrackingService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Updates the live location for a specific order in Firestore
  Future<void> updateLocation({
    required String orderId,
    required double latitude,
    required double longitude,
    double heading = 0.0,
  }) async {
    try {
      await _firestore.collection('tracking').doc(orderId).set({
        'latitude': latitude,
        'longitude': longitude,
        'heading': heading,
        'lastUpdatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      
      debugPrint('Firestore location update sent for $orderId: $latitude, $longitude');
    } catch (e) {
      debugPrint('Failed to update location in Firestore: $e');
    }
  }

  /// Start tracking (replaces joinOrder)
  void startTracking(String orderId) {
    debugPrint('Provider started tracking for order: $orderId');
  }

  void dispose() {
    // Cleanup
  }
}
