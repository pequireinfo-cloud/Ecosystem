import 'package:flutter/foundation.dart';
import 'package:dartz/dartz.dart';
import 'package:pequire_user_app/core/error/failure.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../../domain/entities/login_role.dart';
import 'package:dio/dio.dart';
import 'package:descope/descope.dart';

import '../datasources/auth_local_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  // ... (rest of the code will be updated in next steps)

  @override
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
    required LoginRole role,
  }) async {
    try {
      final authModel = await remoteDataSource.login(
        email: email,
        password: password,
        role: role,
      );
      return Right(authModel);
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Authentication failed';
      return Left(ServerFailure(message));
    } catch (e) {
      return const Left(ServerFailure('An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> register({
    required String email,
    required String password,
    required LoginRole role,
  }) async {
    try {
      final authModel = await remoteDataSource.register(
        email: email,
        password: password,
        role: role,
      );
      return Right(authModel);
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Registration failed';
      return Left(ServerFailure(message));
    } catch (e) {
      return const Left(ServerFailure('An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, void>> sendWhatsAppOtp({
    required String phoneNumber,
  }) async {
    try {
      debugPrint('AUTH_REPO: Attempting to send Text OTP to: $phoneNumber');
      debugPrint('AUTH_REPO: Using Project ID: ${Descope.projectId}');
      
      // Use Descope SDK directly to send OTP via SMS (Text)
      await Descope.otp.signUpOrIn(
        method: DeliveryMethod.sms,
        loginId: phoneNumber,
      );
      
      debugPrint('AUTH_REPO: Text OTP send request successful');
      return const Right(null);
    } catch (e) {
      debugPrint('AUTH_REPO: Text OTP Send ERROR: $e');
      return Left(ServerFailure('Text OTP Send Error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> verifyWhatsAppOtp({
    required String phoneNumber,
    required String otp,
    required String role,
  }) async {
    try {
      debugPrint('AUTH_REPO: Verifying Text OTP via Backend for: $phoneNumber');
      
      // We now call our backend directly to verify the OTP.
      // This satisfies the requirement that the backend MUST be the one verifying the code.
      final authModel = await remoteDataSource.verifyWhatsAppOtp(
        phoneNumber: phoneNumber,
        otp: otp,
        role: role,
      );
      
      debugPrint('AUTH_REPO: Backend verification successful');

      // Cache user for persistence
      await localDataSource.cacheUser(authModel);
      // Note: Backend verification returns our own JWT, which is handled in remoteDataSource.verifyWhatsAppOtp

      return Right(authModel);
    } catch (e) {
      debugPrint('AUTH_REPO: Backend OTP Verification ERROR: $e');
      return Left(ServerFailure('OTP Verification Error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> verifyDescope({
    required String token,
    required String role,
  }) async {
    try {
      final authModel = await remoteDataSource.verifyDescope(
        token: token,
        role: role,
      );
      return Right(authModel);
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Descope verification failed';
      return Left(ServerFailure(message));
    } catch (e) {
      return const Left(ServerFailure('An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, void>> updateUserLocation({
    required String userId,
    required double lat,
    required double lng,
    required String address,
  }) async {
    try {
      await remoteDataSource.updateUserLocation(
        userId: userId,
        lat: lat,
        lng: lng,
        address: address,
      );
      return const Right(null);
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Failed to update location';
      return Left(ServerFailure(message));
    } catch (e) {
      return const Left(ServerFailure('An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getCachedUser() async {
    try {
      final user = await localDataSource.getLastUser();
      return Right(user);
    } catch (e) {
      return const Left(CacheFailure('Failed to load cached user'));
    }
  }

  @override
  Future<String?> getToken() {
    return localDataSource.getToken();
  }

  @override
  Future<void> logout() async {
    await localDataSource.clearCache();
  }
}
