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

  /// Updates user profile details (first name, last name, phone, image).
  /// Uses a direct update to avoid triggering RLS INSERT policy violations on `profiles`.
  Future<Either<Failure, UserModel>> createProfile({
    required UserModel user,
  }) async {
    try {
      final effectiveId = user.id ?? supabaseClient.auth.currentUser?.id;
      if (effectiveId == null) {
        return left(Failure("User not authenticated"));
      }

      final updateData = <String, dynamic>{
        if (user.firstName != null) 'firstname': user.firstName,
        if (user.lastName != null) 'lastname': user.lastName,
        if (user.phoneNumber != null) 'phoneNumber': user.phoneNumber,
        if (user.image != null) 'image': user.image,
      };

      Log.info("Updating profile for $effectiveId: $updateData");
      final updateResponse = await supabaseClient
          .from(SupabaseTable.profiles)
          .update(updateData)
          .eq('id', effectiveId)
          .select();

      if (updateResponse.isNotEmpty) {
        Log.info("Profile updated successfully: ${updateResponse.first}");
        return right(
          UserModel.fromMap(updateResponse.first).copyWith(
            id: effectiveId,
            email: user.email ?? supabaseClient.auth.currentUser?.email,
          ),
        );
      }

      // If no row was updated (profile didn't exist yet), insert/upsert it
      final fullData = <String, dynamic>{
        'id': effectiveId,
        'firstname': user.firstName ?? '',
        'lastname': user.lastName ?? '',
        if (user.phoneNumber != null) 'phoneNumber': user.phoneNumber,
        if (user.image != null) 'image': user.image,
        if (user.email != null) 'email': user.email,
      };
      final upsertResponse = await supabaseClient
          .from(SupabaseTable.profiles)
          .upsert(fullData, onConflict: 'id')
          .select();

      return right(
        UserModel.fromMap(upsertResponse.first).copyWith(
          id: effectiveId,
          email: user.email ?? supabaseClient.auth.currentUser?.email,
        ),
      );
    } on PostgrestException catch (e) {
      Log.error("Update Profile Error: ${e.message}");
      return left(Failure(e.message));
    } catch (e) {
      Log.error("Update Profile Error: $e");
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
