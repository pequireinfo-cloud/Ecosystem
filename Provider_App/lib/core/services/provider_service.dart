import 'package:pequire_provider_app/core/services/api_service.dart';

class ProviderService {
  static final ProviderService _instance = ProviderService._internal();
  factory ProviderService() => _instance;
  ProviderService._internal();

  Future<Map<String, dynamic>?> getProfile(String providerId) async {
    try {
      final response = await ApiService().get('/providers');
      final List data = response.data;
      final provider = data.firstWhere((p) => p['_id'] == providerId, orElse: () => null);
      return provider != null ? Map<String, dynamic>.from(provider) : null;
    } catch (e) {
      print('Error fetching provider profile: $e');
      return null;
    }
  }

  Future<bool> updateKyc(String providerId, Map<String, dynamic> kycData) async {
    try {
      await ApiService().put('/providers/$providerId/kyc', data: kycData);
      return true;
    } catch (e) {
      print('Error updating KYC: $e');
      return false;
    }
  }

  Future<bool> updateProfile(String providerId, Map<String, dynamic> updateData) async {
    try {
      await ApiService().put('/providers/$providerId', data: updateData);
      return true;
    } catch (e) {
      print('Error updating profile: $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getReviews(String providerId) async {
    try {
      final response = await ApiService().get('/providers/$providerId/reviews');
      final List data = response.data;
      return data.cast<Map<String, dynamic>>();
    } catch (e) {
      print('Error fetching reviews: $e');
      return [];
    }
  }
}
