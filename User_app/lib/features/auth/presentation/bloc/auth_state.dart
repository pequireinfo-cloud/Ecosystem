import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/login_role.dart';

// Events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class LoginSubmitted extends AuthEvent {
  final String email;
  final String password;
  final LoginRole role;

  const LoginSubmitted({
    required this.email,
    required this.password,
    required this.role,
  });

  @override
  List<Object?> get props => [email, password, role];
}

class RegisterSubmitted extends AuthEvent {
  final String name;
  final String email;
  final String password;
  final LoginRole role;

  const RegisterSubmitted({
    required this.name,
    required this.email,
    required this.password,
    required this.role,
  });

  @override
  List<Object?> get props => [name, email, password, role];
}

class SendOtp extends AuthEvent {
  final String phoneNumber;
  const SendOtp(this.phoneNumber);

  @override
  List<Object?> get props => [phoneNumber];
}

class VerifyOtp extends AuthEvent {
  final String verificationId;
  final String smsCode;
  final String role;
  const VerifyOtp({
    required this.verificationId,
    required this.smsCode,
    required this.role,
  });

  @override
  List<Object?> get props => [verificationId, smsCode, role];
}

// Internal events for Firebase callbacks
class AuthErrorInternal extends AuthEvent {
  final String message;
  const AuthErrorInternal(this.message);
  @override
  List<Object?> get props => [message];
}

class OtpSentInternal extends AuthEvent {
  final String verificationId;
  const OtpSentInternal(this.verificationId);
  @override
  List<Object?> get props => [verificationId];
}

class CheckAuthStatus extends AuthEvent {}

class LogoutRequested extends AuthEvent {}

// States
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class OtpSent extends AuthState {
  final String verificationId;
  const OtpSent(this.verificationId);

  @override
  List<Object?> get props => [verificationId];
}

class AuthAuthenticated extends AuthState {
  final UserEntity user;
  const AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

class AuthUnauthenticated extends AuthState {}
