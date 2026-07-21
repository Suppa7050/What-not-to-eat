import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Import screens (to be created)
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/profile/presentation/profile_setup_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/scan/presentation/scan_screen.dart';
import '../../features/scan/presentation/result_screen.dart';
import '../../features/history/presentation/history_screen.dart';
import '../../features/scan/domain/scan_result.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),

      GoRoute(
        path: '/profile-setup',
        builder: (context, state) => const ProfileSetupScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/scan',
        builder: (context, state) {
          final initialType = state.extra as String? ?? 'ingredient';
          return ScanScreen(initialType: initialType);
        }
      ),
      GoRoute(
        path: '/result',
        builder: (context, state) {
          final result = state.extra as ScanResult;
          return ResultScreen(result: result);
        }
      ),
      GoRoute(
        path: '/history',
        builder: (context, state) => const HistoryScreen(),
      ),
    ],
    redirect: (context, state) {
      // Basic auth check will be handled in SplashScreen via SharedPreferences.
      return null; 
    },
  );
});
