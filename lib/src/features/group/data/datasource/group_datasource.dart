import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:larnity/src/core/error/failures.dart';
import 'package:larnity/src/core/service/supabase/src/supabase_provider.dart';
import 'package:larnity/src/core/service/supabase/src/supabase_table.dart';
import 'package:larnity/src/core/utils/logger.dart';
import 'package:larnity/src/features/group/data/models/group_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final groupDataSourceProvider = Provider<GroupDataSource>((ref) {
  return GroupDataSource(supabaseClient: ref.watch(supabaseClientProvider));
});

class GroupDataSource {
  final SupabaseClient supabaseClient;

  GroupDataSource({required this.supabaseClient});

  Future<Either<Failure, GroupModel>> createGroup({
    required GroupModel group,
  }) async {
    try {
      final response = await supabaseClient
          .from('Group')
          .insert(group.toMap())
          .select()
          .single();

      Log.info("Create Group Response: ${response.toString()}");
      final createdGroup = GroupModel.fromMap(response);

      // Auto-enroll the creator as ADMIN in Members table so they have permissions
      final ownerId = group.userId ?? supabaseClient.auth.currentUser?.id;
      if (createdGroup.id != null && ownerId != null) {
        try {
          await supabaseClient.from(SupabaseTable.members).upsert({
            'groupId': createdGroup.id,
            'userId': ownerId,
            'role': 'ADMIN',
            'isActive': true,
            'planType': 'OWNER',
            'subscriptionStartDate': DateTime.now().toIso8601String(),
          }, onConflict: 'groupId,userId');
          Log.info("Auto-enrolled group creator $ownerId as ADMIN in Members");
        } catch (memberErr) {
          Log.warning("Could not auto-enroll creator in Members: $memberErr");
        }
      }

      return Right(createdGroup);
    } on PostgrestException catch (e) {
      Log.error("Create Group Error: ${e.message}");
      return Left(Failure(e.message));
    } catch (e) {
      Log.error("Create Group Error: ${e.toString()}");
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, GroupModel>> getGroup({required String id}) async {
    try {
      final response = await supabaseClient
          .from('Group')
          .select()
          .eq('id', id)
          .single();

      return Right(GroupModel.fromMap(response));
    } on PostgrestException catch (e) {
      Log.error("Get Group Error: ${e.message}");
      return Left(Failure(e.message));
    } catch (e) {
      Log.error("Get Group Error: ${e.toString()}");
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, List<GroupModel>>> getGroupsByUser({
    required String userId,
  }) async {
    try {
      // 1. Fetch groups created/owned by the user
      final ownedResponse = await supabaseClient
          .from('Group')
          .select()
          .eq('userId', userId)
          .order('created_at', ascending: false);

      final ownedGroups = <GroupModel>[];
      for (var data in ownedResponse as List) {
        try {
          ownedGroups.add(GroupModel.fromMap(data as Map<String, dynamic>));
        } catch (e) {
          Log.error("Error parsing owned group: $e");
        }
      }

      // 2. Fetch groups where user is an active member
      final joinedGroups = <GroupModel>[];
      try {
        final memberRows = await supabaseClient
            .from(SupabaseTable.members)
            .select('groupId')
            .eq('userId', userId);

        final groupIds = (memberRows as List)
            .map((r) => r['groupId']?.toString())
            .whereType<String>()
            .where((id) => id.isNotEmpty)
            .toSet()
            .toList();

        if (groupIds.isNotEmpty) {
          final joinedResponse = await supabaseClient
              .from('Group')
              .select()
              .inFilter('id', groupIds);

          for (var data in joinedResponse as List) {
            try {
              joinedGroups.add(
                GroupModel.fromMap(data as Map<String, dynamic>),
              );
            } catch (e) {
              Log.error("Error parsing joined group: $e");
            }
          }
        }
      } catch (e) {
        Log.error("Error fetching joined groups for $userId: $e");
      }

      // 3. Combine and deduplicate
      final allGroupsMap = <String, GroupModel>{};
      for (var g in ownedGroups) {
        if (g.id != null) allGroupsMap[g.id!] = g;
      }
      for (var g in joinedGroups) {
        if (g.id != null) allGroupsMap[g.id!] = g;
      }

      final allGroups = allGroupsMap.values.toList();
      allGroups.sort(
        (a, b) => (b.createdAt ?? DateTime.now()).compareTo(
          a.createdAt ?? DateTime.now(),
        ),
      );

      return Right(allGroups);
    } on PostgrestException catch (e) {
      Log.error("Get Groups by User Error: ${e.message}");
      return Left(Failure(e.message));
    } catch (e) {
      Log.error("Get Groups by User Error: ${e.toString()}");
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, List<GroupModel>>> getPublicGroups() async {
    try {
      dynamic response;
      try {
        // Try fetching groups with related member count aggregation
        response = await supabaseClient
            .from('Group')
            .select('*, Members(count)')
            .order('created_at', ascending: false);
      } catch (relError) {
        Log.warning("select with Members(count) failed: $relError; trying basic select");
        response = await supabaseClient
            .from('Group')
            .select()
            .order('created_at', ascending: false);
      }

      if (response is List && response.isNotEmpty) {
        final sample = response.first as Map;
        Log.info("SUPABASE GROUP TABLE COLUMNS: ${sample.keys.toList()}");
        Log.info("SUPABASE GROUP SAMPLE: $sample");
      }

      // Fetch member count aggregates from Members table as fallback
      final memberCounts = <String, int>{};
      try {
        final membersRes = await supabaseClient
            .from('Members')
            .select('groupId');
        Log.info("MEMBERS RES COUNT: ${(membersRes as List).length}");
        for (var row in membersRes as List) {
          final gId = row['groupId']?.toString();
          if (gId != null && gId.isNotEmpty) {
            memberCounts[gId] = (memberCounts[gId] ?? 0) + 1;
          }
        }
      } catch (e) {
        Log.warning("Could not fetch member counts from Members table: $e");
      }

      final groups = <GroupModel>[];
      for (var data in response) {
        try {
          final map = Map<String, dynamic>.from(data as Map);
          final gId = map['id']?.toString();
          if (gId != null && memberCounts.containsKey(gId) && !map.containsKey('memberCount')) {
            map['memberCount'] = memberCounts[gId];
          }
          final group = GroupModel.fromMap(map);
          // Exclude suspended and private groups
          final isNotSuspended = group.isSuspended != true;
          final isNotPrivate = group.privacy != GroupPrivacy.PRIVATE;
          if (isNotSuspended && isNotPrivate) {
            groups.add(group);
          }
        } catch (e) {
          Log.error("Error parsing public group: $e");
        }
      }

      // Sort by member count (popular / most joined first), then by newest
      groups.sort((a, b) {
        final countA = a.memberCount ?? 0;
        final countB = b.memberCount ?? 0;
        if (countA != countB) {
          return countB.compareTo(countA); // Highest member count first
        }
        return (b.createdAt ?? DateTime.now()).compareTo(
          a.createdAt ?? DateTime.now(),
        );
      });

      return Right(groups);
    } on PostgrestException catch (e) {
      Log.error("Get Public Groups Error: ${e.message}");
      return Left(Failure(e.message));
    } catch (e) {
      Log.error("Get Public Groups Error: ${e.toString()}");
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, List<GroupModel>>> getPendingGroups() async {
    try {
      final response = await supabaseClient
          .from('Group')
          .select()
          .eq('status', 'CREATED')
          .order('created_at', ascending: false);

      final groups = response.map((data) => GroupModel.fromMap(data)).toList();

      return Right(groups);
    } on PostgrestException catch (e) {
      Log.error("Get Pending Groups Error: ${e.message}");
      return Left(Failure(e.message));
    } catch (e) {
      Log.error("Get Pending Groups Error: ${e.toString()}");
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, GroupModel>> updateGroup({
    required GroupModel group,
  }) async {
    try {
      final response = await supabaseClient
          .from('Group')
          .update(group.toMap())
          .eq('id', group.id ?? "")
          .select()
          .single();

      Log.info("Update Group Response: ${response.toString()}");

      return Right(GroupModel.fromMap(response));
    } on PostgrestException catch (e) {
      Log.error("Update Group Error: ${e.message}");
      return Left(Failure(e.message));
    } catch (e) {
      Log.error("Update Group Error: ${e.toString()}");
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, GroupModel>> updateGroupStatus({
    required String id,
    required GroupStatus status,
    String? rejectionReason,
  }) async {
    try {
      final updateData = {
        'status': status.name,
        'updated_at': DateTime.now().toIso8601String(),
        if (rejectionReason != null) 'rejectionReason': rejectionReason,
      };

      final response = await supabaseClient
          .from('Group')
          .update(updateData)
          .eq('id', id)
          .select()
          .single();

      Log.info("Update Group Status Response: ${response.toString()}");

      return Right(GroupModel.fromMap(response));
    } on PostgrestException catch (e) {
      Log.error("Update Group Status Error: ${e.message}");
      return Left(Failure(e.message));
    } catch (e) {
      Log.error("Update Group Status Error: ${e.toString()}");
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, void>> deleteGroup({required String id}) async {
    try {
      await supabaseClient.from('Group').delete().eq('id', id);

      Log.info("Delete Group Success for ID: $id");

      return const Right(null);
    } on PostgrestException catch (e) {
      Log.error("Delete Group Error: ${e.message}");
      return Left(Failure(e.message));
    } catch (e) {
      Log.error("Delete Group Error: ${e.toString()}");
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, GroupModel?>> getGroupBySlug({
    required String slug,
  }) async {
    try {
      final response = await supabaseClient
          .from('Group')
          .select()
          .eq('slug', slug)
          .eq('active', true)
          .eq('isSuspended', false)
          .maybeSingle();

      if (response == null) {
        return const Right(null);
      }

      return Right(GroupModel.fromMap(response));
    } on PostgrestException catch (e) {
      Log.error("Get Group by Slug Error: ${e.message}");
      return Left(Failure(e.message));
    } catch (e) {
      Log.error("Get Group by Slug Error: ${e.toString()}");
      return Left(Failure(e.toString()));
    }
  }
}
