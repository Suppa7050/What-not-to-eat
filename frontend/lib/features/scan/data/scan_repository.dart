import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../domain/scan_result.dart';
import '../../profile/domain/user_profile.dart';

final scanRepositoryProvider = Provider<ScanRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return ScanRepository(dio);
});

class ScanRepository {
  final Dio _dio;

  ScanRepository(this._dio);

  Future<ScanResult> scanImage({
    required File imageFile,
    required UserProfile profile,
    String? concern,
    String scanType = 'ingredient',
  }) async {
    try {
      String fileName = imageFile.path.split('/').last;
      
      FormData formData = FormData.fromMap({
        "image": await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        ),
        "profile": profile.toJson(),
        if (concern != null) "concern": concern,
        "scanType": scanType,
      });

      final response = await _dio.post('/scan', data: formData);
      return ScanResult.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null && e.response?.data is Map) {
        final data = e.response?.data as Map;
        if (data['message'] != null) {
          throw Exception(data['message']);
        } else if (data['error'] != null) {
          throw Exception(data['error']);
        }
      }
      throw Exception('Failed to scan image: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
  
  Future<List<ScanResult>> getHistory() async {
    try {
      final response = await _dio.get('/history');
      return (response.data as List).map((e) => ScanResult.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to get history: $e');
    }
  }
}
