import 'package:fpdart/fpdart.dart';
import 'package:larnity/src/core/error/failures.dart';
import 'package:larnity/src/core/service/supabase/src/supabase_provider.dart';
import 'package:larnity/src/core/service/supabase/src/supabase_table.dart';
import 'package:larnity/src/core/utils/logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:larnity/src/features/group/data/models/product_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final productDataSourceProvider = Provider<ProductDataSource>((ref) {
  return ProductDataSource(supabaseClient: ref.read(supabaseClientProvider));
});

class ProductDataSource {
  final SupabaseClient supabaseClient;
  ProductDataSource({required this.supabaseClient});

  Future<Either<Failure, ProductModel>> createItem({required ProductModel item}) async {
    try {
      final response = await supabaseClient
          .from(SupabaseTable.productAndService)
          .insert(item.toMap())
          .select()
          .single();

      return Right(ProductModel.fromMap(response));
    } catch (e, stackTrace) {
      Log.error('createItem: $e', stackTrace: stackTrace);
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, List<ProductModel>>> getItems({required String groupId, required String type}) async {
    try {
      final response = await supabaseClient
          .from(SupabaseTable.productAndService)
          .select()
          .eq('groupId', groupId)
          .eq('type', type);

      final items = response.map((e) => ProductModel.fromMap(e)).toList();
      return Right(items);
    } catch (e, stackTrace) {
      Log.error('getItems: $e', stackTrace: stackTrace);
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, void>> deleteItem({required String itemId}) async {
    try {
      await supabaseClient
          .from(SupabaseTable.productAndService)
          .delete()
          .eq('id', itemId);

      return const Right(null);
    } catch (e, stackTrace) {
      Log.error('deleteItem: $e', stackTrace: stackTrace);
      return Left(Failure(e.toString()));
    }
  }
}
