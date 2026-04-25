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
    on<AuthErrorInternal>((event, emit) => emit(AuthError(event.message)));
    on<OtpSentInternal>((event, emit) => emit(OtpSent(event.verificationId)));
  }

  Future<void> _onSendOtp(
    SendOtp event,
    Emitter<AuthState> emit,
  ) async {
    print('DEBUG: AuthBloc _onSendOtp called for ${event.phoneNumber}');
    emit(AuthLoading());
    try {
      print('DEBUG: Calling _auth.verifyPhoneNumber...');
      
      // Configure Invisible reCAPTCHA for Web
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
      // 1. Verify with Firebase
      final credential = PhoneAuthProvider.credential(
        verificationId: event.verificationId,
        smsCode: event.smsCode,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final idToken = await userCredential.user?.getIdToken();

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
