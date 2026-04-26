import 'package:equatable/equatable.dart';
import 'login_role.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final LoginRole role;
  final String? phoneNumber;
  final double? lastLat;
  final double? lastLng;
  final String? lastAddress;
  final int currentStreak;
  final int rewardPoints;

  const UserEntity({
    required this.id,
    required this.email,
    required this.role,
    this.phoneNumber,
    this.lastLat,
    this.lastLng,
    this.lastAddress,
    this.currentStreak = 0,
    this.rewardPoints = 0,
  });

  @override
  List<Object?> get props => [id, email, role, phoneNumber, lastLat, lastLng, lastAddress];
}
