import 'package:pequire_user_app/core/services/api_service.dart';

class BookingService {
  Future<String?> createBooking({
    required String userId,
    required String serviceType,
    required double lat,
    required double lng,
    required String address,
    required double estimatedPrice,
    List<String> imageUrls = const [],
    bool isWaitAndSave = false,
  }) async {
    try {
      final response = await ApiService().post('/bookings', data: {
        'userId': userId,
        'serviceType': serviceType,
        'location': {
          'latitude': lat,
          'longitude': lng,
          'address': address
        },
        'estimatedPrice': estimatedPrice,
      });

      if (response.statusCode == 201) {
        return response.data['booking']['_id'] as String;
      }
      return null;
    } catch (e) {
      print('Error creating booking: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getBooking(String bookingId) async {
    try {
      final response = await ApiService().get('/bookings/$bookingId');
      return response.data;
    } catch (e) {
      print('Error fetching booking: $e');
      return null;
    }
  }

  Future<void> approveDiagnosis(String bookingId) async {
    try {
      await ApiService().post('/bookings/$bookingId/approve-diagnosis');
    } catch (e) {
      print('Error approving diagnosis: $e');
    }
  }

  Future<void> submitFeedback({
    required String bookingId,
    required int rating,
    required String feedback,
  }) async {
    try {
      await ApiService().post('/bookings/$bookingId/feedback', data: {
        'rating': rating,
        'feedback': feedback,
      });
    } catch (e) {
      print('Error submitting feedback: $e');
    }
  }

  /// Watch booking status via polling as a bridge from Firestore
  Stream<Map<String, dynamic>> watchBooking(String bookingId) async* {
    while (true) {
      final data = await getBooking(bookingId);
      if (data != null) yield data;
      await Future.delayed(const Duration(seconds: 3));
    }
  }
}
