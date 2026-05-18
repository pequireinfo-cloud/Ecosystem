import 'package:pequire_provider_app/core/services/api_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BookingService {
  static final BookingService _instance = BookingService._internal();
  factory BookingService() => _instance;
  BookingService._internal();

  /// Listen for new bookings using Firestore
  Stream<QuerySnapshot> listenForBookings() {
    return FirebaseFirestore.instance
        .collection('bookings')
        .where('status', isEqualTo: 'pending')
        .snapshots();
  }

  /// Fetch pending bookings for the professional
  Future<List<Map<String, dynamic>>> getPendingBookings() async {
    try {
      final response = await ApiService().get('/bookings');
      final List data = response.data;
      // Filter the list for pending bookings
      return data.cast<Map<String, dynamic>>().where((b) => b['status'] == 'pending').toList();
    } catch (e) {
      print('Error fetching bookings: $e');
      return [];
    }
  }

  /// Accept a booking request
  Future<void> acceptBooking(String bookingId, String providerId) async {
    try {
      await ApiService().put('/bookings/$bookingId/accept', data: {
        'providerId': providerId,
      });
    } catch (e) {
      print('Error accepting booking: $e');
      rethrow;
    }
  }

  /// Verify the Arrival OTP from the user
  Future<void> verifyArrivalOtp(String bookingId, String otp) async {
    try {
      await ApiService().post('/bookings/$bookingId/verify-arrival', data: {
        'otp': otp,
      });
    } catch (e) {
      print('Error verifying arrival OTP: $e');
      rethrow;
    }
  }

  /// Submit diagnosis and final price
  Future<void> submitDiagnosis({
    required String bookingId,
    required String appliance,
    required String problem,
    required String solution,
    required double price,
  }) async {
    try {
      await ApiService().post('/bookings/$bookingId/diagnosis', data: {
        'appliance': appliance,
        'problem': problem,
        'solution': solution,
        'price': price,
      });
    } catch (e) {
      print('Error submitting diagnosis: $e');
      rethrow;
    }
  }

  /// Verify the Work Completion OTP from the user
  Future<void> verifyWorkOtp(String bookingId, String otp) async {
    try {
      await ApiService().post('/bookings/$bookingId/verify-work', data: {
        'otp': otp,
      });
    } catch (e) {
      print('Error verifying work OTP: $e');
      rethrow;
    }
  }

  /// Confirm Cash Payment Received
  Future<void> confirmOfflinePayment(String bookingId) async {
    try {
      await ApiService().post('/bookings/$bookingId/confirm-offline-payment');
    } catch (e) {
      print('Error confirming offline payment: $e');
      rethrow;
    }
  }

  /// Submit feedback for the user (customer)
  Future<void> submitUserFeedback({
    required String bookingId,
    required int rating,
    required String feedback,
  }) async {
    try {
      await ApiService().post('/bookings/$bookingId/user-feedback', data: {
        'rating': rating,
        'feedback': feedback,
      });
    } catch (e) {
      print('Error submitting user feedback: $e');
      rethrow;
    }
  }
}
