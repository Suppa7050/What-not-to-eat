import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../profile/data/profile_repository.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(seconds: 2));
    
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token != null && token.isNotEmpty) {
      try {
        final profile = await ref.read(profileRepositoryProvider).getProfile();
        final setupSkipped = prefs.getBool('profile_setup_skipped') ?? false;
        if ((profile.username == null || profile.username!.isEmpty) && !setupSkipped) {
          if (mounted) context.go('/profile-setup');
        } else {
          if (mounted) context.go('/');
        }
      } catch (e) {
        // If profile fetch fails (e.g. invalid token), go to login
        await prefs.remove('jwt_token');
        if (mounted) context.go('/login');
      }
    } else {
      final setupSkipped = prefs.getBool('profile_setup_skipped') ?? false;
      if (setupSkipped) {
        if (mounted) context.go('/');
      } else {
        if (mounted) context.go('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/logo.png', width: 120, height: 120),
            const SizedBox(height: 24),
            const Text('kNOw n eat', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.green)),
            const SizedBox(height: 24),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
