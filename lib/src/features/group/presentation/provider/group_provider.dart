import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:larnity/src/core/service/supabase/src/supabase_provider.dart';
import 'package:larnity/src/core/service/supabase/src/supabase_table.dart';
import 'package:larnity/src/core/utils/async_states.dart';
import 'package:larnity/src/features/auth/presentation/provider/auth_provider.dart';
import 'package:larnity/src/features/explore/domain/category.dart';
import 'package:larnity/src/features/group/data/datasource/group_datasource.dart';
import 'package:larnity/src/features/group/data/models/group_model.dart';

final groupProvider = NotifierProvider<GroupNotifier, GroupState>(
  GroupNotifier.new,
);

/// Checks whether the currently logged-in user is the owner or an admin of the active group.
final isGroupAdminOrOwnerProvider = Provider<bool>((ref) {
  final group = ref.watch(groupProvider).group;
  final currentUserId = ref.watch(authProvider).user?.id;
  if (group == null || currentUserId == null || currentUserId.isEmpty) {
    return false;
  }
  // Group creator is always owner/admin
  if (group.userId != null && group.userId == currentUserId) {
    return true;
  }
  return false;
});

class GroupNotifier extends Notifier<GroupState> {
  TextEditingController groupNameController = TextEditingController();

  @override
  GroupState build() {
    groupNameController = TextEditingController();

    // Watch for auth state changes and refresh groups when user changes
    ref.listen(authProvider, (_, next) {
      final userId = next.user?.id;
      if (userId != null && userId.isNotEmpty) {
        getGroupsByUser(userId: userId);
      }
    });

    Future.microtask(() async {
      final userId = ref.read(authProvider).user?.id ?? "";
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
    final userId = ref.read(authProvider).user?.id;
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