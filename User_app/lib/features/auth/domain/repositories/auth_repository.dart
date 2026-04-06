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
}
