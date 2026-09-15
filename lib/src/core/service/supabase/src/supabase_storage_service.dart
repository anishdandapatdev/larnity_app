import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:larnity/src/core/service/supabase/src/supabase_provider.dart';
import 'package:larnity/src/core/utils/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Provider for [SupabaseStorageService].
final storageServiceProvider = Provider<SupabaseStorageService>((ref) {
  return SupabaseStorageService(client: ref.watch(supabaseClientProvider));
});

/// Storage bucket name constants.
class StorageBucket {
  static const String profileImages = 'profile-images';
  static const String groupImages = 'images'; // Using 'images' bucket
  static const String postMedia = 'images';
  static const String courseMedia = 'images';
  static const String challengeMedia = 'images';
  static const String productMedia = 'images'; // The user has 'images' bucket for everything
  static const String messageMedia = 'images';
  static const String jobMedia = 'images';
  static const String eventMedia = 'images';
  static const String resourceMedia = 'images';
}

/// Centralized service for Supabase Storage operations.
///
/// Handles file uploads, downloads, deletions, and public URL generation
/// across all features (posts, chat, challenges, products, etc.).
class SupabaseStorageService {
  final SupabaseClient client;

  SupabaseStorageService({required this.client});

  /// Upload a [File] to the given [bucket] at [path].
  ///
  /// Returns the public URL of the uploaded file.
  /// [path] should include the filename, e.g. `'posts/abc123/image.jpg'`
  Future<String> uploadFile({
    required String bucket,
    required String path,
    required File file,
  }) async {
    try {
      await client.storage.from(bucket).upload(
        path,
        file,
        fileOptions: const FileOptions(upsert: true),
      );

      final publicUrl = client.storage.from(bucket).getPublicUrl(path);
      Log.info('File uploaded to $bucket/$path → $publicUrl');
      return publicUrl;
    } catch (e) {
      Log.error('File upload error ($bucket/$path): $e');
      rethrow;
    }
  }

  /// Upload raw bytes to the given [bucket] at [path].
  ///
  /// Useful for web or when you have bytes instead of a File object.
  Future<String> uploadBytes({
    required String bucket,
    required String path,
    required Uint8List bytes,
    String? contentType,
  }) async {
    try {
      await client.storage.from(bucket).uploadBinary(
        path,
        bytes,
        fileOptions: FileOptions(
          upsert: true,
          contentType: contentType,
        ),
      );

      final publicUrl = client.storage.from(bucket).getPublicUrl(path);
      Log.info('Bytes uploaded to $bucket/$path → $publicUrl');
      return publicUrl;
    } catch (e) {
      Log.error('Bytes upload error ($bucket/$path): $e');
      rethrow;
    }
  }

  /// Delete a file from the given [bucket] at [path].
  Future<void> deleteFile({
    required String bucket,
    required String path,
  }) async {
    try {
      await client.storage.from(bucket).remove([path]);
      Log.info('File deleted from $bucket/$path');
    } catch (e) {
      Log.error('File delete error ($bucket/$path): $e');
      rethrow;
    }
  }

  /// Delete multiple files from the given [bucket].
  Future<void> deleteFiles({
    required String bucket,
    required List<String> paths,
  }) async {
    try {
      await client.storage.from(bucket).remove(paths);
      Log.info('Deleted ${paths.length} files from $bucket');
    } catch (e) {
      Log.error('Batch file delete error ($bucket): $e');
      rethrow;
    }
  }

  /// Get the public URL for a file in [bucket] at [path].
  String getPublicUrl({
    required String bucket,
    required String path,
  }) {
    return client.storage.from(bucket).getPublicUrl(path);
  }

  /// Generate a unique file path using userId and timestamp.
  ///
  /// Example: `userId/1716940800000_filename.jpg`
  static String generatePath({
    String? userId,
    required String fileName,
    String? subfolder,
  }) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final sanitizedName = fileName.replaceAll(RegExp(r'[^\w\.\-]'), '_');
    
    String path = '';
    if (userId != null && userId.isNotEmpty) {
      path += '$userId/';
    }
    if (subfolder != null && subfolder.isNotEmpty) {
      path += '$subfolder/';
    }
    path += '${timestamp}_$sanitizedName';
    
    return path;
  }
}
