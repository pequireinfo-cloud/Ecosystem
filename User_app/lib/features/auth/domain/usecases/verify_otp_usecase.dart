import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:pequire_user_app/core/error/failure.dart';
import 'package:pequire_user_app/features/auth/domain/entities/user_entity.dart';
import 'package:pequire_user_app/features/auth/domain/repositories/auth_repository.dart';

class VerifyOtpUseCase {
  final AuthRepository repository;

  VerifyOtpUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call(VerifyOtpParams params) async {
    return await repository.verifyDescope(
      token: params.idToken,
      role: params.role,
    );
  }
}

class VerifyOtpParams extends Equatable {
  final String idToken;
  final String role;

  const VerifyOtpParams({required this.idToken, required this.role});

  @override
  List<Object?> get props => [idToken, role];
}
