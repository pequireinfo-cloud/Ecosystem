import 'package:dio/dio.dart';
import '../models/auth_model.dart';
import '../../domain/entities/login_role.dart';
import 'package:flutter/foundation.dart';

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

  Future<AuthModel> verifyOtp({
    required String idToken,
    required String role,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl({required this.dio});

  // Base URL for API (Using local IP for Android connectivity)
  static const String baseUrl = 'http://10.46.122.48:4000/api';

  @override
  Future<AuthModel> verifyOtp({
    required String idToken,
    required String role,
  }) async {
    final response = await dio.post(
      '$baseUrl/auth/user/verify-otp',
      data: {
        'idToken': idToken,
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
  Future<AuthModel> login({
    required String email,
    required String password,
    required LoginRole role,
  }) async {
    // Mocking an API call
    await Future.delayed(const Duration(seconds: 1));

    // For mocking, we just succeed if email doesn't contain "error"
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
    // Mocking an API call for registration
    await Future.delayed(const Duration(seconds: 1));

    // For mocking, we just succeed if email doesn't contain "error"
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
    // Mocking an API call to update user location
    await Future.delayed(const Duration(milliseconds: 500));
    debugPrint("Location updated for $userId to $address ($lat, $lng)");
  }
}
