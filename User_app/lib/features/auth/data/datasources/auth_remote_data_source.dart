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
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl({required this.dio});

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
