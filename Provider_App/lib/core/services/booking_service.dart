import 'package:pequire_provider_app/core/services/api_service.dart';

class BookingService {
  static final BookingService _instance = BookingService._internal();
  factory BookingService() => _instance;
  BookingService._internal();

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
}
