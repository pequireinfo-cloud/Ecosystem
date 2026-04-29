import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:pequire_user_app/core/error/failure.dart';
import 'package:pequire_user_app/features/auth/domain/entities/user_entity.dart';
import 'package:pequire_user_app/features/auth/domain/repositories/auth_repository.dart';

class VerifyWhatsAppUseCase {
  final AuthRepository repository;

  VerifyWhatsAppUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call(VerifyWhatsAppParams params) async {
    return await repository.verifyWhatsAppWithBackend(
      token: params.token,
      role: params.role,
    );
  }
}

class VerifyWhatsAppParams extends Equatable {
  final String token;
  final String role;

  const VerifyWhatsAppParams({required this.token, required this.role});

  @override
  List<Object?> get props => [token, role];
}
