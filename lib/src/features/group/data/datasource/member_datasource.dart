import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:larnity/src/core/error/failures.dart';
import 'package:larnity/src/core/service/supabase/src/supabase_provider.dart';
import 'package:larnity/src/core/service/supabase/src/supabase_table.dart';
import 'package:larnity/src/core/utils/logger.dart';
import 'package:larnity/src/features/group/data/models/member_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final memberDataSourceProvider = Provider<MemberDataSource>((ref) {
  return MemberDataSource(supabaseClient: ref.watch(supabaseClientProvider));
});

class MemberDataSource {
  final SupabaseClient supabaseClient;

  MemberDataSource({required this.supabaseClient});

  /// Get active members of a group with profile joins.
  Future<Either<Failure, List<MemberModel>>> getMembers({
    required String groupId,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await supabaseClient
          .from(SupabaseTable.members)
          .select('*, profiles(*)')
          .eq('groupId', groupId)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      final members = (response as List)
          .map((e) => MemberModel.fromMap(e as Map<String, dynamic>))
          .toList();

      Log.info('Fetched ${members.length} members for group $groupId');
      return Right(members);
    } on PostgrestException catch (e) {
      Log.error('getMembers error: ${e.message}');
      return Left(Failure(e.message));
    } catch (e) {
      Log.error('getMembers error: $e');
      return Left(Failure(e.toString()));
    }
  }

  /// Get a specific member by userId in a group.
  Future<Either<Failure, MemberModel?>> getMemberByUserId({
    required String groupId,
    required String userId,
  }) async {
    try {
      final response = await supabaseClient
          .from(SupabaseTable.members)
          .select('*, profiles(*)')
          .eq('groupId', groupId)
          .eq('userId', userId)
          .maybeSingle();

      if (response == null) return const Right(null);
      return Right(MemberModel.fromMap(response));
    } on PostgrestException catch (e) {
      Log.error('getMemberByUserId error: ${e.message}');
      return Left(Failure(e.message));
    } catch (e) {
      Log.error('getMemberByUserId error: $e');
      return Left(Failure(e.toString()));
    }
  }

  /// Add a member to a group.
  Future<Either<Failure, MemberModel>> addMember({
    required MemberModel member,
  }) async {
    try {
      Map<String, dynamic> response;
      try {
        response = await supabaseClient
            .from(SupabaseTable.members)
            .insert(member.toMap())
            .select('*, profiles(*)')
            .single();
      } catch (_) {
        response = await supabaseClient
            .from(SupabaseTable.members)
            .insert(member.toMap())
            .select()
            .single();
      }

      final created = MemberModel.fromMap(response);
      Log.info('Added member ${created.userId} to group ${created.groupId}');
      return Right(created);
    } on PostgrestException catch (e) {
      Log.error('addMember error: ${e.message}');
      return Left(Failure(e.message));
    } catch (e) {
      Log.error('addMember error: $e');
      return Left(Failure(e.toString()));
    }
  }

  /// Add or update membership for a user in a group (idempotent for renewals and re-subscriptions).
  Future<Either<Failure, MemberModel>> addOrUpdateMember({
    required MemberModel member,
  }) async {
    try {
      final existingRes = await getMemberByUserId(
        groupId: member.groupId,
        userId: member.userId,
      );

      return await existingRes.fold(
        (failure) => addMember(member: member),
        (existing) async {
          if (existing != null && existing.id != null) {
            final updateData = member.toMap()..remove('id');
            Map<String, dynamic> response;
            try {
              response = await supabaseClient
                  .from(SupabaseTable.members)
                  .update(updateData)
                  .eq('id', existing.id!)
                  .select('*, profiles(*)')
                  .single();
            } catch (_) {
              response = await supabaseClient
                  .from(SupabaseTable.members)
                  .update(updateData)
                  .eq('id', existing.id!)
                  .select()
                  .single();
            }

            final updated = MemberModel.fromMap(response);
            Log.info(
              'Updated existing membership for ${updated.userId} in group ${updated.groupId}',
            );
            return Right(updated);
          } else {
            return addMember(member: member);
          }
        },
      );
    } catch (e) {
      Log.error('addOrUpdateMember error: $e');
      return Left(Failure(e.toString()));
    }
  }

  /// Update a member's role.
  Future<Either<Failure, MemberModel>> updateMemberRole({
    required String memberId,
    required String role,
  }) async {
    try {
      final response = await supabaseClient
          .from(SupabaseTable.members)
          .update({'role': role})
          .eq('id', memberId)
          .select('*, profiles(*)')
          .single();

      final updated = MemberModel.fromMap(response);
      Log.info('Updated member $memberId role to $role');
      return Right(updated);
    } on PostgrestException catch (e) {
      Log.error('updateMemberRole error: ${e.message}');
      return Left(Failure(e.message));
    } catch (e) {
      Log.error('updateMemberRole error: $e');
      return Left(Failure(e.toString()));
    }
  }

  /// Remove a member from a group (delete).
  Future<Either<Failure, void>> removeMember({required String memberId}) async {
    try {
      await supabaseClient
          .from(SupabaseTable.members)
          .delete()
          .eq('id', memberId);

      Log.info('Removed member: $memberId');
      return const Right(null);
    } on PostgrestException catch (e) {
      Log.error('removeMember error: ${e.message}');
      return Left(Failure(e.message));
    } catch (e) {
      Log.error('removeMember error: $e');
      return Left(Failure(e.toString()));
    }
  }

  /// Block a member by adding to GroupMemberBlocks.
  Future<Either<Failure, void>> blockMember({
    required String groupId,
    required String userId,
    required String blockedBy,
    String? reason,
  }) async {
    try {
      await supabaseClient.from(SupabaseTable.groupMemberBlocks).insert({
        'groupId': groupId,
        'userId': userId,
        'blockedBy': blockedBy,
        'reason': reason,
      });

      // Member status is determined by the existence of a block in GroupMemberBlocks

      Log.info('Blocked member $userId in group $groupId');
      return const Right(null);
    } on PostgrestException catch (e) {
      Log.error('blockMember error: ${e.message}');
      return Left(Failure(e.message));
    } catch (e) {
      Log.error('blockMember error: $e');
      return Left(Failure(e.toString()));
    }
  }

  /// Get blocked members for a group.
  Future<Either<Failure, List<Map<String, dynamic>>>> getBlockedMembers({
    required String groupId,
  }) async {
    try {
      final response = await supabaseClient
          .from(SupabaseTable.groupMemberBlocks)
          .select('*, profiles(*)')
          .eq('groupId', groupId);

      Log.info('Fetched ${(response as List).length} blocked members');
      return Right(List<Map<String, dynamic>>.from(response));
    } on PostgrestException catch (e) {
      Log.error('getBlockedMembers error: ${e.message}');
      return Left(Failure(e.message));
    } catch (e) {
      Log.error('getBlockedMembers error: $e');
      return Left(Failure(e.toString()));
    }
  }

  /// Search members by name.
  Future<Either<Failure, List<MemberModel>>> searchMembers({
    required String groupId,
    required String query,
  }) async {
    try {
      final response = await supabaseClient
          .from(SupabaseTable.members)
          .select('*, profiles(*)')
          .eq('groupId', groupId)
          .or(
            'firstname.ilike.%$query%,lastname.ilike.%$query%',
            referencedTable: 'profiles',
          )
          .order('created_at', ascending: false);

      final members = (response as List)
          .map((e) => MemberModel.fromMap(e as Map<String, dynamic>))
          .toList();

      Log.info('Found ${members.length} members matching "$query"');
      return Right(members);
    } on PostgrestException catch (e) {
      Log.error('searchMembers error: ${e.message}');
      return Left(Failure(e.message));
    } catch (e) {
      Log.error('searchMembers error: $e');
      return Left(Failure(e.toString()));
    }
  }

  /// Get member count for a group.
  Future<Either<Failure, int>> getMemberCount({required String groupId}) async {
    try {
      final response = await supabaseClient
          .from(SupabaseTable.members)
          .select('id')
          .eq('groupId', groupId)
          .count(CountOption.exact);

      return Right(response.count);
    } on PostgrestException catch (e) {
      Log.error('getMemberCount error: ${e.message}');
      return Left(Failure(e.message));
    } catch (e) {
      Log.error('getMemberCount error: $e');
      return Left(Failure(e.toString()));
    }
  }
}
