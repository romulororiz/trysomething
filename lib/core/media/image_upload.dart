import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Cloudinary unsigned image upload utility.
///
/// Configure [cloudName] and [uploadPreset] before deploying.
/// Create an unsigned upload preset in Cloudinary Settings → Upload.
class ImageUpload {
  ImageUpload._();

  // TODO: Replace with your Cloudinary cloud name and unsigned upload preset.
  static const _cloudName = 'CLOUD_NAME';
  static const _uploadPreset = 'PRESET';

  /// Uploads [file] to Cloudinary and returns the secure URL.
  /// Returns null if upload fails.
  static Future<String?> uploadImage(File file) async {
    try {
      final dio = Dio();
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path),
        'upload_preset': _uploadPreset,
      });
      final response = await dio.post(
        'https://api.cloudinary.com/v1_1/$_cloudName/image/upload',
        data: formData,
      );
      return response.data['secure_url'] as String?;
    } catch (e) {
      debugPrint('[ImageUpload] Failed to upload: $e');
      return null;
    }
  }
}
