import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:larnity/src/core/error/failures.dart';
import 'package:larnity/src/core/service/supabase/src/supabase_provider.dart';
import 'package:larnity/src/core/utils/logger.dart';
import 'package:larnity/src/features/group/data/models/promotion_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final promotionDataSourceProvider = Provider<PromotionDataSource>((ref) {
  return PromotionDataSource(supabaseClient: ref.watch(supabaseClientProvider));
});

class PromotionDataSource {
  final SupabaseClient supabaseClient;

  PromotionDataSource({required this.supabaseClient});

  Future<Either<Failure, PromotionModel>> createPromotion({
    required PromotionModel promotion,
  }) async {
    try {
      final response = await supabaseClient
          .from('promotions') // Adjust table name as needed
          .insert(promotion.toMap())
          .select()
          .single();

      Log.info("Create Promotion Response: ${response.toString()}");

      return Right(PromotionModel.fromMap(response));
    } on PostgrestException catch (e) {
      Log.error("Create Promotion Error: ${e.message}");
      return Left(Failure(e.message));
    } catch (e) {
      Log.error("Create Promotion Error: ${e.toString()}");
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, PromotionModel>> getPromotion({
    required String promoCodeld,
  }) async {
    try {
      final response = await supabaseClient
          .from('promotions')
          .select()
          .eq('promoCodeld', promoCodeld)
          .single();

      return Right(PromotionModel.fromMap(response));
    } on PostgrestException catch (e) {
      Log.error("Get Promotion Error: ${e.message}");
      return Left(Failure(e.message));
    } catch (e) {
      Log.error("Get Promotion Error: ${e.toString()}");
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, List<PromotionModel>>> getPromotionsByGroup({
    required String groupld,
  }) async {
    try {
      final response = await supabaseClient
          .from('promotions')
          .select()
          .eq('groupld', groupld)
          .order('created_at', ascending: false);

      final promotions = response
          .map((data) => PromotionModel.fromMap(data))
          .toList();

      return Right(promotions);
    } on PostgrestException catch (e) {
      Log.error("Get Promotions by Group Error: ${e.message}");
      return Left(Failure(e.message));
    } catch (e) {
      Log.error("Get Promotions by Group Error: ${e.toString()}");
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, List<PromotionModel>>> getActivePromotionsByGroup({
    required String groupld,
  }) async {
    try {
      final now = DateTime.now().toIso8601String();
      final response = await supabaseClient
          .from('promotions')
          .select()
          .eq('groupld', groupld)
          .eq('isActive', true)
          .lt('startAt', now)
          .gt('endAt', now)
          .order('created_at', ascending: false);

      final promotions = response
          .map((data) => PromotionModel.fromMap(data))
          .toList();

      return Right(promotions);
    } on PostgrestException catch (e) {
      Log.error("Get Active Promotions by Group Error: ${e.message}");
      return Left(Failure(e.message));
    } catch (e) {
      Log.error("Get Active Promotions by Group Error: ${e.toString()}");
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, List<PromotionModel>>> getAllActivePromotions() async {
    try {
      final now = DateTime.now().toIso8601String();
      final response = await supabaseClient
          .from('promotions')
          .select()
          .eq('isActive', true)
          .lt('startAt', now)
          .gt('endAt', now)
          .order('created_at', ascending: false);

      final promotions = response
          .map((data) => PromotionModel.fromMap(data))
          .toList();

      return Right(promotions);
    } on PostgrestException catch (e) {
      Log.error("Get All Active Promotions Error: ${e.message}");
      return Left(Failure(e.message));
    } catch (e) {
      Log.error("Get All Active Promotions Error: ${e.toString()}");
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, PromotionModel>> updatePromotion({
    required PromotionModel promotion,
  }) async {
    try {
      final response = await supabaseClient
          .from('promotions')
          .update(promotion.toMap())
          .eq('promoCodeld', promotion.promoCodeld)
          .select()
          .single();

      Log.info("Update Promotion Response: ${response.toString()}");

      return Right(PromotionModel.fromMap(response));
    } on PostgrestException catch (e) {
      Log.error("Update Promotion Error: ${e.message}");
      return Left(Failure(e.message));
    } catch (e) {
      Log.error("Update Promotion Error: ${e.toString()}");
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, PromotionModel>> updatePromotionStatus({
    required String promoCodeld,
    required bool isActive,
  }) async {
    try {
      final response = await supabaseClient
          .from('promotions')
          .update({
            'isActive': isActive,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('promoCodeld', promoCodeld)
          .select()
          .single();

      Log.info("Update Promotion Status Response: ${response.toString()}");

      return Right(PromotionModel.fromMap(response));
    } on PostgrestException catch (e) {
      Log.error("Update Promotion Status Error: ${e.message}");
      return Left(Failure(e.message));
    } catch (e) {
      Log.error("Update Promotion Status Error: ${e.toString()}");
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, void>> deletePromotion({
    required String promoCodeld,
  }) async {
    try {
      await supabaseClient
          .from('promotions')
          .delete()
          .eq('promoCodeld', promoCodeld);

      Log.info("Delete Promotion Success for Promo Code: $promoCodeld");

      return const Right(null);
    } on PostgrestException catch (e) {
      Log.error("Delete Promotion Error: ${e.message}");
      return Left(Failure(e.message));
    } catch (e) {
      Log.error("Delete Promotion Error: ${e.toString()}");
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, List<PromotionModel>>> getExpiredPromotions() async {
    try {
      final now = DateTime.now().toIso8601String();
      final response = await supabaseClient
          .from('promotions')
          .select()
          .lt('endAt', now)
          .eq('isActive', true)
          .order('endAt', ascending: false);

      final promotions = response
          .map((data) => PromotionModel.fromMap(data))
          .toList();

      return Right(promotions);
    } on PostgrestException catch (e) {
      Log.error("Get Expired Promotions Error: ${e.message}");
      return Left(Failure(e.message));
    } catch (e) {
      Log.error("Get Expired Promotions Error: ${e.toString()}");
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, List<PromotionModel>>> getUpcomingPromotions() async {
    try {
      final now = DateTime.now().toIso8601String();
      final response = await supabaseClient
          .from('promotions')
          .select()
          .gt('startAt', now)
          .eq('isActive', true)
          .order('startAt', ascending: true);

      final promotions = response
          .map((data) => PromotionModel.fromMap(data))
          .toList();

      return Right(promotions);
    } on PostgrestException catch (e) {
      Log.error("Get Upcoming Promotions Error: ${e.message}");
      return Left(Failure(e.message));
    } catch (e) {
      Log.error("Get Upcoming Promotions Error: ${e.toString()}");
      return Left(Failure(e.toString()));
    }
  }
}
