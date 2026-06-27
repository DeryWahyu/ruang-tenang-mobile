import 'dart:io';
import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../domain/repositories/upload_repository.dart';

class UploadRepositoryImpl implements UploadRepository {
  final ApiClient _apiClient;

  UploadRepositoryImpl({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<String> uploadImage(File file) async {
    final fileName = file.path.split('/').last;
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path, filename: fileName),
    });

    final response = await _apiClient.uploadFile<Map<String, dynamic>>(
      ApiConstants.uploadImage,
      formData: formData,
      fromJson: (json) => Map<String, dynamic>.from(json as Map),
    );

    if (!response.success || response.data == null) {
      throw Exception(response.error ?? 'Gagal mengunggah gambar');
    }

    return response.data!['url'] as String;
  }

  @override
  Future<String> uploadAudio(File file) async {
    final fileName = file.path.split('/').last;
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path, filename: fileName),
    });

    final response = await _apiClient.uploadFile<Map<String, dynamic>>(
      ApiConstants.uploadAudio,
      formData: formData,
      fromJson: (json) => Map<String, dynamic>.from(json as Map),
    );

    if (!response.success || response.data == null) {
      throw Exception(response.error ?? 'Gagal mengunggah audio');
    }

    return response.data!['url'] as String;
  }
}