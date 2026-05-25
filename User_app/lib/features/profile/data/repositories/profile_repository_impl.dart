import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/error/failure.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../datasources/profile_remote_data_source.dart';
import '../../domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, UserEntity>> getProfile() async {
    try {
      final profile = await remoteDataSource.getProfile();
      return Right(profile);
    } on DioException catch (e) {
      String message = 'Failed to fetch profile';
      if (e.response?.data is Map<String, dynamic> && e.response?.data['message'] != null) {
        message = e.response?.data['message'];
      } else if (e.response?.data is String) {
        message = e.response?.data;
      }
      return Left(ServerFailure(message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> updateProfile(Map<String, dynamic> profileData) async {
    try {
      final profile = await remoteDataSource.updateProfile(profileData);
      return Right(profile);
    } on DioException catch (e) {
      return Left(ServerFailure(e.response?.data['message'] ?? 'Failed to update profile'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updatePreferences(Map<String, dynamic> preferences) async {
    try {
      await remoteDataSource.updatePreferences(preferences);
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(e.response?.data['message'] ?? 'Failed to update preferences'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
