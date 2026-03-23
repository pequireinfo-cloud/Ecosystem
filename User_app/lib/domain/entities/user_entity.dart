import 'package:equatable/equatable.dart';
import 'login_role.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final LoginRole role;

  const UserEntity({
    required this.id,
    required this.email,
    required this.role,
  });

  @override
  List<Object?> get props => [id, email, role];
}
