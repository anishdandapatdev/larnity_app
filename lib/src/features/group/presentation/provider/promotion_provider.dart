import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:larnity/src/core/utils/async_states.dart';
import 'package:larnity/src/features/group/data/datasource/promotion_datasource.dart';
import 'package:larnity/src/features/group/data/models/promotion_model.dart';

final promotionProvider = NotifierProvider<PromotionNotifier, PromotionState>(
  PromotionNotifier.new,
);

class PromotionNotifier extends Notifier<PromotionState> {
  @override
  PromotionState build() {
    return PromotionState(state: AsyncState.initial);
  }

  Future<void> createPromotion({
    required PromotionModel promotion,
    void Function()? successCallBack,
    void Function(String error)? failureCallBack,
  }) async {
    final dataSource = ref.read(promotionDataSourceProvider);

    state = state.copyWith(state: AsyncState.loading);
    final response = await dataSource.createPromotion(promotion: promotion);

    response.fold(
      (failure) {
        state = state.copyWith(
          state: AsyncState.failure,
          error: failure.message,
        );
        failureCallBack?.call(failure.message);
      },
      (promotion) {
        final updatedPromotions = [...state.promotions ?? [], promotion];
        state = state.copyWith(
          state: AsyncState.success,
          promotion: promotion,
          promotions: updatedPromotions,
        );
        successCallBack?.call();
      },
    );
  }

  Future<void> getPromotionsByGroup({required String groupld}) async {
    final dataSource = ref.read(promotionDataSourceProvider);

    state = state.copyWith(state: AsyncState.loading);
    final response = await dataSource.getPromotionsByGroup(groupld: groupld);

    response.fold(
      (failure) => state = state.copyWith(
        state: AsyncState.failure,
        error: failure.message,
      ),
      (promotions) => state = state.copyWith(
        state: AsyncState.success,
        promotions: promotions,
      ),
    );
  }

  Future<void> getActivePromotionsByGroup({required String groupld}) async {
    final dataSource = ref.read(promotionDataSourceProvider);

    state = state.copyWith(state: AsyncState.loading);
    final response = await dataSource.getActivePromotionsByGroup(
      groupld: groupld,
    );

    response.fold(
      (failure) => state = state.copyWith(
        state: AsyncState.failure,
        error: failure.message,
      ),
      (promotions) => state = state.copyWith(
        state: AsyncState.success,
        promotions: promotions,
      ),
    );
  }

  Future<void> getAllActivePromotions() async {
    final dataSource = ref.read(promotionDataSourceProvider);

    state = state.copyWith(state: AsyncState.loading);
    final response = await dataSource.getAllActivePromotions();

    response.fold(
      (failure) => state = state.copyWith(
        state: AsyncState.failure,
        error: failure.message,
      ),
      (promotions) => state = state.copyWith(
        state: AsyncState.success,
        promotions: promotions,
      ),
    );
  }

  Future<void> updatePromotionStatus({
    required String promoCodeld,
    required bool isActive,
  }) async {
    final dataSource = ref.read(promotionDataSourceProvider);

    state = state.copyWith(state: AsyncState.loading);
    final response = await dataSource.updatePromotionStatus(
      promoCodeld: promoCodeld,
      isActive: isActive,
    );

    response.fold(
      (failure) => state = state.copyWith(
        state: AsyncState.failure,
        error: failure.message,
      ),
      (promotion) {
        // Update the promotion in the list
        final updatedPromotions = state.promotions?.map((p) {
          return p.promoCodeld == promotion.promoCodeld ? promotion : p;
        }).toList();

        state = state.copyWith(
          state: AsyncState.success,
          promotion: promotion,
          promotions: updatedPromotions,
        );
      },
    );
  }

  Future<void> validatePromoCode({
    required String promoCodeld,
    required String groupld,
  }) async {
    final dataSource = ref.read(promotionDataSourceProvider);

    state = state.copyWith(state: AsyncState.loading);
    final response = await dataSource.getPromotion(promoCodeld: promoCodeld);

    response.fold(
      (failure) => state = state.copyWith(
        state: AsyncState.failure,
        error: 'Invalid promo code',
      ),
      (promotion) {
        if (promotion.groupld != groupld) {
          state = state.copyWith(
            state: AsyncState.failure,
            error: 'Promo code not valid for this group',
          );
        } else if (!promotion.isCurrentlyActive) {
          state = state.copyWith(
            state: AsyncState.failure,
            error: 'Promo code is not active',
          );
        } else {
          state = state.copyWith(
            state: AsyncState.success,
            promotion: promotion,
            error: null,
          );
        }
      },
    );
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void reset() {
    state = PromotionState(state: AsyncState.initial);
  }

  void clearSelectedPromotion() {
    state = state.copyWith(promotion: null);
  }
}

class PromotionState {
  final AsyncState? state;
  final String? error;
  final PromotionModel? promotion;
  final List<PromotionModel>? promotions;

  PromotionState({this.state, this.error, this.promotion, this.promotions});

  PromotionState copyWith({
    AsyncState? state,
    String? error,
    PromotionModel? promotion,
    List<PromotionModel>? promotions,
  }) {
    return PromotionState(
      state: state ?? this.state,
      error: error ?? this.error,
      promotion: promotion ?? this.promotion,
      promotions: promotions ?? this.promotions,
    );
  }

  bool get isLoading => state == AsyncState.loading;
  bool get isSuccess => state == AsyncState.success;
  bool get isFailure => state == AsyncState.failure;

  List<PromotionModel> get activePromotions =>
      promotions?.where((p) => p.isCurrentlyActive).toList() ?? [];

  List<PromotionModel> get expiredPromotions =>
      promotions?.where((p) => p.hasExpired).toList() ?? [];

  List<PromotionModel> get upcomingPromotions =>
      promotions?.where((p) => p.isScheduled).toList() ?? [];
}
