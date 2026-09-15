import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:larnity/src/core/utils/async_states.dart';
import 'package:larnity/src/features/group/data/datasource/challenge_datasource.dart';
import 'package:larnity/src/features/group/data/models/challenge_model.dart';
import 'package:larnity/src/features/group/data/models/challenge_day_model.dart';

class ChallengeState {
  final AsyncState? fetchState;
  final AsyncState? detailState;
  final String? error;
  final List<ChallengeModel>? challenges;
  final ChallengeModel? selectedChallenge;
  final List<ChallengeDayModel>? challengeDays;
  final Map<String, int>? stats;
  final String? statusFilter;
  final String? typeFilter;

  ChallengeState({
    this.fetchState, this.detailState, this.error, this.challenges,
    this.selectedChallenge, this.challengeDays, this.stats,
    this.statusFilter, this.typeFilter,
  });

  ChallengeState copyWith({
    AsyncState? fetchState, AsyncState? detailState, String? error,
    List<ChallengeModel>? challenges, ChallengeModel? selectedChallenge,
    List<ChallengeDayModel>? challengeDays, Map<String, int>? stats,
    String? statusFilter, String? typeFilter,
  }) => ChallengeState(
    fetchState: fetchState ?? this.fetchState,
    detailState: detailState ?? this.detailState,
    error: error ?? this.error,
    challenges: challenges ?? this.challenges,
    selectedChallenge: selectedChallenge ?? this.selectedChallenge,
    challengeDays: challengeDays ?? this.challengeDays,
    stats: stats ?? this.stats,
    statusFilter: statusFilter ?? this.statusFilter,
    typeFilter: typeFilter ?? this.typeFilter,
  );
}

final challengeProvider = NotifierProvider.autoDispose
    .family<ChallengeNotifier, ChallengeState, String>(ChallengeNotifier.new);

class ChallengeNotifier extends AutoDisposeFamilyNotifier<ChallengeState, String> {
  @override
  ChallengeState build(String arg) {
    Future.microtask(() {
      fetchChallenges();
      fetchStats();
    });
    return ChallengeState(fetchState: AsyncState.initial);
  }

  String get _groupId => arg;

  Future<void> fetchChallenges({String? status, String? type}) async {
    final ds = ref.read(challengeDataSourceProvider);
    state = state.copyWith(
      fetchState: AsyncState.loading,
      statusFilter: status,
      typeFilter: type,
    );

    final result = await ds.getChallenges(
      groupId: _groupId, status: status, type: type,
    );
    result.fold(
      (f) => state = state.copyWith(fetchState: AsyncState.failure, error: f.message),
      (challenges) => state = state.copyWith(fetchState: AsyncState.success, challenges: challenges),
    );
  }

  Future<void> fetchStats() async {
    final ds = ref.read(challengeDataSourceProvider);
    final result = await ds.getChallengeStats(groupId: _groupId);
    result.fold((_) {}, (stats) => state = state.copyWith(stats: stats));
  }

  Future<void> fetchChallengeDetail({required String challengeId}) async {
    final ds = ref.read(challengeDataSourceProvider);
    state = state.copyWith(detailState: AsyncState.loading);
    final result = await ds.getChallengeDetail(challengeId: challengeId);
    result.fold(
      (f) => state = state.copyWith(detailState: AsyncState.failure, error: f.message),
      (challenge) => state = state.copyWith(detailState: AsyncState.success, selectedChallenge: challenge),
    );
  }

  Future<void> fetchChallengeDays({required String challengeId}) async {
    final ds = ref.read(challengeDataSourceProvider);
    final result = await ds.getChallengeDays(challengeId: challengeId);
    result.fold((_) {}, (days) => state = state.copyWith(challengeDays: days));
  }

  Future<void> registerForChallenge({
    required String challengeId,
    required String userId,
    void Function()? successCallBack,
    void Function(String error)? failureCallBack,
  }) async {
    final ds = ref.read(challengeDataSourceProvider);
    final result = await ds.registerForChallenge(challengeId: challengeId, userId: userId);
    result.fold(
      (f) => failureCallBack?.call(f.message),
      (_) { fetchStats(); successCallBack?.call(); },
    );
  }
}
