import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../domain/user_profile.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return ProfileRepository(dio);
});

class ProfileRepository {
  final Dio _dio;

  ProfileRepository(this._dio);

  Future<UserProfile> getProfile() async {
    try {
      final response = await _dio.get('/profile');
      return UserProfile.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to get profile: $e');
    }
  }

  Future<UserProfile> updateProfile({String? username, int? age, double? height, double? weight}) async {
    try {
      final response = await _dio.put('/profile', data: {
        if (username != null) 'username': username,
        if (age != null) 'age': age,
        if (height != null) 'height': height,
        if (weight != null) 'weight': weight,
      });
      return UserProfile.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        throw Exception('Username already taken');
      }
      throw Exception('Failed to update profile: $e');
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }
}
