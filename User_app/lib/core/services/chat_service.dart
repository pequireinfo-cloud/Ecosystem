import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_service.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseService().firestore;

  /// Send a message in a specific booking
  Future<void> sendMessage(String bookingId, String senderId, String text) async {
    await _firestore
        .collection('bookings')
        .doc(bookingId)
        .collection('messages')
        .add({
      'senderId': senderId,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
      'type': 'text',
    });

    // Update last message in booking doc for preview
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
