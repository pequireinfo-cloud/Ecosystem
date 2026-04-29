import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:descope/descope.dart';
import 'package:flutter/foundation.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_state.dart';
export 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository repository;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AuthBloc({
    required this.repository,
  }) : super(AuthInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
    on<SendWhatsAppOtp>(_onSendWhatsAppOtp);
    on<VerifyWhatsAppOtp>(_onVerifyWhatsAppOtp);
    on<LoginWithDescope>(_onLoginWithDescope);
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<LogoutRequested>(_onLogoutRequested);
    on<AuthErrorInternal>((event, emit) => emit(AuthError(event.message)));
    on<OtpSentInternal>((event, emit) => emit(OtpSent(event.phoneNumber)));
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final session = Descope.sessionManager.session;
      if (session != null && !session.sessionToken.isExpired) {
        debugPrint('AUTH_BLOC: Valid Descope session found');
        
        final failureOrUser = await repository.getCachedUser();
        
        failureOrUser.fold(
          (failure) => emit(AuthUnauthenticated()),
          (user) {
            if (user != null) {
              emit(AuthAuthenticated(user));
            } else {
              emit(AuthUnauthenticated());
            }
          },
        );
        return;
      }
    } catch (e) {
      debugPrint('AUTH_BLOC: Session check error: $e');
    }
    emit(AuthUnauthenticated());
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _auth.signOut();
    emit(AuthUnauthenticated());
  }

  Future<void> _onSendWhatsAppOtp(
    SendWhatsAppOtp event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final failureOrSuccess = await repository.sendWhatsAppOtp(
      phoneNumber: event.phoneNumber,
    );

    failureOrSuccess.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(OtpSent(event.phoneNumber)),
    );
  }

  Future<void> _onVerifyWhatsAppOtp(
    VerifyWhatsAppOtp event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final failureOrUser = await repository.verifyWhatsAppOtp(
      phoneNumber: event.phoneNumber,
      otp: event.otp,
      role: event.role,
    );

    failureOrUser.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onLoginWithDescope(
    LoginWithDescope event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final failureOrUser = await repository.verifyDescope(
      token: event.token,
      role: event.role,
    );

    failureOrUser.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final failureOrUser = await repository.login(
      email: event.email,
      password: event.password,
      role: event.role,
    );

    failureOrUser.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }
}
