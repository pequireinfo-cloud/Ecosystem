import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class TrackingService {
  static final TrackingService _instance = TrackingService._internal();
  factory TrackingService() => _instance;
  TrackingService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Listens to live location updates for a specific order
  Stream<DocumentSnapshot<Map<String, dynamic>>> listenToLocation(String orderId) {
    debugPrint('Connecting to Firestore tracking for order: $orderId');
    return _firestore.collection('tracking').doc(orderId).snapshots();
  }

  /// Disconnect/Cleanup is not needed for Firestore snapshots as they are managed by the StreamSubscription
  void dispose() {
    // Optional cleanup
  }
}
