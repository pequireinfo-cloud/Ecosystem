import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:pequire_provider_app/core/theme/app_theme.dart';
import 'features/onboarding/screens/onboarding_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/otp_screen.dart';
import 'features/home/screens/home_screen.dart';
import 'features/history/screens/booking_history_screen.dart';
import 'features/profile/screens/profile_screen.dart';
import 'features/auth/screens/service_selection_screen.dart';
import 'features/auth/screens/profile_setup_screen.dart';
import 'features/auth/screens/kyc_screen.dart';
import 'features/auth/screens/verification_pending_screen.dart';
import 'features/earnings/screens/earnings_screen.dart';
import 'features/profile/screens/edit_profile_screen.dart';
import 'features/reviews/screens/reviews_screen.dart';
import 'features/settings/screens/settings_screen.dart';
import 'features/notifications/screens/notifications_screen.dart';
import 'features/help/screens/help_screen.dart';

import 'package:pequire_provider_app/core/services/firebase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await FirebaseService().initialize();

  runApp(
    const ProviderScope(
      child: PequireApp(),
    ),
  );
}

final _router = GoRouter(
  initialLocation: '/onboarding',
  routes: [
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
      routes: [
        GoRoute(
          path: 'otp',
          builder: (context, state) {
            final verificationId = state.extra as String?;
            return OtpScreen(verificationId: verificationId);
          },
        ),
      ],
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/history',
      builder: (context, state) => const BookingHistoryScreen(),
    ),
    GoRoute(
      path: '/service-selection',
      builder: (context, state) => const ServiceSelectionScreen(),
    ),
    GoRoute(
      path: '/profile-setup',
      builder: (context, state) => const ProfileSetupScreen(),
    ),
    GoRoute(
      path: '/kyc',
      builder: (context, state) => const KycScreen(),
    ),
    GoRoute(
      path: '/verification-pending',
      builder: (context, state) => const VerificationPendingScreen(),
    ),
    GoRoute(
      path: '/earnings',
      builder: (context, state) => const EarningsScreen(),
    ),
    GoRoute(
      path: '/reviews',
      builder: (context, state) => const ReviewsScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationsScreen(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/edit-profile',
      builder: (context, state) => const EditProfileScreen(),
    ),
    GoRoute(
      path: '/help',
      builder: (context, state) => const HelpScreen(),
    ),
  ],
);

class PequireApp extends StatelessWidget {
  const PequireApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'PeQuire Provider',
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
      theme: AppTheme.light,
    );
  }
}
