import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:larnity/src/core/utils/async_states.dart';
import 'package:larnity/src/features/group/data/datasource/live_class_datasource.dart';
import 'package:larnity/src/features/group/data/models/live_class_model.dart';

class LiveClassState {
  final AsyncState? fetchState;
  final AsyncState? createState;
  final String? error;
  final List<LiveClassModel>? liveClasses;

  LiveClassState({this.fetchState, this.createState, this.error, this.liveClasses});

  LiveClassState copyWith({
    AsyncState? fetchState, AsyncState? createState, String? error,
    List<LiveClassModel>? liveClasses,
  }) => LiveClassState(
    fetchState: fetchState ?? this.fetchState,
    createState: createState ?? this.createState,
    error: error ?? this.error,
    liveClasses: liveClasses ?? this.liveClasses,
  );
}

final liveClassProvider = NotifierProvider.autoDispose
    .family<LiveClassNotifier, LiveClassState, String>(LiveClassNotifier.new);

class LiveClassNotifier extends AutoDisposeFamilyNotifier<LiveClassState, String> {
  @override
  LiveClassState build(String arg) {
    Future.microtask(() => fetchLiveClasses());
    return LiveClassState(fetchState: AsyncState.initial);
  }

  String get _groupId => arg;

  Future<void> fetchLiveClasses() async {
    final ds = ref.read(liveClassDataSourceProvider);
    state = state.copyWith(fetchState: AsyncState.loading);
    final result = await ds.getLiveClasses(groupId: _groupId);
    result.fold(
      (f) => state = state.copyWith(fetchState: AsyncState.failure, error: f.message),
      (classes) => state = state.copyWith(fetchState: AsyncState.success, liveClasses: classes),
    );
  }

  Future<void> createLiveClass({
    required LiveClassModel liveClass,
    void Function()? successCallBack,
    void Function(String error)? failureCallBack,
  }) async {
    final ds = ref.read(liveClassDataSourceProvider);
    state = state.copyWith(createState: AsyncState.loading);
    final result = await ds.createLiveClass(liveClass: liveClass);
    result.fold(
      (f) { state = state.copyWith(createState: AsyncState.failure, error: f.message); failureCallBack?.call(f.message); },
      (created) { state = state.copyWith(createState: AsyncState.success, liveClasses: [created, ...(state.liveClasses ?? [])]); successCallBack?.call(); },
    );
  }

  Future<void> deleteLiveClass({
    required String liveClassId,
    void Function()? successCallBack,
    void Function(String error)? failureCallBack,
  }) async {
    final ds = ref.read(liveClassDataSourceProvider);
    final result = await ds.deleteLiveClass(liveClassId: liveClassId);
    result.fold(
      (f) => failureCallBack?.call(f.message),
      (_) { state = state.copyWith(liveClasses: state.liveClasses?.where((c) => c.id != liveClassId).toList()); successCallBack?.call(); },
    );
  }
}
