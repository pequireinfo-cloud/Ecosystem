import 'package:dartz/dartz.dart';
import 'package:pequire_user_app/core/error/failure.dart';
import '../entities/user_entity.dart';
import '../entities/login_role.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
    required LoginRole role,
  });

  Future<Either<Failure, UserEntity>> register({
    required String email,
    required String password,
    required LoginRole role,
  });

  Future<Either<Failure, void>> sendWhatsAppOtp({
    required String phoneNumber,
  });

  Future<Either<Failure, UserEntity>> verifyWhatsAppOtp({
    required String phoneNumber,
    required String otp,
    required String role,
  });

  Future<Either<Failure, UserEntity>> verifyDescope({
    required String token,
    required String role,
  });

  Future<Either<Failure, void>> updateUserLocation({
    required String userId,
    required double lat,
    required double lng,
    required String address,
  });

  Future<Either<Failure, UserEntity?>> getCachedUser();
  Future<String?> getToken();
  Future<void> logout();
}
