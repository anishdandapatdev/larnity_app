import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:larnity/src/core/error/failures.dart';
import 'package:larnity/src/core/service/supabase/src/supabase_provider.dart';
import 'package:larnity/src/core/service/supabase/src/supabase_table.dart';
import 'package:larnity/src/core/utils/logger.dart';
import 'package:larnity/src/features/group/data/models/event_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final eventDataSourceProvider = Provider<EventDataSource>((ref) {
  return EventDataSource(supabaseClient: ref.watch(supabaseClientProvider));
});

class EventDataSource {
  final SupabaseClient supabaseClient;

  EventDataSource({required this.supabaseClient});

  Future<Either<Failure, List<EventModel>>> getEvents({
    required String groupId,
  }) async {
    try {
      final response = await supabaseClient
          .from(SupabaseTable.event)
          .select('*')
          .eq('groupId', groupId)
          .isFilter('type', null)
          .order('date', ascending: true)
          .order('time', ascending: true);

      final events = (response as List)
          .map((e) => EventModel.fromMap(e as Map<String, dynamic>))
          .toList();

      Log.info('Fetched ${events.length} events for group $groupId');
      return Right(events);
    } on PostgrestException catch (e) {
      Log.error('getEvents error: ${e.message}');
      return Left(Failure(e.message));
    } catch (e) {
      Log.error('getEvents error: $e');
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, List<EventModel>>> getUpcomingEvents({
    required String groupId,
  }) async {
    try {
      final response = await supabaseClient
          .from(SupabaseTable.event)
          .select('*')
          .eq('groupId', groupId)
          .isFilter('type', null)
          .gte('date', DateTime.now().toIso8601String().split('T').first)
          .order('date', ascending: true)
          .order('time', ascending: true);

      final events = (response as List)
          .map((e) => EventModel.fromMap(e as Map<String, dynamic>))
          .toList();

      Log.info('Fetched ${events.length} upcoming events');
      return Right(events);
    } on PostgrestException catch (e) {
      Log.error('getUpcomingEvents error: ${e.message}');
      return Left(Failure(e.message));
    } catch (e) {
      Log.error('getUpcomingEvents error: $e');
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, EventModel>> createEvent({
    required EventModel event,
  }) async {
    try {
      final response = await supabaseClient
          .from(SupabaseTable.event)
          .insert(event.toMap())
          .select()
          .single();

      final created = EventModel.fromMap(response);
      Log.info('Created event: ${created.id}');
      return Right(created);
    } on PostgrestException catch (e) {
      Log.error('createEvent error: ${e.message}');
      return Left(Failure(e.message));
    } catch (e) {
      Log.error('createEvent error: $e');
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, EventModel>> updateEvent({
    required EventModel event,
  }) async {
    try {
      final response = await supabaseClient
          .from(SupabaseTable.event)
          .update(event.toMap())
          .eq('id', event.id!)
          .select()
          .single();

      final updated = EventModel.fromMap(response);
      Log.info('Updated event: ${updated.id}');
      return Right(updated);
    } on PostgrestException catch (e) {
      Log.error('updateEvent error: ${e.message}');
      return Left(Failure(e.message));
    } catch (e) {
      Log.error('updateEvent error: $e');
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, void>> deleteEvent({
    required String eventId,
  }) async {
    try {
      await supabaseClient
          .from(SupabaseTable.event)
          .delete()
          .eq('id', eventId);

      Log.info('Deleted event: $eventId');
      return const Right(null);
    } on PostgrestException catch (e) {
      Log.error('deleteEvent error: ${e.message}');
      return Left(Failure(e.message));
    } catch (e) {
      Log.error('deleteEvent error: $e');
      return Left(Failure(e.toString()));
    }
  }
}
