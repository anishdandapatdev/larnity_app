import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:larnity/src/core/utils/async_states.dart';
import 'package:larnity/src/features/group/data/datasource/supporter_datasource.dart';
import 'package:larnity/src/features/group/data/models/supporter_model.dart';

class SupporterState {
  final AsyncState? fetchState;
  final AsyncState? createState;
  final String? error;
  final List<SupporterModel>? supporters;

  SupporterState({
    this.fetchState,
    this.createState,
    this.error,
    this.supporters,
  });

  SupporterState copyWith({
    AsyncState? fetchState,
    AsyncState? createState,
    String? error,
    List<SupporterModel>? supporters,
  }) {
    return SupporterState(
      fetchState: fetchState ?? this.fetchState,
      createState: createState ?? this.createState,
      error: error ?? this.error,
      supporters: supporters ?? this.supporters,
    );
  }
}

final supporterProvider = NotifierProvider.autoDispose
    .family<SupporterNotifier, SupporterState, String>(SupporterNotifier.new);

class SupporterNotifier
    extends AutoDisposeFamilyNotifier<SupporterState, String> {
  @override
  SupporterState build(String arg) {
    Future.microtask(() => fetchSupporters());
    return SupporterState(fetchState: AsyncState.initial);
  }

  String get _groupId => arg;

  Future<void> fetchSupporters() async {
    final ds = ref.read(supporterDataSourceProvider);
    state = state.copyWith(fetchState: AsyncState.loading);

    final result = await ds.getSupporters(groupId: _groupId);
    result.fold(
      (f) => state = state.copyWith(
        fetchState: AsyncState.failure,
        error: f.message,
      ),
      (supporters) => state = state.copyWith(
        fetchState: AsyncState.success,
        supporters: supporters,
      ),
    );
  }

  Future<void> addSupporter({
    required SupporterModel supporter,
    void Function()? successCallBack,
    void Function(String error)? failureCallBack,
  }) async {
    final ds = ref.read(supporterDataSourceProvider);
    state = state.copyWith(createState: AsyncState.loading);

    final result = await ds.addSupporter(supporter: supporter);
    result.fold(
      (f) {
        state = state.copyWith(
          createState: AsyncState.failure,
          error: f.message,
        );
        failureCallBack?.call(f.message);
      },
      (created) {
        state = state.copyWith(
          createState: AsyncState.success,
          supporters: [created, ...(state.supporters ?? [])],
        );
        successCallBack?.call();
      },
    );
  }

  Future<void> removeSupporter({
    required String supporterId,
    void Function()? successCallBack,
    void Function(String error)? failureCallBack,
  }) async {
    final ds = ref.read(supporterDataSourceProvider);
    final result = await ds.removeSupporter(supporterId: supporterId);

    result.fold((f) => failureCallBack?.call(f.message), (_) {
      state = state.copyWith(
        supporters: state.supporters
            ?.where((s) => s.id != supporterId)
            .toList(),
      );
      successCallBack?.call();
    });
  }
}
