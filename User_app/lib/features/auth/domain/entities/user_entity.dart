import 'package:equatable/equatable.dart';
import 'login_role.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final LoginRole role;
  final String? phoneNumber;
  final String? name;
  final String? nickname;
  final String? avatarUrl;
  final String? dob;
  final String? gender;
  final String? country;
  final double? lastLat;
  final double? lastLng;
  final String? lastAddress;
  final int currentStreak;
  final int rewardPoints;
  final Map<String, dynamic>? preferences;
  final List<Map<String, dynamic>>? coupons;

  const UserEntity({
    required this.id,
    required this.email,
    required this.role,
    this.phoneNumber,
    this.name,
    this.nickname,
    this.avatarUrl,
    this.dob,
    this.gender,
    this.country,
    this.lastLat,
    this.lastLng,
    this.lastAddress,
    this.currentStreak = 0,
    this.rewardPoints = 0,
    this.preferences,
    this.coupons,
  });

  @override
  List<Object?> get props => [id, email, role, phoneNumber, name, nickname, avatarUrl, dob, gender, country, lastLat, lastLng, lastAddress, currentStreak, rewardPoints, preferences, coupons];
}
