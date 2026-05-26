import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';

final notificationsProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('auth_token');
  if (token == null) throw Exception('Unauthenticated');

  final dio = Dio(BaseOptions(baseUrl: 'http://10.0.2.2:5000/api'));
  
  final response = await dio.get(
    '/notifications',
    options: Options(headers: {'Authorization': 'Bearer $token'}),
  );
  
  if (response.statusCode == 200) {
    return response.data['data'] ?? [];
  } else {
    throw Exception('Failed to load notifications');
  }
});

final markNotificationReadProvider = Provider((ref) {
  return (String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) return;

      final dio = Dio(BaseOptions(baseUrl: 'http://10.0.2.2:5000/api'));
      await dio.put(
        '/notifications/$id/read',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      
      // Invalidate the list to trigger a refetch
      ref.invalidate(notificationsProvider);
    } catch (e) {
      print('Mark read failed: $e');
    }
  };
});
