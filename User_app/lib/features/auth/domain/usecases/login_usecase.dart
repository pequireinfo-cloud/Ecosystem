import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/error/failure.dart';
import '../../../core/util/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';
import '../entities/login_role.dart';

class LoginUseCase implements UseCase<UserEntity, LoginParams> {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(LoginParams params) async {
    return await repository.login(
      email: params.email,
      password: params.password,
      role: params.role,
    );
  }
}

class LoginParams extends Equatable {
  final String email;
  final String password;
  final LoginRole role;

  const LoginParams({
    required this.email,
    required this.password,
    required this.role,
  });

  @override
  List<Object?> get props => [email, password, role];
}
