import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:larnity/src/core/error/failures.dart';
import 'package:larnity/src/core/service/supabase/src/supabase_provider.dart';
import 'package:larnity/src/core/service/supabase/src/supabase_table.dart';
import 'package:larnity/src/core/utils/logger.dart';
import 'package:larnity/src/features/group/data/models/challenge_model.dart';
import 'package:larnity/src/features/group/data/models/challenge_day_model.dart';
import 'package:larnity/src/features/group/data/models/challenge_registration_model.dart';
import 'package:larnity/src/features/group/data/models/challenge_submission_model.dart';
import 'package:larnity/src/features/group/data/models/challenge_winner_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final challengeDataSourceProvider = Provider<ChallengeDataSource>((ref) {
  return ChallengeDataSource(supabaseClient: ref.watch(supabaseClientProvider));
});

class ChallengeDataSource {
  final SupabaseClient supabaseClient;

  ChallengeDataSource({required this.supabaseClient});

  /// Get challenges for a group with day and registration counts.
  Future<Either<Failure, List<ChallengeModel>>> getChallenges({
    required String groupId,
    String? status,
    String? type,
  }) async {
    try {
      var query = supabaseClient
          .from(SupabaseTable.challenges)
          .select('*, ChallengeDays(count), ChallengeRegistrations(count)')
          .eq('groupId', groupId);

      if (status != null) {
        query = query.eq('status', status);
      }
      if (type != null) {
        query = query.eq('type', type);
      }

      final response = await query.order('created_at', ascending: false);

      final challenges = (response as List)
          .map((e) => ChallengeModel.fromMap(e as Map<String, dynamic>))
          .toList();

      Log.info('Fetched ${challenges.length} challenges for group $groupId');
      return Right(challenges);
    } on PostgrestException catch (e) {
      Log.error('getChallenges error: ${e.message}');
      return Left(Failure(e.message));
    } catch (e) {
      Log.error('getChallenges error: $e');
      return Left(Failure(e.toString()));
    }
  }

  /// Get challenge detail with days.
  Future<Either<Failure, ChallengeModel>> getChallengeDetail({
    required String challengeId,
  }) async {
    try {
      final response = await supabaseClient
          .from(SupabaseTable.challenges)
          .select('*, ChallengeDays(*), ChallengeRegistrations(count)')
          .eq('id', challengeId)
          .single();

      return Right(ChallengeModel.fromMap(response));
    } on PostgrestException catch (e) {
      Log.error('getChallengeDetail error: ${e.message}');
      return Left(Failure(e.message));
    } catch (e) {
      Log.error('getChallengeDetail error: $e');
      return Left(Failure(e.toString()));
    }
  }

  /// Get challenge days.
  Future<Either<Failure, List<ChallengeDayModel>>> getChallengeDays({
    required String challengeId,
  }) async {
    try {
      final response = await supabaseClient
          .from(SupabaseTable.challengeDays)
          .select('*')
          .eq('challengeId', challengeId)
          .order('dayNumber', ascending: true);

      final days = (response as List)
          .map((e) => ChallengeDayModel.fromMap(e as Map<String, dynamic>))
          .toList();

      return Right(days);
    } on PostgrestException catch (e) {
      Log.error('getChallengeDays error: ${e.message}');
      return Left(Failure(e.message));
    } catch (e) {
      Log.error('getChallengeDays error: $e');
      return Left(Failure(e.toString()));
    }
  }

  /// Register for a challenge.
  Future<Either<Failure, ChallengeRegistrationModel>> registerForChallenge({
    required String challengeId,
    required String userId,
  }) async {
    try {
      final response = await supabaseClient
          .from(SupabaseTable.challengeRegistrations)
          .insert({
            'challengeId': challengeId,
            'userId': userId,
          })
          .select()
          .single();

      Log.info('Registered for challenge $challengeId');
      return Right(ChallengeRegistrationModel.fromMap(response));
    } on PostgrestException catch (e) {
      Log.error('registerForChallenge error: ${e.message}');
      return Left(Failure(e.message));
    } catch (e) {
      Log.error('registerForChallenge error: $e');
      return Left(Failure(e.toString()));
    }
  }

  /// Check if user is registered for a challenge.
  Future<Either<Failure, bool>> isRegistered({
    required String challengeId,
    required String userId,
  }) async {
    try {
      final response = await supabaseClient
          .from(SupabaseTable.challengeRegistrations)
          .select('id')
          .eq('challengeId', challengeId)
          .eq('userId', userId)
          .maybeSingle();

      return Right(response != null);
    } on PostgrestException catch (e) {
      Log.error('isRegistered error: ${e.message}');
      return Left(Failure(e.message));
    } catch (e) {
      Log.error('isRegistered error: $e');
      return Left(Failure(e.toString()));
    }
  }

  /// Submit a daily challenge task.
  Future<Either<Failure, ChallengeSubmissionModel>> submitDailyTask({
    required ChallengeSubmissionModel submission,
  }) async {
    try {
      final response = await supabaseClient
          .from(SupabaseTable.challengeSubmissions)
          .insert(submission.toMap())
          .select()
          .single();

      Log.info('Submitted daily task for day ${submission.challengeDayId}');
      return Right(ChallengeSubmissionModel.fromMap(response));
    } on PostgrestException catch (e) {
      Log.error('submitDailyTask error: ${e.message}');
      return Left(Failure(e.message));
    } catch (e) {
      Log.error('submitDailyTask error: $e');
      return Left(Failure(e.toString()));
    }
  }

  /// Get challenge winners.
  Future<Either<Failure, List<ChallengeWinnerModel>>> getWinners({
    required String challengeId,
  }) async {
    try {
      final response = await supabaseClient
          .from(SupabaseTable.challengeWinners)
          .select('*, profiles(*)')
          .eq('challengeId', challengeId)
          .order('rank', ascending: true);

      final winners = (response as List)
          .map((e) => ChallengeWinnerModel.fromMap(e as Map<String, dynamic>))
          .toList();

      return Right(winners);
    } on PostgrestException catch (e) {
      Log.error('getWinners error: ${e.message}');
      return Left(Failure(e.message));
    } catch (e) {
      Log.error('getWinners error: $e');
      return Left(Failure(e.toString()));
    }
  }

  /// Get challenge statistics for a group.
  Future<Either<Failure, Map<String, int>>> getChallengeStats({
    required String groupId,
  }) async {
    try {
      final all = await supabaseClient
          .from(SupabaseTable.challenges)
          .select('id')
          .eq('groupId', groupId)
          .count(CountOption.exact);

      final active = await supabaseClient
          .from(SupabaseTable.challenges)
          .select('id')
          .eq('groupId', groupId)
          .eq('status', 'REGISTRATION_OPEN')
          .count(CountOption.exact);

      final live = await supabaseClient
          .from(SupabaseTable.challenges)
          .select('id')
          .eq('groupId', groupId)
          .eq('status', 'LIVE')
          .count(CountOption.exact);

      return Right({
        'total': all.count,
        'active': active.count,
        'live': live.count,
      });
    } on PostgrestException catch (e) {
      Log.error('getChallengeStats error: ${e.message}');
      return Left(Failure(e.message));
    } catch (e) {
      Log.error('getChallengeStats error: $e');
      return Left(Failure(e.toString()));
    }
  }
}
