import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Cloudinary unsigned image upload utility.
///
/// Configure [cloudName] and [uploadPreset] before deploying.
/// Create an unsigned upload preset in Cloudinary Settings → Upload.
class ImageUpload {
  ImageUpload._();

  static const _cloudName = 'dduhb4jtj';
  static const _uploadPreset = 'TrySomething';

  /// Uploads an image at [path] to Cloudinary and returns the secure URL.
  /// Accepts both plain paths and file:// URIs (as returned by image_picker).
  /// Returns null if upload fails.
  static Future<String?> uploadImage(File file) async {
    try {
      // Resolve file:// URIs to plain paths (image_picker on some Android
      // devices returns file:///data/... instead of /data/...).
      final resolvedPath = file.path.startsWith('file://')
          ? Uri.parse(file.path).toFilePath()
          : file.path;
      final resolved = File(resolvedPath);

      if (!resolved.existsSync()) {
        debugPrint('[ImageUpload] File does not exist: $resolvedPath');
        return null;
      }

      final bytes = await resolved.readAsBytes();
      debugPrint('[ImageUpload] Uploading ${bytes.length} bytes');

      final dio = Dio();
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(
          bytes,
          filename: resolvedPath.split('/').last,
        ),
        'upload_preset': _uploadPreset,
      });
      final response = await dio.post(
        'https://api.cloudinary.com/v1_1/$_cloudName/image/upload',
        data: formData,
      );
      final url = response.data['secure_url'] as String?;
      debugPrint('[ImageUpload] Success: $url');
      return url;
    } on DioException catch (e) {
      debugPrint('[ImageUpload] Cloudinary error: ${e.response?.statusCode}');
      debugPrint('[ImageUpload] Response body: ${e.response?.data}');
      return null;
    } catch (e) {
      debugPrint('[ImageUpload] Unexpected error: $e');
      return null;
    }
  }
}
