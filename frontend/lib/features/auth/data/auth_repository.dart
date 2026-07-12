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

  Future<void> login(String username, String password) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'username': username,
        'password': password,
      });
      final token = response.data['token'];
      if (token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', token);
      }
    } on DioException catch (e) {
      if (e.response != null && e.response!.data != null) {
        throw Exception(e.response!.data['error'] ?? 'Failed to login');
      }
      throw Exception('Failed to login: $e');
    } catch (e) {
      throw Exception('Failed to login: $e');
    }
  }

  Future<void> register(String username, String password) async {
    try {
      final response = await _dio.post('/auth/register', data: {
        'username': username,
        'password': password,
      });
      final token = response.data['token'];
      if (token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', token);
      }
    } on DioException catch (e) {
      if (e.response != null && e.response!.data != null) {
        throw Exception(e.response!.data['error'] ?? 'Failed to register');
      }
      throw Exception('Failed to register: $e');
    } catch (e) {
      throw Exception('Failed to register: $e');
    }
  }
}
