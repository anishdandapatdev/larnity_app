import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:larnity/src/core/error/failures.dart';
import 'package:larnity/src/core/service/supabase/src/supabase_provider.dart';
import 'package:larnity/src/core/service/supabase/src/supabase_table.dart';
import 'package:larnity/src/core/utils/logger.dart';
import 'package:larnity/src/features/auth/data/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final profileDataSourceProvider = Provider<ProfileDataSource>((ref) {
  return ProfileDataSource(supabaseClient: ref.watch(supabaseClientProvider));
});

class ProfileDataSource {
  final SupabaseClient supabaseClient;
  ProfileDataSource({required this.supabaseClient});

  /// Upsert so both first-time profile creation and updates work correctly.
  Future<Either<Failure, UserModel>> createProfile({
    required UserModel user,
  }) async {
    try {
      Log.info("Upserting profile map: ${user.toMap()}");
      final response = await supabaseClient
          .from(SupabaseTable.profiles)
          .upsert(user.toMap(), onConflict: 'id')
          .select();

      Log.info("Upsert Profile Response: ${response.first.toString()}");

      return right(UserModel.fromMap(response.first));
    } on PostgrestException catch (e) {
      Log.info("Upsert Profile Error: ${e.message}");
      return left(Failure(e.message));
    } catch (e) {
      Log.info("Upsert Profile Error: ${e.toString()}");
      return left(Failure(e.toString()));
    }
  }

  /// Uploads a profile image to Supabase Storage and returns its public URL.
  Future<Either<Failure, String>> uploadProfileImage({
    required File imageFile,
    required String userId,
  }) async {
    try {
      final fileExt = imageFile.path.split('.').last.toLowerCase();
      final fileName = 'avatar_$userId.$fileExt';
      const bucket = 'avatars';

      await supabaseClient.storage.from(bucket).upload(
            fileName,
            imageFile,
            fileOptions: const FileOptions(upsert: true),
          );

      final publicUrl = supabaseClient.storage
          .from(bucket)
          .getPublicUrl(fileName);

      Log.info("Profile image uploaded: $publicUrl");
      return right(publicUrl);
    } on StorageException catch (e) {
      Log.info("Image upload Storage error: ${e.message}");
      return left(Failure(e.message));
    } catch (e) {
      Log.info("Image upload error: ${e.toString()}");
      return left(Failure(e.toString()));
    }
  }
}
