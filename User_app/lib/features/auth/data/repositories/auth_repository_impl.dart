import 'package:dartz/dartz.dart';
import 'package:pequire_user_app/core/error/failure.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../../domain/entities/login_role.dart';
import 'package:dio/dio.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

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
}
