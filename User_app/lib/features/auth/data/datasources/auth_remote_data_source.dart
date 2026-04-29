import 'package:dio/dio.dart';
import '../models/auth_model.dart';
import '../../domain/entities/login_role.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/config/api_config.dart';

abstract class AuthRemoteDataSource {
  Future<AuthModel> login({
    required String email,
    required String password,
    required LoginRole role,
  });

  Future<AuthModel> register({
    required String email,
    required String password,
    required LoginRole role,
  });

  Future<void> updateUserLocation({
    required String userId,
    required double lat,
    required double lng,
    required String address,
  });

  Future<void> sendWhatsAppOtp({
    required String phoneNumber,
  });

  Future<AuthModel> verifyWhatsAppOtp({
    required String phoneNumber,
    required String otp,
    required String role,
  });

  Future<AuthModel> verifyDescope({
    required String token,
    required String role,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl({required this.dio});

  // Using centralized ApiConfig
  static const String baseUrl = ApiConfig.baseUrl;

  @override
  Future<void> sendWhatsAppOtp({
    required String phoneNumber,
  }) async {
    await dio.post(
      '$baseUrl/auth/user/send-whatsapp-otp',
      options: Options(headers: ApiConfig.headers),
      data: {
        'phoneNumber': phoneNumber,
      },
    );
  }

  @override
  Future<AuthModel> verifyWhatsAppOtp({
    required String phoneNumber,
    required String otp,
    required String role,
  }) async {
    final response = await dio.post(
      '$baseUrl/auth/user/verify-whatsapp-otp',
      options: Options(headers: ApiConfig.headers),
      data: {
        'phoneNumber': phoneNumber,
        'otp': otp,
        'role': role,
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return AuthModel.fromJson(response.data['user']);
    } else {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
      );
    }
  }

  @override
  Future<AuthModel> verifyDescope({
    required String token,
    required String role,
  }) async {
    try {
      debugPrint('AUTH_REMOTE: Verifying Descope token with backend...');
      debugPrint('AUTH_REMOTE: URL: $baseUrl/auth/user/verify-descope');
      
      final response = await dio.post(
        '$baseUrl/auth/user/verify-descope',
        options: Options(headers: ApiConfig.headers),
        data: {
          'sessionToken': token,
          'role': role,
        },
      ).timeout(const Duration(seconds: 10));

      debugPrint('AUTH_REMOTE: Backend Response: ${response.statusCode}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return AuthModel.fromJson(response.data['user']);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
        );
      }
    } catch (e) {
      debugPrint('AUTH_REMOTE: Verification Failed: $e');
      if (e is DioException) {
        debugPrint('AUTH_REMOTE: Dio Error Type: ${e.type}');
        debugPrint('AUTH_REMOTE: Dio Error Msg: ${e.message}');
      }
      rethrow;
    }
  }

  @override
  Future<AuthModel> login({
    required String email,
    required String password,
    required LoginRole role,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    if (!email.contains('error')) {
      return AuthModel(
        id: '1',
        email: email,
        role: role,
      );
    } else {
      throw DioException(
        requestOptions: RequestOptions(path: '/login'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/login'),
          statusCode: 401,
          data: {'message': 'Invalid credentials'},
        ),
      );
    }
  }

  @override
  Future<AuthModel> register({
    required String email,
    required String password,
    required LoginRole role,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    if (!email.contains('error')) {
      return AuthModel(
        id: '2',
        email: email,
        role: role,
      );
    } else {
      throw DioException(
        requestOptions: RequestOptions(path: '/register'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/register'),
          statusCode: 400,
          data: {'message': 'Registration failed: User already exists'},
        ),
      );
    }
  }

  @override
  Future<void> updateUserLocation({
    required String userId,
    required double lat,
    required double lng,
    required String address,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    debugPrint("Location updated for $userId to $address ($lat, $lng)");
  }
}
