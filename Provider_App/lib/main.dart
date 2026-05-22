import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:pequire_provider_app/core/theme/app_theme.dart';
import 'features/onboarding/screens/onboarding_screen.dart';
import 'features/auth/screens/login_screen.dart';
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

import 'features/settings/screens/language_selection_screen.dart';
import 'package:pequire_provider_app/core/services/firebase_service.dart';
import 'package:pequire_provider_app/core/services/socket_service.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pequire_provider_app/l10n/app_localizations.dart';
import 'package:pequire_provider_app/core/providers/locale_provider.dart';
import 'package:pequire_provider_app/core/providers/theme_provider.dart';

import 'package:descope/descope.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pequire_provider_app/core/config/api_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Descope
  Descope.projectId = 'P3CyZF9IZxcIXXxhQ3fZLgWJmuy5';

  // Load persistent session
  final prefs = await SharedPreferences.getInstance();
  ApiConfig.currentProviderId = prefs.getString('current_provider_id');
  
  // Initialize Firebase
  debugPrint("Starting Firebase initialization...");
  await FirebaseService().initialize();
  debugPrint("Firebase initialization check complete.");

  // Initialize Socket Service
  SocketService().connect();
  
  debugPrint("Starting runApp...");
  runApp(
    const ProviderScope(
      child: PequireApp(),
    ),
  );
}


final _router = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    final session = Descope.sessionManager.session;
    final isLoggedIn = session != null && !session.sessionToken.isExpired;
    
    final isLoggingIn = state.matchedLocation == '/login' || 
                        state.matchedLocation == '/onboarding' || 
                        state.matchedLocation == '/login/otp';
    
    if (!isLoggedIn) {
      // Not logged in
      if (isLoggingIn) return null; // Let them proceed to login/onboarding
      return '/onboarding'; // Otherwise force onboarding
    }
    
    // Logged in
    if (isLoggingIn || state.matchedLocation == '/') return '/home'; // If logged in, don't show login screens and redirect to home from root
    
    return null; // Let them proceed to their destination
  },
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const Scaffold(body: Center(child: CircularProgressIndicator())),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
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
      path: '/language-selection',
      builder: (context, state) => const LanguageSelectionScreen(),
    ),
    GoRoute(
      path: '/help',
      builder: (context, state) => const HelpScreen(),
    ),
  ],
);

class PequireApp extends ConsumerWidget {
  const PequireApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeModeProvider);
    
    return MaterialApp.router(
      title: 'Pequire Partner',
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('hi'),
      ],
    );
  }
}
