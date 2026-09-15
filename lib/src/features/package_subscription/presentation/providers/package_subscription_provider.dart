import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:larnity/src/core/utils/async_states.dart';
import 'package:larnity/src/features/auth/presentation/provider/auth_provider.dart';
import 'package:larnity/src/features/package_subscription/data/datasource/package_subscription_datasource.dart';
import 'package:larnity/src/features/package_subscription/data/model/package_subscription_model.dart';

final packageSubscriptionProvider =
    NotifierProvider<PackageSubscriptionNotifier, PackageSubscriptionState>(
      PackageSubscriptionNotifier.new,
    );

class PackageSubscriptionNotifier extends Notifier<PackageSubscriptionState> {
  @override
  PackageSubscriptionState build() {
    // Reactively re-fetch whenever the authenticated user changes.
    // This handles the Google sign-in case where user.id is null at build
    // time but becomes available only after the profile upsert completes.
    ref.listen(authProvider, (previous, next) {
      final userId = next.user?.id;
      final prevId = previous?.user?.id;
      if (userId != null && userId.isNotEmpty && userId != prevId) {
        getActiveSubscriptionByUser(userId: userId);
      }
    });

    // Also try immediately in case the user is already loaded.
    Future.microtask(() async {
      final userId = ref.read(authProvider).user?.id ?? "";
      if (userId.isNotEmpty) {
        await getActiveSubscriptionByUser(userId: userId);
      }
    });

    return PackageSubscriptionState(state: AsyncState.initial);
  }

  Future<void> createPackageSubscription({
    required PackageSubscriptionModel subscription,
    void Function()? successCallBack,
    void Function(String error)? failureCallBack,
  }) async {
    final dataSource = ref.read(packageSubscriptionDataSourceProvider);

    state = state.copyWith(state: AsyncState.loading);
    final response = await dataSource.createPackageSubscription(
      subscription: subscription,
    );

    response.fold(
      (failure) {
        state = state.copyWith(
          state: AsyncState.failure,
          error: failure.message,
        );
        failureCallBack?.call(failure.message);
      },
      (subscription) async {
        final List<PackageSubscriptionModel> updatedSubscriptions = [
          ...state.subscriptions ?? [],
          subscription,
        ];
        await getActiveSubscriptionByUser(
          userId: ref.watch(authProvider).user?.id ?? "",
        );
        state = state.copyWith(
          state: AsyncState.success,
          activeSubscription:
              subscription.isValid != null && subscription.isValid!
              ? subscription
              : state.activeSubscription,
          subscriptions: updatedSubscriptions,
        );
        successCallBack?.call();
      },
    );
  }

  Future<void> getActiveSubscriptionByUser({required String userId}) async {
    final dataSource = ref.read(packageSubscriptionDataSourceProvider);

    state = state.copyWith(state: AsyncState.loading);
    final response = await dataSource.getActiveSubscriptionByUser(
      userId: userId,
    );

    response.fold(
      (failure) => state = state.copyWith(
        state: AsyncState.failure,
        error: failure.message,
      ),
      (subscription) => state = state.copyWith(
        state: AsyncState.success,
        activeSubscription: subscription,
      ),
    );
  }

  Future<void> getSubscriptionsByUser({required String userId}) async {
    final dataSource = ref.read(packageSubscriptionDataSourceProvider);

    state = state.copyWith(state: AsyncState.loading);
    final response = await dataSource.getSubscriptionsByUser(userId: userId);

    response.fold(
      (failure) => state = state.copyWith(
        state: AsyncState.failure,
        error: failure.message,
      ),
      (subscriptions) {
        // Find the active subscription or use the most recent one
        final activeSubscription = subscriptions.firstWhere(
          (sub) => sub.isValid != null && sub.isValid!,
          orElse: () => subscriptions.first,
        );

        state = state.copyWith(
          state: AsyncState.success,
          subscriptions: subscriptions,
          activeSubscription: activeSubscription,
        );
      },
    );
  }

  Future<void> incrementGroupsCreated({
    required String userId,
    required String packageId,
  }) async {
    final dataSource = ref.read(packageSubscriptionDataSourceProvider);

    state = state.copyWith(state: AsyncState.loading);
    final response = await dataSource.incrementGroupsCreated(
      userId: userId,
      packageId: packageId,
    );

    response.fold(
      (failure) => state = state.copyWith(
        state: AsyncState.failure,
        error: failure.message,
      ),
      (subscription) {
        // Update the subscription in the list
        final updatedSubscriptions = state.subscriptions?.map((sub) {
          return sub.userId == subscription.userId &&
                  sub.packageId == subscription.packageId
              ? subscription
              : sub;
        }).toList();

        state = state.copyWith(
          state: AsyncState.success,
          activeSubscription:
              subscription.isValid != null && subscription.isValid!
              ? subscription
              : state.activeSubscription,
          subscriptions: updatedSubscriptions,
        );
      },
    );
  }

  Future<void> deactivateSubscription({
    required String userId,
    required String packageId,
  }) async {
    final dataSource = ref.read(packageSubscriptionDataSourceProvider);

    state = state.copyWith(state: AsyncState.loading);
    final response = await dataSource.deactivateSubscription(
      userId: userId,
      packageId: packageId,
    );

    response.fold(
      (failure) => state = state.copyWith(
        state: AsyncState.failure,
        error: failure.message,
      ),
      (subscription) {
        // Update the subscription in the list
        final updatedSubscriptions = state.subscriptions?.map((sub) {
          return sub.userId == subscription.userId &&
                  sub.packageId == subscription.packageId
              ? subscription
              : sub;
        }).toList();

        // Clear active subscription if it's the one being deactivated
        final shouldClearActive =
            state.activeSubscription?.userId == userId &&
            state.activeSubscription?.packageId == packageId;

        state = state.copyWith(
          state: AsyncState.success,
          activeSubscription: shouldClearActive
              ? null
              : state.activeSubscription,
          subscriptions: updatedSubscriptions,
        );
      },
    );
  }

  Future<void> checkSubscriptionValidity({required String userId}) async {
    final dataSource = ref.read(packageSubscriptionDataSourceProvider);

    state = state.copyWith(state: AsyncState.loading);
    final response = await dataSource.getActiveSubscriptionByUser(
      userId: userId,
    );

    response.fold(
      (failure) => state = state.copyWith(
        state: AsyncState.failure,
        error: failure.message,
      ),
      (subscription) {
        if (subscription == null ||
            subscription.isValid == null ||
            !subscription.isValid!) {
          state = state.copyWith(
            state: AsyncState.success,
            activeSubscription: null,
          );
        } else {
          state = state.copyWith(
            state: AsyncState.success,
            activeSubscription: subscription,
          );
        }
      },
    );
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void reset() {
    state = PackageSubscriptionState(state: AsyncState.initial);
  }
}

class PackageSubscriptionState {
  final AsyncState? state;
  final String? error;
  final PackageSubscriptionModel? activeSubscription;
  final List<PackageSubscriptionModel>? subscriptions;

  PackageSubscriptionState({
    this.state,
    this.error,
    this.activeSubscription,
    this.subscriptions,
  });

  PackageSubscriptionState copyWith({
    AsyncState? state,
    String? error,
    PackageSubscriptionModel? activeSubscription,
    List<PackageSubscriptionModel>? subscriptions,
  }) {
    return PackageSubscriptionState(
      state: state ?? this.state,
      error: error ?? this.error,
      activeSubscription: activeSubscription ?? this.activeSubscription,
      subscriptions: subscriptions ?? this.subscriptions,
    );
  }

  bool get isLoading => state == AsyncState.loading;
  bool get isSuccess => state == AsyncState.success;
  bool get isFailure => state == AsyncState.failure;

  bool get hasActiveSubscription => activeSubscription?.isValid ?? false;
  // bool get canCreateMoreGroups =>
  //     activeSubscription?.canCreateMoreGroups ?? false;
  int get totalGroupsCreated => activeSubscription?.totalGroupsCreated ?? 0;
  int get daysUntilExpiry => activeSubscription?.daysUntilExpiry ?? 0;
  bool get isExpired => activeSubscription?.isExpired ?? true;
}
