import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:larnity/src/core/utils/async_states.dart';
import 'package:larnity/src/features/group/data/datasource/product_service_datasource.dart';
import 'package:larnity/src/features/group/data/models/product_service_model.dart';

class ServiceState {
  final AsyncState? fetchState;
  final AsyncState? createState;
  final String? error;
  final List<ProductServiceModel>? services;

  ServiceState({this.fetchState, this.createState, this.error, this.services});

  ServiceState copyWith({
    AsyncState? fetchState, AsyncState? createState, String? error,
    List<ProductServiceModel>? services,
  }) => ServiceState(
    fetchState: fetchState ?? this.fetchState,
    createState: createState ?? this.createState,
    error: error ?? this.error,
    services: services ?? this.services,
  );
}

final serviceProvider = NotifierProvider.autoDispose
    .family<ServiceNotifier, ServiceState, String>(ServiceNotifier.new);

class ServiceNotifier extends AutoDisposeFamilyNotifier<ServiceState, String> {
  @override
  ServiceState build(String arg) {
    Future.microtask(() => fetchServices());
    return ServiceState(fetchState: AsyncState.initial);
  }

  String get _groupId => arg;

  Future<void> fetchServices() async {
    final ds = ref.read(productServiceDataSourceProvider);
    state = state.copyWith(fetchState: AsyncState.loading);
    final result = await ds.getItems(groupId: _groupId, type: 'SERVICE');
    result.fold(
      (f) => state = state.copyWith(fetchState: AsyncState.failure, error: f.message),
      (services) => state = state.copyWith(fetchState: AsyncState.success, services: services),
    );
  }

  Future<void> createService({
    required ProductServiceModel service,
    void Function()? successCallBack,
    void Function(String error)? failureCallBack,
  }) async {
    final ds = ref.read(productServiceDataSourceProvider);
    state = state.copyWith(createState: AsyncState.loading);
    final item = service.copyWith(type: 'SERVICE');
    final result = await ds.createItem(item: item);
    result.fold(
      (f) { state = state.copyWith(createState: AsyncState.failure, error: f.message); failureCallBack?.call(f.message); },
      (created) { state = state.copyWith(createState: AsyncState.success, services: [created, ...(state.services ?? [])]); successCallBack?.call(); },
    );
  }

  Future<void> deleteService({
    required String serviceId,
    void Function()? successCallBack,
    void Function(String error)? failureCallBack,
  }) async {
    final ds = ref.read(productServiceDataSourceProvider);
    final result = await ds.deleteItem(itemId: serviceId);
    result.fold(
      (f) => failureCallBack?.call(f.message),
      (_) { state = state.copyWith(services: state.services?.where((s) => s.id != serviceId).toList()); successCallBack?.call(); },
    );
  }
}
