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
}
