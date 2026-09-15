import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:larnity/src/core/error/failures.dart';
import 'package:larnity/src/core/service/supabase/src/supabase_provider.dart';
import 'package:larnity/src/core/service/supabase/src/supabase_table.dart';
import 'package:larnity/src/core/utils/logger.dart';
import 'package:larnity/src/features/group/data/models/supporter_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supporterDataSourceProvider = Provider<SupporterDataSource>((ref) {
  return SupporterDataSource(supabaseClient: ref.watch(supabaseClientProvider));
});

class SupporterDataSource {
  final SupabaseClient supabaseClient;

  SupporterDataSource({required this.supabaseClient});

  Future<Either<Failure, List<SupporterModel>>> getSupporters({
    required String groupId,
  }) async {
    try {
      final response = await supabaseClient
          .from(SupabaseTable.supporter)
          .select('*, profiles(*)')
          .eq('groupId', groupId)
          .order('created_at', ascending: false);

      final supporters = (response as List)
          .map((e) => SupporterModel.fromMap(e as Map<String, dynamic>))
          .toList();

      Log.info('Fetched ${supporters.length} supporters for group $groupId');
      return Right(supporters);
    } on PostgrestException catch (e) {
      Log.error('getSupporters error: ${e.message}');
      return Left(Failure(e.message));
    } catch (e) {
      Log.error('getSupporters error: $e');
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, SupporterModel>> addSupporter({
    required SupporterModel supporter,
  }) async {
    try {
      final response = await supabaseClient
          .from(SupabaseTable.supporter)
          .insert(supporter.toMap())
          .select('*, profiles(*)')
          .single();

      final created = SupporterModel.fromMap(response);
      Log.info('Added supporter ${created.userId} to group ${created.groupId}');
      return Right(created);
    } on PostgrestException catch (e) {
      Log.error('addSupporter error: ${e.message}');
      return Left(Failure(e.message));
    } catch (e) {
      Log.error('addSupporter error: $e');
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, void>> removeSupporter({
    required String supporterId,
  }) async {
    try {
      await supabaseClient
          .from(SupabaseTable.supporter)
          .delete()
          .eq('id', supporterId);

      Log.info('Removed supporter: $supporterId');
      return const Right(null);
    } on PostgrestException catch (e) {
      Log.error('removeSupporter error: ${e.message}');
      return Left(Failure(e.message));
    } catch (e) {
      Log.error('removeSupporter error: $e');
      return Left(Failure(e.toString()));
    }
  }
}
