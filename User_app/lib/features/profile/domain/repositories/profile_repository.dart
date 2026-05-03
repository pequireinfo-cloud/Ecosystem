import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../../auth/domain/entities/user_entity.dart';

abstract class ProfileRepository {
  Future<Either<Failure, UserEntity>> getProfile();
  Future<Either<Failure, UserEntity>> updateProfile(Map<String, dynamic> profileData);
  Future<Either<Failure, void>> updatePreferences(Map<String, dynamic> preferences);
}
