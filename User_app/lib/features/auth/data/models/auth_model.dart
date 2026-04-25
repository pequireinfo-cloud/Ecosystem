import '../../domain/entities/user_entity.dart';
import '../../domain/entities/login_role.dart';

class AuthModel extends UserEntity {
  const AuthModel({
    required super.id,
    required super.email,
    required super.role,
    super.phoneNumber,
    super.lastLat,
    super.lastLng,
    super.lastAddress,
  });

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    return AuthModel(
      id: json['id'] ?? json['_id'],
      email: json['email'] ?? '',
      role: _parseRole(json['role']),
      phoneNumber: json['phoneNumber'],
      lastLat: json['lastLat']?.toDouble(),
      lastLng: json['lastLng']?.toDouble(),
      lastAddress: json['lastAddress'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'role': role.toString().split('.').last,
      'phoneNumber': phoneNumber,
      'lastLat': lastLat,
      'lastLng': lastLng,
      'lastAddress': lastAddress,
    };
  }

  static LoginRole _parseRole(String role) {
    if (role == 'serviceProvider' || role == 'provider') {
      return LoginRole.serviceProvider;
    }
    return LoginRole.user;
  }
}
