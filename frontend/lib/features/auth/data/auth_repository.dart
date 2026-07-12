import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/network/api_client.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return AuthRepository(dio);
});

class AuthRepository {
  final Dio _dio;

  AuthRepository(this._dio);

  Future<void> sendOtp(String email) async {
    try {
      await _dio.post('/auth/send-otp', data: {'email': email});
    } catch (e) {
      throw Exception('Failed to send OTP: $e');
    }
  }

  Future<void> verifyOtp(String email, String code) async {
    try {
      final response = await _dio.post('/auth/verify-otp', data: {
        'email': email,
        'code': code,
      });
      final token = response.data['token'];
      if (token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', token);
      }
    } catch (e) {
      throw Exception('Failed to verify OTP: $e');
    }
  }
}
