import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:descope/descope.dart';
import 'package:flutter/foundation.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/config/api_config.dart';
import '../../domain/entities/user_entity.dart';
import 'auth_state.dart';
import '../../../../core/services/notification_service.dart';
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
      debugPrint('AUTH_BLOC: Checking persistent auth status...');
      
      // 1. Check our own local cache first (more reliable for "Persistent Login")
      final failureOrUser = await repository.getCachedUser();
      final token = await repository.getToken();

      if (token != null) {
        ApiConfig.setToken(token);
        debugPrint('AUTH_BLOC: Token restored to ApiConfig');
      }

      bool isAuthenticated = false;
      UserEntity? authenticatedUser;

      failureOrUser.fold(
        (failure) => isAuthenticated = false,
        (user) {
          if (user != null) {
            isAuthenticated = true;
            authenticatedUser = user;
          }
        },
      );

      if (isAuthenticated && authenticatedUser != null) {
        debugPrint('AUTH_BLOC: User authenticated from local cache');
        emit(AuthAuthenticated(authenticatedUser!));
        di.sl<NotificationService>().syncTokenWithBackend();
        return;
      }

      // 2. Fallback to Descope Session Manager if local cache is empty
      final session = Descope.sessionManager.session;
      if (session != null && !session.sessionToken.isExpired) {
        debugPrint('AUTH_BLOC: Valid Descope session found, but no local user?');
        // This case is unlikely if cacheUser is called on login, but handle it
        emit(AuthUnauthenticated()); // Or try to fetch user from backend
        return;
      }
    } catch (e) {
      debugPrint('AUTH_BLOC: Session check error: $e');
    }
    
    debugPrint('AUTH_BLOC: No valid session found, landing on Onboarding');
    emit(AuthUnauthenticated());
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _auth.signOut();
    Descope.sessionManager.clearSession();
    await repository.logout();
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
      (user) {
        emit(AuthAuthenticated(user));
        di.sl<NotificationService>().syncTokenWithBackend();
      },
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
      (user) {
        emit(AuthAuthenticated(user));
        di.sl<NotificationService>().syncTokenWithBackend();
      },
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
      (user) {
        emit(AuthAuthenticated(user));
        di.sl<NotificationService>().syncTokenWithBackend();
      },
    );
  }
}
