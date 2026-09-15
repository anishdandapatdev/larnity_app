import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:larnity/src/core/utils/async_states.dart';
import 'package:larnity/src/features/group/data/datasource/treasure_datasource.dart';
import 'package:larnity/src/features/group/data/models/resource_category_model.dart';
import 'package:larnity/src/features/group/data/models/resource_model.dart';

class TreasureState {
  final AsyncState? fetchState;
  final AsyncState? createState;
  final String? error;
  final List<ResourceModel>? resources;
  final List<ResourceCategoryModel>? categories;

  TreasureState({
    this.fetchState,
    this.createState,
    this.error,
    this.resources,
    this.categories,
  });

  TreasureState copyWith({
    AsyncState? fetchState,
    AsyncState? createState,
    String? error,
    List<ResourceModel>? resources,
    List<ResourceCategoryModel>? categories,
  }) {
    return TreasureState(
      fetchState: fetchState ?? this.fetchState,
      createState: createState ?? this.createState,
      error: error ?? this.error,
      resources: resources ?? this.resources,
      categories: categories ?? this.categories,
    );
  }
}

final treasureProvider = NotifierProvider.autoDispose
    .family<TreasureNotifier, TreasureState, String>(TreasureNotifier.new);

class TreasureNotifier
    extends AutoDisposeFamilyNotifier<TreasureState, String> {
  @override
  TreasureState build(String arg) {
    Future.microtask(() => fetchResources());
    return TreasureState(fetchState: AsyncState.initial);
  }

  String get _groupId => arg;

  Future<void> fetchResources() async {
    final ds = ref.read(treasureDataSourceProvider);
    state = state.copyWith(fetchState: AsyncState.loading);

    final result = await ds.getResources(groupId: _groupId);
    result.fold(
      (f) => state = state.copyWith(
        fetchState: AsyncState.failure,
        error: f.message,
      ),
      (resources) => state = state.copyWith(
        fetchState: AsyncState.success,
        resources: resources,
      ),
    );
  }

  Future<void> addResource({
    required ResourceModel resource,
    void Function()? successCallBack,
    void Function(String error)? failureCallBack,
  }) async {
    final ds = ref.read(treasureDataSourceProvider);
    state = state.copyWith(createState: AsyncState.loading);

    final result = await ds.addResource(resource: resource);
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
          resources: [created, ...(state.resources ?? [])],
        );
        successCallBack?.call();
      },
    );
  }

  Future<void> deleteResource({
    required String resourceId,
    void Function()? successCallBack,
    void Function(String error)? failureCallBack,
  }) async {
    final ds = ref.read(treasureDataSourceProvider);
    final result = await ds.deleteResource(resourceId: resourceId);

    result.fold((f) => failureCallBack?.call(f.message), (_) {
      state = state.copyWith(
        resources: state.resources?.where((r) => r.id != resourceId).toList(),
      );
      successCallBack?.call();
    });
  }
}
