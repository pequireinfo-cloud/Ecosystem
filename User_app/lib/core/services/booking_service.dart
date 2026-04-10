import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_service.dart';

class BookingService {
  final FirebaseFirestore _firestore = FirebaseService().firestore;

  Future<String> createBooking({
    required String userId,
    required String serviceType,
    required double lat,
    required double lng,
    required String address,
    required double estimatedPrice,
    List<String> imageUrls = const [],
    bool isWaitAndSave = false,
  }) async {
    final bookingRef = _firestore.collection('bookings').doc();
    
    await bookingRef.set({
      'id': bookingRef.id,
      'userId': userId,
      'serviceType': serviceType,
      'status': 'pending',
      'location': GeoPoint(lat, lng),
      'address': address,
      'imageUrls': imageUrls,
      'estimatedPrice': estimatedPrice,
      'isWaitAndSave': isWaitAndSave,
      'createdAt': FieldValue.serverTimestamp(),
      'providerId': null,
    });

    return bookingRef.id;
  }

  Stream<DocumentSnapshot> watchBooking(String bookingId) {
    return _firestore.collection('bookings').doc(bookingId).snapshots();
  }

  Future<void> updateBookingStatus(String bookingId, String status) async {
    await _firestore.collection('bookings').doc(bookingId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> submitDiagnosis({
    required String bookingId,
    required String applianceDetails,
    required String problemDescription,
    required double finalPrice,
  }) async {
    await _firestore.collection('bookings').doc(bookingId).update({
      'status': 'waiting_approval',
      'diagnosis': {
        'appliance': applianceDetails,
        'problem': problemDescription,
      },
      'finalPrice': finalPrice,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> approvePrice(String bookingId) async {
    await _firestore.collection('bookings').doc(bookingId).update({
      'status': 'working',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
