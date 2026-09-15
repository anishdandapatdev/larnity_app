import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:larnity/src/core/utils/async_states.dart';
import 'package:larnity/src/features/group/data/datasource/member_datasource.dart';
import 'package:larnity/src/features/group/data/models/member_model.dart';

class MemberState {
  final AsyncState? fetchState;
  final String? error;
  final List<MemberModel>? members;
  final int? memberCount;
  final String? searchQuery;

  MemberState({this.fetchState, this.error, this.members, this.memberCount, this.searchQuery});

  MemberState copyWith({
    AsyncState? fetchState, String? error, List<MemberModel>? members,
    int? memberCount, String? searchQuery,
  }) => MemberState(
    fetchState: fetchState ?? this.fetchState,
    error: error ?? this.error,
    members: members ?? this.members,
    memberCount: memberCount ?? this.memberCount,
    searchQuery: searchQuery ?? this.searchQuery,
  );
}

final memberProvider = NotifierProvider.autoDispose
    .family<MemberNotifier, MemberState, String>(MemberNotifier.new);

class MemberNotifier extends AutoDisposeFamilyNotifier<MemberState, String> {
  @override
  MemberState build(String arg) {
    Future.microtask(() => fetchMembers());
    return MemberState(fetchState: AsyncState.initial);
  }

  String get _groupId => arg;

  Future<void> fetchMembers() async {
    final ds = ref.read(memberDataSourceProvider);
    state = state.copyWith(fetchState: AsyncState.loading);

    final result = await ds.getMembers(groupId: _groupId);
    final countResult = await ds.getMemberCount(groupId: _groupId);

    result.fold(
      (f) => state = state.copyWith(fetchState: AsyncState.failure, error: f.message),
      (members) {
        int count = members.length;
        countResult.fold((_) {}, (c) => count = c);
        state = state.copyWith(
          fetchState: AsyncState.success,
          members: members,
          memberCount: count,
        );
      },
    );
  }

  Future<void> searchMembers({required String query}) async {
    if (query.isEmpty) {
      return fetchMembers();
    }

    final ds = ref.read(memberDataSourceProvider);
    state = state.copyWith(fetchState: AsyncState.loading, searchQuery: query);

    final result = await ds.searchMembers(groupId: _groupId, query: query);
    result.fold(
      (f) => state = state.copyWith(fetchState: AsyncState.failure, error: f.message),
      (members) => state = state.copyWith(fetchState: AsyncState.success, members: members),
    );
  }

  Future<void> updateMemberRole({
    required String memberId,
    required String role,
    void Function()? successCallBack,
    void Function(String error)? failureCallBack,
  }) async {
    final ds = ref.read(memberDataSourceProvider);
    final result = await ds.updateMemberRole(memberId: memberId, role: role);
    result.fold(
      (f) => failureCallBack?.call(f.message),
      (updated) {
        state = state.copyWith(
          members: state.members?.map((m) => m.id == memberId ? updated : m).toList(),
        );
        successCallBack?.call();
      },
    );
  }

  Future<void> removeMember({
    required String memberId,
    void Function()? successCallBack,
    void Function(String error)? failureCallBack,
  }) async {
    final ds = ref.read(memberDataSourceProvider);
    final result = await ds.removeMember(memberId: memberId);
    result.fold(
      (f) => failureCallBack?.call(f.message),
      (_) {
        state = state.copyWith(
          members: state.members?.where((m) => m.id != memberId).toList(),
          memberCount: (state.memberCount ?? 1) - 1,
        );
        successCallBack?.call();
      },
    );
  }

  Future<void> blockMember({
    required String userId,
    required String blockedBy,
    String? reason,
    void Function()? successCallBack,
    void Function(String error)? failureCallBack,
  }) async {
    final ds = ref.read(memberDataSourceProvider);
    final result = await ds.blockMember(
      groupId: _groupId, userId: userId, blockedBy: blockedBy, reason: reason,
    );
    result.fold(
      (f) => failureCallBack?.call(f.message),
      (_) {
        state = state.copyWith(
          members: state.members?.where((m) => m.userId != userId).toList(),
        );
        successCallBack?.call();
      },
    );
  }
}
