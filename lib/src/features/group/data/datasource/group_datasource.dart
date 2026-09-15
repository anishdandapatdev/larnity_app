import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:larnity/src/core/error/failures.dart';
import 'package:larnity/src/core/service/supabase/src/supabase_provider.dart';
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

      return Right(GroupModel.fromMap(response));
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
      // Fetch groups created by the user
      final ownedResponse = await supabaseClient
          .from('Group')
          .select()
          .eq('userId', userId)
          .order('created_at', ascending: false);

      final ownedGroups = (ownedResponse as List)
          .map((data) => GroupModel.fromMap(data))
          .toList();

      // Fetch groups where user is a member
      final memberResponse = await supabaseClient
          .from('Members')
          .select('groupId, Group(*)')
          .eq('userId', userId);

      final joinedGroups = <GroupModel>[];
      for (var row in memberResponse as List) {
        if (row['Group'] != null) {
          try {
            joinedGroups.add(GroupModel.fromMap(row['Group']));
          } catch (e) {
            Log.error("Error parsing joined group: $e");
          }
        }
      }

      // Combine and deduplicate
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
      final response = await supabaseClient
          .from('Group')
          .select()
          .eq('privacy', 'PUBLIC')
          .eq('active', true)
          .eq('status', 'APPROVED')
          .eq('isSuspended', false)
          .order('created_at', ascending: false);

      final groups = response.map((data) => GroupModel.fromMap(data)).toList();

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
