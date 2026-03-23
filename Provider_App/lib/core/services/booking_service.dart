import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_service.dart';

class BookingService {
  static final BookingService _instance = BookingService._internal();
  factory BookingService() => _instance;
  BookingService._internal();

  final _firestore = FirebaseService().firestore;
  final _auth = FirebaseService().auth;

  /// Listen for bookings searching for a provider
  Stream<QuerySnapshot> listenForBookings() {
    return _firestore
        .collection('bookings')
        .where('status', isEqualTo: 'pending')
        // In a real app, you'd filter by category and location
        .snapshots();
  }

  /// Accept a booking request
  Future<void> acceptBooking(String bookingId) async {
    final user = _auth.currentUser;
    // For demo/ecosystem check, we can allow even if user is null if we want to mock it
    // but better to use uid if available.
    final uid = user?.uid ?? 'temp_provider_456';

    await _firestore.collection('bookings').doc(bookingId).update({
      'providerId': uid,
      'status': 'accepted',
      'acceptedAt': FieldValue.serverTimestamp(),
    });
    
    // Also update provider status
    await _firestore.collection('providers').doc(uid).update({
      'activeBookingId': bookingId,
      'isAvailable': false,
    });
  }

  /// Update job progress with granular steps
  Future<void> updateJobProgress(String bookingId, String step) async {
    await _firestore.collection('bookings').doc(bookingId).update({
      'progress': step,
      'lastUpdatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Mark a booking as completed
  Future<void> completeBooking(String bookingId) async {
    final user = _auth.currentUser;
    final uid = user?.uid ?? 'temp_provider_456';

    await _firestore.collection('bookings').doc(bookingId).update({
      'status': 'completed',
      'completedAt': FieldValue.serverTimestamp(),
    });

    // Free up the provider
    await _firestore.collection('providers').doc(uid).update({
      'activeBookingId': null,
      'isAvailable': true,
    });
  }
}
