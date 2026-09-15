import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:larnity/src/core/error/failures.dart';
import 'package:larnity/src/core/service/supabase/src/supabase_provider.dart';
import 'package:larnity/src/core/service/supabase/src/supabase_table.dart';
import 'package:larnity/src/core/utils/logger.dart';
import 'package:larnity/src/features/group/data/models/resource_category_model.dart';
import 'package:larnity/src/features/group/data/models/resource_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final treasureDataSourceProvider = Provider<TreasureDataSource>((ref) {
  return TreasureDataSource(supabaseClient: ref.watch(supabaseClientProvider));
});

class TreasureDataSource {
  final SupabaseClient supabaseClient;

  TreasureDataSource({required this.supabaseClient});

  Future<Either<Failure, List<ResourceModel>>> getResources({
    required String groupId,
  }) async {
    try {
      final response = await supabaseClient
          .from(SupabaseTable.resource)
          .select()
          .eq('groupId', groupId)
          .order('created_at', ascending: false);

      final resources = (response as List)
          .map((e) => ResourceModel.fromMap(e as Map<String, dynamic>))
          .toList();

      return Right(resources);
    } on PostgrestException catch (e) {
      Log.error('getResources error: ${e.message}');
      return Left(Failure(e.message));
    } catch (e) {
      Log.error('getResources error: $e');
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, ResourceModel>> addResource({
    required ResourceModel resource,
  }) async {
    try {
      final response = await supabaseClient
          .from(SupabaseTable.resource)
          .insert(resource.toMap())
          .select()
          .single();

      final created = ResourceModel.fromMap(response);
      return Right(created);
    } on PostgrestException catch (e) {
      Log.error('addResource error: ${e.message}');
      return Left(Failure(e.message));
    } catch (e) {
      Log.error('addResource error: $e');
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, void>> deleteResource({
    required String resourceId,
  }) async {
    try {
      await supabaseClient
          .from(SupabaseTable.resource)
          .delete()
          .eq('id', resourceId);

      return const Right(null);
    } on PostgrestException catch (e) {
      Log.error('deleteResource error: ${e.message}');
      return Left(Failure(e.message));
    } catch (e) {
      Log.error('deleteResource error: $e');
      return Left(Failure(e.toString()));
    }
  }

  // --- Categories (unused in UI currently, but supported in backend) ---

  Future<Either<Failure, List<ResourceCategoryModel>>> getCategories({
    required String groupId,
  }) async {
    try {
      final response = await supabaseClient
          .from(SupabaseTable.resourceCategory)
          .select()
          .eq('groupId', groupId)
          .order('created_at', ascending: false);

      final categories = (response as List)
          .map((e) => ResourceCategoryModel.fromMap(e as Map<String, dynamic>))
          .toList();

      return Right(categories);
    } on PostgrestException catch (e) {
      Log.error('getCategories error: ${e.message}');
      return Left(Failure(e.message));
    } catch (e) {
      Log.error('getCategories error: $e');
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, ResourceCategoryModel>> addCategory({
    required ResourceCategoryModel category,
  }) async {
    try {
      final response = await supabaseClient
          .from(SupabaseTable.resourceCategory)
          .insert(category.toMap())
          .select()
          .single();

      final created = ResourceCategoryModel.fromMap(response);
      return Right(created);
    } on PostgrestException catch (e) {
      Log.error('addCategory error: ${e.message}');
      return Left(Failure(e.message));
    } catch (e) {
      Log.error('addCategory error: $e');
      return Left(Failure(e.toString()));
    }
  }
}
