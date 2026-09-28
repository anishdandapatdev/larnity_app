import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:larnity/src/core/service/supabase/src/supabase_provider.dart';
import 'package:larnity/src/core/service/supabase/src/supabase_table.dart';
import 'package:larnity/src/core/utils/async_states.dart';
import 'package:larnity/src/features/auth/presentation/provider/auth_provider.dart';
import 'package:larnity/src/features/explore/domain/category.dart';
import 'package:larnity/src/features/group/data/datasource/group_datasource.dart';
import 'package:larnity/src/features/group/data/datasource/member_datasource.dart';
import 'package:larnity/src/features/group/data/models/group_model.dart';

final groupProvider = NotifierProvider<GroupNotifier, GroupState>(
  GroupNotifier.new,
);

/// Checks whether the currently logged-in user is the owner or an admin of a specific group by groupId.
final isGroupAdminOrOwnerForGroupProvider =
    Provider.family<bool, String?>((ref, groupId) {
  if (groupId == null || groupId.isEmpty) return false;
  final currentUserId = ref.watch(authProvider).user?.id ??
      ref.watch(supabaseClientProvider).auth.currentUser?.id;
  if (currentUserId == null || currentUserId.isEmpty) return false;

  // 1. Check if user is creator of the group
  final activeGroup = ref.watch(groupProvider).group;
  if (activeGroup?.id == groupId && activeGroup?.userId == currentUserId) {
    return true;
  }
  final groups = ref.watch(groupProvider).groups ?? [];
  final targetGroup = groups.where((g) => g.id == groupId).firstOrNull;
  if (targetGroup != null && targetGroup.userId == currentUserId) {
    return true;
  }

  // 2. Check user's membership role in userMembershipsProvider
  final memberships = ref.watch(userMembershipsProvider).value ?? {};
  final member = memberships[groupId];
  if (member != null && member.isActive) {
    if (member.isAdmin || member.isManager || member.planType == 'OWNER') {
      return true;
    }
  }

  return false;
});

/// Checks whether the currently logged-in user is the owner or an admin of the active group.
final isGroupAdminOrOwnerProvider = Provider<bool>((ref) {
  final group = ref.watch(groupProvider).group;
  if (group == null || group.id == null) return false;
  return ref.watch(isGroupAdminOrOwnerForGroupProvider(group.id));
});

class GroupNotifier extends Notifier<GroupState> {
  TextEditingController groupNameController = TextEditingController();

  @override
  GroupState build() {
    groupNameController = TextEditingController();

    // Watch for auth state changes and refresh groups when user changes
    ref.listen(authProvider, (_, next) {
      final userId = next.user?.id ??
          ref.read(supabaseClientProvider).auth.currentUser?.id;
      if (userId != null && userId.isNotEmpty) {
        getGroupsByUser(userId: userId);
      }
    });

    Future.microtask(() async {
      final userId = ref.read(authProvider).user?.id ??
          ref.read(supabaseClientProvider).auth.currentUser?.id ??
          "";
      if (userId.isNotEmpty) {
        await getGroupsByUser(userId: userId);
      }
    });

    groupNameController.addListener(() {
      state = state.copyWith(groupName: groupNameController.text);
    });

    ref.onDispose(() {
      groupNameController.dispose();
    });

    return GroupState(fetchState: AsyncState.initial);
  }

  Future<void> createGroup({
    required GroupModel group,
    void Function()? successCallBack,
    void Function(String error)? failureCallBack,
  }) async {
    final dataSource = ref.read(groupDataSourceProvider);
    final userId = ref.read(authProvider).user?.id;

    // Check if userId is available
    if (userId == null || userId.isEmpty) {
      final error = "User not authenticated";
      state = state.copyWith(
        createState: AsyncState.failure,
        error: error,
      );
      failureCallBack?.call(error);
      return;
    }

    state = state.copyWith(createState: AsyncState.loading);
    final response = await dataSource.createGroup(group: group);

    response.fold(
      (failure) {
        state = state.copyWith(
          createState: AsyncState.failure,
          error: failure.message,
        );
        failureCallBack?.call(failure.message);
      },
      (createdGroup) async {
        // Set the created group and success state
        state = state.copyWith(
          selectedCategory: null,
          createState: AsyncState.success,
          group: createdGroup,
        );
        
        // After successfully creating a group, refresh the groups list from the database
        await getGroupsByUser(userId: userId);
        successCallBack?.call();
      },
    );
  }

  Future<void> getGroupsByUser({required String userId}) async {
    final dataSource = ref.read(groupDataSourceProvider);

    state = state.copyWith(fetchState: AsyncState.loading);
    final response = await dataSource.getGroupsByUser(userId: userId);

    response.fold(
      (failure) => state = state.copyWith(
        fetchState: AsyncState.failure,
        error: failure.message,
      ),
      (groups) {
        state = state.copyWith(
          fetchState: AsyncState.success,
          groups: groups,
        );
        // Failsafe: Auto-select the first group if none is currently selected
        if (state.group == null && groups.isNotEmpty) {
          state = state.copyWith(group: groups.first);
        }
      },
    );
  }

  Future<void> getPublicGroups() async {
    final dataSource = ref.read(groupDataSourceProvider);
    state = state.copyWith(fetchState: AsyncState.loading);

    final response = await dataSource.getPublicGroups();

    response.fold(
      (failure) => state = state.copyWith(
        fetchState: AsyncState.failure,
        error: failure.message,
      ),
      (groups) => state = state.copyWith(
        fetchState: AsyncState.success,
        exploreGroups: groups,
      ),
    );
  }

  Future<void> updateGroupStatus({
    required String id,
    required GroupStatus status,
    String? rejectionReason,
  }) async {
    final dataSource = ref.read(groupDataSourceProvider);

    state = state.copyWith(fetchState: AsyncState.loading);
    final response = await dataSource.updateGroupStatus(
      id: id,
      status: status,
      rejectionReason: rejectionReason,
    );

    response.fold(
      (failure) => state = state.copyWith(
        fetchState: AsyncState.failure,
        error: failure.message,
      ),
      (group) {
        // Update the group in the list
        final updatedGroups = state.groups?.map((g) {
          return g.id == group.id ? group : g;
        }).toList();

        state = state.copyWith(
          fetchState: AsyncState.success,
          group: group,
          groups: updatedGroups,
        );
      },
    );
  }

  Future<void> updateGroup({
    required GroupModel group,
    void Function()? successCallBack,
    void Function(String error)? failureCallBack,
  }) async {
    final currentUserId = ref.read(authProvider).user?.id ??
        ref.read(supabaseClientProvider).auth.currentUser?.id;
    final isAllowed = ref.read(isGroupAdminOrOwnerForGroupProvider(group.id)) ||
        (group.userId != null && group.userId == currentUserId);
    if (!isAllowed) {
      final error =
          "Permission denied: Only group admins or owners can update group details.";
      state = state.copyWith(
        createState: AsyncState.failure,
        error: error,
      );
      failureCallBack?.call(error);
      return;
    }

    final dataSource = ref.read(groupDataSourceProvider);
    state = state.copyWith(createState: AsyncState.loading);
    final response = await dataSource.updateGroup(group: group);

    response.fold(
      (failure) {
        state = state.copyWith(
          createState: AsyncState.failure,
          error: failure.message,
        );
        failureCallBack?.call(failure.message);
      },
      (updatedGroup) {
        final updatedGroups = state.groups?.map((g) {
          return g.id == updatedGroup.id ? updatedGroup : g;
        }).toList();

        state = state.copyWith(
          createState: AsyncState.success,
          group: updatedGroup,
          groups: updatedGroups,
        );
        successCallBack?.call();
      },
    );
  }

  Future<void> getGroupBySlug({required String slug}) async {
    final dataSource = ref.read(groupDataSourceProvider);

    state = state.copyWith(fetchState: AsyncState.loading);
    final response = await dataSource.getGroupBySlug(slug: slug);

    response.fold(
      (failure) => state = state.copyWith(
        fetchState: AsyncState.failure,
        error: failure.message,
      ),
      (group) =>
          state = state.copyWith(fetchState: AsyncState.success, group: group),
    );
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void reset() {
    state = GroupState(fetchState: AsyncState.initial);
  }

  void setSelectedGroup(GroupModel? group) {
    state = state.copyWith(group: group);
    if (group != null && group.id != null) {
      final currentUserId = ref.read(authProvider).user?.id;
      if (currentUserId != null && currentUserId == group.userId) {
        Future.microtask(() async {
          try {
            final client = ref.read(supabaseClientProvider);
            await client.from(SupabaseTable.members).upsert({
              'groupId': group.id,
              'userId': currentUserId,
              'role': 'ADMIN',
              'isActive': true,
              'planType': 'OWNER',
              'subscriptionStartDate': DateTime.now().toIso8601String(),
            }, onConflict: 'groupId,userId');
          } catch (_) {}
        });
      }
    }
  }

  void selectCategory({Category? category}) {
    if (category == null || category.name == 'All') {
      state = state.copyWith(clearSelectedCategory: true);
    } else {
      state = state.copyWith(selectedCategory: category);
    }
  }

  void clearCategory() {
    state = state.copyWith(clearSelectedCategory: true);
  }

  void refreshGroupsForCurrentUser() {
    final userId = ref.read(authProvider).user?.id ??
        ref.read(supabaseClientProvider).auth.currentUser?.id;
    if (userId != null && userId.isNotEmpty) {
      getGroupsByUser(userId: userId);
    }
  }
}

class GroupState {
  final AsyncState? fetchState;
  final AsyncState? createState;
  final String? error;
  final String? groupName;
  final GroupModel? group;
  final List<GroupModel>? groups;
  final List<GroupModel>? exploreGroups;
  final Category? selectedCategory;

  GroupState({
    this.fetchState,
    this.createState,
    this.error,
    this.groupName,
    this.group,
    this.groups,
    this.exploreGroups,
    this.selectedCategory,
  });

  GroupState copyWith({
    AsyncState? fetchState,
    AsyncState? createState,
    String? error,
    String? groupName,
    GroupModel? group,
    List<GroupModel>? groups,
    List<GroupModel>? exploreGroups,
    Category? selectedCategory,
    bool clearSelectedCategory = false,
  }) {
    return GroupState(
      fetchState: fetchState ?? this.fetchState,
      createState: createState ?? this.createState,
      error: error ?? this.error,
      groupName: groupName ?? this.groupName,
      group: group ?? this.group,
      groups: groups ?? this.groups,
      exploreGroups: exploreGroups ?? this.exploreGroups,
      selectedCategory: clearSelectedCategory
          ? null
          : (selectedCategory ?? this.selectedCategory),
    );
  }

  bool get isLoading => fetchState == AsyncState.loading;
  bool get isSuccess => fetchState == AsyncState.success;
  bool get isFailure => fetchState == AsyncState.failure;

  List<GroupModel> get publicGroups =>
      exploreGroups ??
      groups?.where((group) => group.isPublic && group.isApproved).toList() ??
      [];

  List<GroupModel> get pendingGroups =>
      groups?.where((group) => group.isPending).toList() ?? [];
}