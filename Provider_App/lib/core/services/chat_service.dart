import 'package:cloud_firestore/cloud_firestore.dart';
import '../config/api_config.dart';
import 'firebase_service.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseService().firestore;

  /// Send a message in a specific booking
  Future<void> sendMessage(String bookingId, String text) async {
    final uid = ApiConfig.currentProviderId ?? 'temp_provider_456';

    await _firestore
        .collection('bookings')
        .doc(bookingId)
        .collection('messages')
        .add({
      'senderId': uid,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
      'type': 'text',
    });

    // Update last message in booking doc
    await _firestore.collection('bookings').doc(bookingId).update({
      'lastMessage': text,
      'lastMessageAt': FieldValue.serverTimestamp(),
    });
  }

  /// Watch messages for a booking
  Stream<QuerySnapshot> watchMessages(String bookingId) {
    return _firestore
        .collection('bookings')
        .doc(bookingId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
}
