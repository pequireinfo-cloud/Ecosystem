import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/verify_otp_usecase.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final VerifyOtpUseCase verifyOtpUseCase;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AuthBloc({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.verifyOtpUseCase,
  }) : super(AuthInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
    on<SendOtp>(_onSendOtp);
    on<VerifyOtp>(_onVerifyOtp);
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<LogoutRequested>(_onLogoutRequested);
    on<AuthErrorInternal>((event, emit) => emit(AuthError(event.message)));
    on<OtpSentInternal>((event, emit) => emit(OtpSent(event.verificationId)));
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    final user = _auth.currentUser;
    if (user != null) {
      final idToken = await user.getIdToken();
      if (idToken != null) {
        final failureOrUser = await verifyOtpUseCase(VerifyOtpParams(
          idToken: idToken,
          role: 'user',
        ));
        failureOrUser.fold(
          (failure) => emit(AuthUnauthenticated()),
          (userEntity) => emit(AuthAuthenticated(userEntity)),
        );
        return;
      }
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

  Future<void> _onSendOtp(
    SendOtp event,
    Emitter<AuthState> emit,
  ) async {
    print('DEBUG: AuthBloc _onSendOtp called for ${event.phoneNumber}');
    emit(AuthLoading());
    
    // Fixed OTP for Testing
    if (event.phoneNumber.contains('8081158394')) {
      print('DEBUG: Test number detected. Bypassing Firebase verifyPhoneNumber.');
      add(const OtpSentInternal('test_verification_id_user'));
      return;
    }

    try {
      print('DEBUG: Calling _auth.verifyPhoneNumber...');
      
      await _auth.verifyPhoneNumber(
        phoneNumber: event.phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          print('DEBUG: verificationCompleted: Auto-verification success!');
          add(VerifyOtp(
            verificationId: credential.verificationId ?? '',
            smsCode: credential.smsCode ?? '',
            role: 'user',
          ));
        },
        verificationFailed: (FirebaseAuthException e) {
          print('DEBUG: verificationFailed: ${e.code} - ${e.message}');
          add(AuthErrorInternal(e.message ?? 'Phone verification failed'));
        },
        codeSent: (String verificationId, int? resendToken) {
          print('DEBUG: codeSent: VerificationId = $verificationId');
          add(OtpSentInternal(verificationId));
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          print('DEBUG: codeAutoRetrievalTimeout: $verificationId');
        },
      );
    } catch (e) {
      print('DEBUG: Exception in _onSendOtp: $e');
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onVerifyOtp(
    VerifyOtp event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      String? idToken;

      // Check for Test Mode
      if (event.verificationId == 'test_verification_id_user') {
        if (event.smsCode == '1234') {
          // For testing, we might not have a real Firebase user session
          // We can try to sign in with a custom token or just mock the backend call
          // However, for "Realism", we'll assume the backend has a way to handle this
          // or we use a real test number in Firebase console.
          // For now, let's use a dummy token that the backend will recognize as "Test User"
          idToken = "TEST_USER_TOKEN_8081158394";
        } else {
          emit(const AuthError('Invalid OTP for test number'));
          return;
        }
      } else {
        // 1. Verify with Firebase
        final credential = PhoneAuthProvider.credential(
          verificationId: event.verificationId,
          smsCode: event.smsCode,
        );

        final userCredential = await _auth.signInWithCredential(credential);
        idToken = await userCredential.user?.getIdToken();
      }

      if (idToken == null) {
        emit(const AuthError('Failed to get identity token'));
        return;
      }

      // 2. Verify with our Backend
      final failureOrUser = await verifyOtpUseCase(VerifyOtpParams(
        idToken: idToken,
        role: event.role,
      ));

      failureOrUser.fold(
        (failure) => emit(AuthError(failure.message)),
        (user) => emit(AuthAuthenticated(user)),
      );
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final failureOrUser = await loginUseCase(LoginParams(
      email: event.email,
      password: event.password,
      role: event.role,
    ));

    failureOrUser.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onRegisterSubmitted(
    RegisterSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final failureOrUser = await registerUseCase(RegisterParams(
      email: event.email,
      password: event.password,
      role: event.role,
    ));

    failureOrUser.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }
}
