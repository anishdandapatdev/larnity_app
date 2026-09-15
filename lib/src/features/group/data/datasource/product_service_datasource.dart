import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:larnity/src/core/error/failures.dart';
import 'package:larnity/src/core/service/supabase/src/supabase_provider.dart';
import 'package:larnity/src/core/service/supabase/src/supabase_table.dart';
import 'package:larnity/src/core/utils/logger.dart';
import 'package:larnity/src/features/group/data/models/product_service_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final productServiceDataSourceProvider =
    Provider<ProductServiceDataSource>((ref) {
  return ProductServiceDataSource(
      supabaseClient: ref.watch(supabaseClientProvider));
});

class ProductServiceDataSource {
  final SupabaseClient supabaseClient;

  ProductServiceDataSource({required this.supabaseClient});

  /// Get products or services for a group.
  Future<Either<Failure, List<ProductServiceModel>>> getItems({
    required String groupId,
    required String type, // 'PRODUCT' or 'SERVICE'
  }) async {
    try {
      final response = await supabaseClient
          .from(SupabaseTable.productAndService)
          .select('*')
          .eq('groupId', groupId)
          .eq('type', type)
          .order('created_at', ascending: false);

      final items = (response as List)
          .map((e) => ProductServiceModel.fromMap(e as Map<String, dynamic>))
          .toList();

      Log.info('Fetched ${items.length} ${type}s for group $groupId');
      return Right(items);
    } on PostgrestException catch (e) {
      Log.error('getItems error: ${e.message}');
      return Left(Failure(e.message));
    } catch (e) {
      Log.error('getItems error: $e');
      return Left(Failure(e.toString()));
    }
  }

  /// Create a product or service.
  Future<Either<Failure, ProductServiceModel>> createItem({
    required ProductServiceModel item,
  }) async {
    try {
      final response = await supabaseClient
          .from(SupabaseTable.productAndService)
          .insert(item.toMap())
          .select()
          .single();

      final created = ProductServiceModel.fromMap(response);
      Log.info('Created ${created.type}: ${created.id}');
      return Right(created);
    } on PostgrestException catch (e) {
      Log.error('createItem error: ${e.message}');
      return Left(Failure(e.message));
    } catch (e) {
      Log.error('createItem error: $e');
      return Left(Failure(e.toString()));
    }
  }

  /// Update a product or service.
  Future<Either<Failure, ProductServiceModel>> updateItem({
    required ProductServiceModel item,
  }) async {
    try {
      final response = await supabaseClient
          .from(SupabaseTable.productAndService)
          .update(item.toMap())
          .eq('id', item.id!)
          .select()
          .single();

      final updated = ProductServiceModel.fromMap(response);
      Log.info('Updated ${updated.type}: ${updated.id}');
      return Right(updated);
    } on PostgrestException catch (e) {
      Log.error('updateItem error: ${e.message}');
      return Left(Failure(e.message));
    } catch (e) {
      Log.error('updateItem error: $e');
      return Left(Failure(e.toString()));
    }
  }

  /// Delete a product or service.
  Future<Either<Failure, void>> deleteItem({
    required String itemId,
  }) async {
    try {
      await supabaseClient
          .from(SupabaseTable.productAndService)
          .delete()
          .eq('id', itemId);

      Log.info('Deleted item: $itemId');
      return const Right(null);
    } on PostgrestException catch (e) {
      Log.error('deleteItem error: ${e.message}');
      return Left(Failure(e.message));
    } catch (e) {
      Log.error('deleteItem error: $e');
      return Left(Failure(e.toString()));
    }
  }
}
