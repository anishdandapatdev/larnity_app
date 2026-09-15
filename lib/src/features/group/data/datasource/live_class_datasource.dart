import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:larnity/src/core/error/failures.dart';
import 'package:larnity/src/core/service/supabase/src/supabase_provider.dart';
import 'package:larnity/src/core/service/supabase/src/supabase_table.dart';
import 'package:larnity/src/core/utils/logger.dart';
import 'package:larnity/src/features/group/data/models/live_class_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final liveClassDataSourceProvider = Provider<LiveClassDataSource>((ref) {
  return LiveClassDataSource(supabaseClient: ref.watch(supabaseClientProvider));
});

class LiveClassDataSource {
  final SupabaseClient supabaseClient;

  LiveClassDataSource({required this.supabaseClient});

  Future<Either<Failure, List<LiveClassModel>>> getLiveClasses({
    required String groupId,
  }) async {
    try {
      final response = await supabaseClient
          .from(SupabaseTable.liveClass)
          .select('*')
          .eq('groupId', groupId)
          .eq('type', 'LIVECLASS')
          .order('date', ascending: true)
          .order('time', ascending: true);

      final classes = (response as List)
          .map((e) => LiveClassModel.fromMap(e as Map<String, dynamic>))
          .toList();

      Log.info('Fetched ${classes.length} live classes for group $groupId');
      return Right(classes);
    } on PostgrestException catch (e) {
      Log.error('getLiveClasses error: ${e.message}');
      return Left(Failure(e.message));
    } catch (e) {
      Log.error('getLiveClasses error: $e');
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, List<LiveClassModel>>> getUpcomingLiveClasses({
    required String groupId,
  }) async {
    try {
      final response = await supabaseClient
          .from(SupabaseTable.liveClass)
          .select('*')
          .eq('groupId', groupId)
          .eq('type', 'LIVECLASS')
          .gte('date', DateTime.now().toIso8601String().split('T').first)
          .order('date', ascending: true)
          .order('time', ascending: true);

      final classes = (response as List)
          .map((e) => LiveClassModel.fromMap(e as Map<String, dynamic>))
          .toList();

      Log.info('Fetched ${classes.length} upcoming live classes');
      return Right(classes);
    } on PostgrestException catch (e) {
      Log.error('getUpcomingLiveClasses error: ${e.message}');
      return Left(Failure(e.message));
    } catch (e) {
      Log.error('getUpcomingLiveClasses error: $e');
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, LiveClassModel>> createLiveClass({
    required LiveClassModel liveClass,
  }) async {
    try {
      final response = await supabaseClient
          .from(SupabaseTable.liveClass)
          .insert(liveClass.toMap())
          .select()
          .single();

      final created = LiveClassModel.fromMap(response);
      Log.info('Created live class: ${created.id}');
      return Right(created);
    } on PostgrestException catch (e) {
      Log.error('createLiveClass error: ${e.message}');
      return Left(Failure(e.message));
    } catch (e) {
      Log.error('createLiveClass error: $e');
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, LiveClassModel>> updateLiveClass({
    required LiveClassModel liveClass,
  }) async {
    try {
      final response = await supabaseClient
          .from(SupabaseTable.liveClass)
          .update(liveClass.toMap())
          .eq('id', liveClass.id!)
          .select()
          .single();

      final updated = LiveClassModel.fromMap(response);
      Log.info('Updated live class: ${updated.id}');
      return Right(updated);
    } on PostgrestException catch (e) {
      Log.error('updateLiveClass error: ${e.message}');
      return Left(Failure(e.message));
    } catch (e) {
      Log.error('updateLiveClass error: $e');
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, void>> deleteLiveClass({
    required String liveClassId,
  }) async {
    try {
      await supabaseClient
          .from(SupabaseTable.liveClass)
          .delete()
          .eq('id', liveClassId);

      Log.info('Deleted live class: $liveClassId');
      return const Right(null);
    } on PostgrestException catch (e) {
      Log.error('deleteLiveClass error: ${e.message}');
      return Left(Failure(e.message));
    } catch (e) {
      Log.error('deleteLiveClass error: $e');
      return Left(Failure(e.toString()));
    }
  }
}
