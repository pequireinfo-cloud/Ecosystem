import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_service.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseService().firestore;
  final FirebaseAuth _auth = FirebaseService().auth;

  /// Send a message in a specific booking
  Future<void> sendMessage(String bookingId, String text) async {
    final user = _auth.currentUser;
    final uid = user?.uid ?? 'temp_provider_456';

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
