import 'package:equatable/equatable.dart';
import 'login_role.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final LoginRole role;
  final double? lastLat;
  final double? lastLng;
  final String? lastAddress;

  const UserEntity({
    required this.id,
    required this.email,
    required this.role,
    this.lastLat,
    this.lastLng,
    this.lastAddress,
  });

  @override
  List<Object?> get props => [id, email, role, lastLat, lastLng, lastAddress];
}
