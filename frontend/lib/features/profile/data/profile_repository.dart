import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/network/api_client.dart';
import '../domain/user_profile.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return ProfileRepository(dio);
});

class ProfileRepository {
  final Dio _dio;
  static const _localProfileKey = 'local_user_profile';

  ProfileRepository(this._dio);

  Future<UserProfile> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    
    // First, try to fetch from backend if logged in
    final token = prefs.getString('jwt_token');
    if (token != null && token.isNotEmpty) {
      try {
        final response = await _dio.get('/profile');
        final profile = UserProfile.fromJson(response.data);
        // Save fetched profile locally
        await prefs.setString(_localProfileKey, jsonEncode(profile.toJson()));
        return profile;
      } catch (e) {
        // Fall back to local if API fails
      }
    }

    // Try to load local profile (Guest mode or offline fallback)
    final localData = prefs.getString(_localProfileKey);
    if (localData != null) {
      return UserProfile.fromJson(jsonDecode(localData));
    }
    
    // Default empty profile
    return UserProfile();
  }

  Future<UserProfile> updateProfile({
    String? username, 
    int? age, 
    double? height, 
    double? weight,
    bool? hasDiabetes,
    String? additionalNotes,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    UserProfile currentProfile = await getProfile();
    
    final updatedProfile = UserProfile(
      id: currentProfile.id,
      email: currentProfile.email,
      username: username ?? currentProfile.username,
      age: age ?? currentProfile.age,
      height: height ?? currentProfile.height,
      weight: weight ?? currentProfile.weight,
      hasDiabetes: hasDiabetes ?? currentProfile.hasDiabetes,
      additionalNotes: additionalNotes ?? currentProfile.additionalNotes,
    );

    // Save locally
    await prefs.setString(_localProfileKey, jsonEncode(updatedProfile.toJson()));

    // Try to sync with backend if logged in
    final token = prefs.getString('jwt_token');
    if (token != null && token.isNotEmpty) {
      try {
        final response = await _dio.put('/profile', data: {
          if (username != null) 'username': username,
          if (age != null) 'age': age,
          if (height != null) 'height': height,
          if (weight != null) 'weight': weight,
          if (hasDiabetes != null) 'hasDiabetes': hasDiabetes,
          if (additionalNotes != null) 'additionalNotes': additionalNotes,
        });
        return UserProfile.fromJson(response.data);
      } on DioException catch (e) {
        if (e.response?.statusCode == 409) {
          throw Exception('Username already taken');
        }
        throw Exception('Failed to update profile online: $e');
      } catch (e) {
        throw Exception('Failed to update profile online: $e');
      }
    }

    return updatedProfile;
  }

  Future<void> syncLocalProfileToMongo() async {
    final prefs = await SharedPreferences.getInstance();
    final localData = prefs.getString(_localProfileKey);
    final token = prefs.getString('jwt_token');

    if (token != null && token.isNotEmpty && localData != null) {
      final localProfile = UserProfile.fromJson(jsonDecode(localData));
      
      bool hasData = localProfile.username != null || 
                     localProfile.age != null || 
                     localProfile.weight != null || 
                     localProfile.height != null || 
                     localProfile.hasDiabetes || 
                     (localProfile.additionalNotes != null && localProfile.additionalNotes!.isNotEmpty);
                     
      if (hasData) {
        try {
          await updateProfile(
            username: localProfile.username,
            age: localProfile.age,
            height: localProfile.height,
            weight: localProfile.weight,
            hasDiabetes: localProfile.hasDiabetes,
            additionalNotes: localProfile.additionalNotes,
          );
        } catch (e) {
          // ignore sync errors
        }
      }
    }
  }
}
