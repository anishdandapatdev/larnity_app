// ignore_for_file: camel_case_types

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:larnity/src/core/utils/async_states.dart';
import 'package:larnity/src/features/package/data/datasource/package_datasource.dart';
import 'package:larnity/src/features/package/data/model/package_model.dart';

final packageProvider = NotifierProvider<packageNotifier, packageState>(
  packageNotifier.new,
);

class packageNotifier extends Notifier<packageState> {
  @override
  packageState build() {
    // final packageSubscriptionNotifier = ref.read(
    //   packageSubscriptionProvider.notifier,
    // );
    Future.microtask(() async {
      // await packageSubscriptionNotifier.getActiveSubscriptionByUser(
      //   userId: ref.watch(authProvider).user?.id ?? "",
      // );
      await getAllPackages();
    });
    return packageState(state: AsyncState.initial);
  }

  Future<void> getAllPackages({bool activeOnly = true}) async {
    final dataSource = ref.read(packageDataSourceProvider);

    state = state.copyWith(state: AsyncState.loading);
    final response = await dataSource.getAllPackages(activeOnly: activeOnly);

    response.fold(
      (failure) => state = state.copyWith(
        state: AsyncState.failure,
        error: failure.message,
      ),
      (packages) =>
          state = state.copyWith(state: AsyncState.success, packages: packages),
    );
  }

  Future<void> getActivePackages() async {
    final dataSource = ref.read(packageDataSourceProvider);

    state = state.copyWith(state: AsyncState.loading);
    final response = await dataSource.getActivePackages();

    response.fold(
      (failure) => state = state.copyWith(
        state: AsyncState.failure,
        error: failure.message,
      ),
      (packages) =>
          state = state.copyWith(state: AsyncState.success, packages: packages),
    );
  }

  Future<void> getFreeTrialPackage() async {
    final dataSource = ref.read(packageDataSourceProvider);

    state = state.copyWith(state: AsyncState.loading);
    final response = await dataSource.getFreeTrialPackage();

    response.fold(
      (failure) => state = state.copyWith(
        state: AsyncState.failure,
        error: failure.message,
      ),
      (package) => state = state.copyWith(
        state: AsyncState.success,
        freeTrialPackage: package,
      ),
    );
  }

  Future<void> getPackage({required String packageId}) async {
    final dataSource = ref.read(packageDataSourceProvider);

    state = state.copyWith(state: AsyncState.loading);
    final response = await dataSource.getPackage(packageId: packageId);

    response.fold(
      (failure) => state = state.copyWith(
        state: AsyncState.failure,
        error: failure.message,
      ),
      (package) => state = state.copyWith(
        state: AsyncState.success,
        selectedPackage: package,
      ),
    );
  }

  Future<void> createPackage({
    required PackageModel package,
    void Function()? successCallBack,
    void Function(String error)? failureCallBack,
  }) async {
    final dataSource = ref.read(packageDataSourceProvider);

    state = state.copyWith(state: AsyncState.loading);
    final response = await dataSource.createPackage(package: package);

    response.fold(
      (failure) {
        state = state.copyWith(
          state: AsyncState.failure,
          error: failure.message,
        );
        failureCallBack?.call(failure.message);
      },
      (package) {
        final List<PackageModel> updatedPackages = [
          ...state.packages ?? [],
          package,
        ];
        state = state.copyWith(
          state: AsyncState.success,
          selectedPackage: package,
          packages: updatedPackages,
        );
        successCallBack?.call();
      },
    );
  }

  Future<void> updatePackage({required PackageModel package}) async {
    final dataSource = ref.read(packageDataSourceProvider);

    state = state.copyWith(state: AsyncState.loading);
    final response = await dataSource.updatePackage(package: package);

    response.fold(
      (failure) => state = state.copyWith(
        state: AsyncState.failure,
        error: failure.message,
      ),
      (updatedPackage) {
        // Update the package in the list
        final updatedPackages = state.packages?.map((p) {
          return p.id == updatedPackage.id ? updatedPackage : p;
        }).toList();

        state = state.copyWith(
          state: AsyncState.success,
          selectedPackage: updatedPackage,
          packages: updatedPackages,
        );
      },
    );
  }

  void setSelectedPackage(PackageModel? package) {
    state = state.copyWith(selectedPackage: package);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void reset() {
    state = packageState(state: AsyncState.initial);
  }
}

class packageState {
  final AsyncState? state;
  final String? error;
  final PackageModel? selectedPackage;
  final PackageModel? freeTrialPackage;
  final List<PackageModel>? packages;

  packageState({
    this.state,
    this.error,
    this.selectedPackage,
    this.freeTrialPackage,
    this.packages,
  });

  packageState copyWith({
    AsyncState? state,
    String? error,
    PackageModel? selectedPackage,
    PackageModel? freeTrialPackage,
    List<PackageModel>? packages,
  }) {
    return packageState(
      state: state ?? this.state,
      error: error ?? this.error,
      selectedPackage: selectedPackage ?? this.selectedPackage,
      freeTrialPackage: freeTrialPackage ?? this.freeTrialPackage,
      packages: packages ?? this.packages,
    );
  }

  bool get isLoading => state == AsyncState.loading;
  bool get isSuccess => state == AsyncState.success;
  bool get isFailure => state == AsyncState.failure;

  List<PackageModel> get activePackages =>
      packages?.where((p) => p.isActive).toList() ?? [];

  List<PackageModel> get paidPackages =>
      activePackages.where((p) => !p.isFree && !p.isFreeTrialPack).toList();

  List<PackageModel> get freePackages =>
      activePackages.where((p) => p.isFree).toList();

  PackageModel? get recommendedPackage {
    final active = activePackages;
    if (active.isEmpty) return null;
    // Return the package with highest display order (usually the premium one)
    return active.reduce((a, b) => a.displayOrder > b.displayOrder ? a : b);
  }

  PackageModel? get basicPackage {
    final active = activePackages;
    if (active.isEmpty) return null;
    // Return the package with lowest display order (usually the basic one)
    return active.reduce((a, b) => a.displayOrder < b.displayOrder ? a : b);
  }
}
