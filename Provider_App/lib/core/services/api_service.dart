import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/api_config.dart';

class ApiService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: ApiConfig.baseUrl.endsWith('/') ? ApiConfig.baseUrl : '${ApiConfig.baseUrl}/',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: ApiConfig.headers,
  ));

  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String _normalizePath(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    if (path.startsWith('/')) {
      return path.substring(1);
    }
    return path;
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.get(_normalizePath(path), queryParameters: queryParameters);
    } on DioException catch (e) {
      debugPrint('API GET Error: ${e.message}');
      rethrow;
    }
  }

  Future<Response> post(String path, {dynamic data}) async {
    path = _normalizePath(path);
    try {
      return await _dio.post(path, data: data);
    } on DioException catch (e) {
      debugPrint('API POST Error: ${e.message}');
      rethrow;
    }
  }

  Future<Response> put(String path, {dynamic data}) async {
    path = _normalizePath(path);
    try {
      return await _dio.put(path, data: data);
    } on DioException catch (e) {
      debugPrint('API PUT Error: ${e.message}');
      rethrow;
    }
  }

  Future<String> uploadFile(String filePath) async {
    try {
      final fileName = filePath.split(RegExp(r'[/\\]')).last;
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          filePath,
          filename: fileName,
        ),
      });

      final response = await _dio.post(
        'upload',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      if (response.data != null && response.data['success'] == true) {
        return response.data['url'] as String;
      } else {
        throw Exception(response.data?['error'] ?? 'File upload failed');
      }
    } on DioException catch (e) {
      debugPrint('API File Upload Error: ${e.message}');
      final err = e.response?.data?['error'] ?? e.message ?? 'File upload failed';
      throw Exception(err);
    }
  }
}
