import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../api/api_client.dart';
import '../api/api_constants.dart';

/// Cloudinary unsigned image upload with pre-upload AI moderation.
///
/// Flow: pick → moderate (Haiku vision) → upload (Cloudinary).
/// If moderation fails or rejects, the image NEVER reaches Cloudinary.
class ImageUpload {
  ImageUpload._();

  static const _cloudName = 'dduhb4jtj';
  static const _uploadPreset = 'TrySomething';

  /// Moderates an image via server-side AI screening.
  /// Returns `null` if safe, or a rejection reason string if unsafe.
  /// Also returns a reason on network/server errors (fail closed).
  static Future<String?> moderateImage(File file) async {
    try {
      final resolvedPath = file.path.startsWith('file://')
          ? Uri.parse(file.path).toFilePath()
          : file.path;
      final resolved = File(resolvedPath);

      if (!resolved.existsSync()) {
        return 'File not found';
      }

      final bytes = await resolved.readAsBytes();
      final base64Image = base64Encode(bytes);

      // Detect media type from extension
      final ext = resolvedPath.split('.').last.toLowerCase();
      final mediaType = switch (ext) {
        'png' => 'image/png',
        'webp' => 'image/webp',
        'gif' => 'image/gif',
        _ => 'image/jpeg',
      };

      debugPrint('[ImageUpload] Moderating ${bytes.length} bytes');

      final dio = ApiClient.instance;
      final response = await dio.post(
        ApiConstants.moderateImage,
        data: {
          'image': base64Image,
          'mediaType': mediaType,
        },
        options: Options(
          receiveTimeout: const Duration(seconds: 15),
          sendTimeout: const Duration(seconds: 15),
        ),
      );

      final safe = response.data['safe'] as bool? ?? false;
      if (safe) {
        debugPrint('[ImageUpload] Moderation: SAFE');
        return null; // null = safe
      }

      final reason = response.data['reason'] as String? ?? 'Content policy violation';
      debugPrint('[ImageUpload] Moderation: BLOCKED — $reason');
      return reason;
    } on DioException catch (e) {
      debugPrint('[ImageUpload] Moderation network error: ${e.message}');
      // Fail closed — reject if moderation is unreachable
      return 'Unable to verify image safety. Please try again.';
    } catch (e) {
      debugPrint('[ImageUpload] Moderation error: $e');
      return 'Unable to verify image safety. Please try again.';
    }
  }

  /// Uploads an image to Cloudinary and returns the secure URL.
  /// Call [moderateImage] first — this method does NOT moderate.
  static Future<String?> uploadImage(File file) async {
    try {
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

  /// Moderates then uploads. Returns the Cloudinary URL if safe,
  /// null if upload fails. Throws [ImageModerationException] if blocked.
  static Future<String?> moderateAndUpload(File file) async {
    final rejection = await moderateImage(file);
    if (rejection != null) {
      throw ImageModerationException(rejection);
    }
    return uploadImage(file);
  }
}

/// Thrown when an image is rejected by the moderation system.
class ImageModerationException implements Exception {
  final String reason;
  const ImageModerationException(this.reason);

  @override
  String toString() => 'ImageModerationException: $reason';
}
