import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:larnity/src/core/error/failures.dart';
import 'package:larnity/src/core/service/supabase/src/supabase_provider.dart';
import 'package:larnity/src/core/utils/logger.dart';
import 'package:larnity/src/features/package_subscription/data/model/package_subscription_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final packageSubscriptionDataSourceProvider =
    Provider<PackageSubscriptionDataSource>((ref) {
      return PackageSubscriptionDataSource(
        supabaseClient: ref.watch(supabaseClientProvider),
      );
    });

class PackageSubscriptionDataSource {
  final SupabaseClient supabaseClient;

  PackageSubscriptionDataSource({required this.supabaseClient});

  Future<Either<Failure, PackageSubscriptionModel>> createPackageSubscription({
    required PackageSubscriptionModel subscription,
  }) async {
    try {
      final response = await supabaseClient
          .from('PackageSubscriptions')
          .insert(subscription.toMap())
          .select()
          .single();

      Log.info("Create Package Subscription Response: ${response.toString()}");

      return Right(PackageSubscriptionModel.fromMap(response));
    } on PostgrestException catch (e) {
      Log.error("Create Package Subscription Error: ${e.message}");
      return Left(Failure(e.message));
    } catch (e) {
      Log.error("Create Package Subscription Error: ${e.toString()}");
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, PackageSubscriptionModel?>>
  getActiveSubscriptionByUser({required String userId}) async {
    try {
      final response = await supabaseClient
          .from('PackageSubscriptions')
          .select()
          .eq('userId', userId)
          .eq('isActive', true)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response == null) {
        return const Right(null);
      }

      return Right(PackageSubscriptionModel.fromMap(response));
    } on PostgrestException catch (e) {
      Log.error("Get Active Subscription Error: ${e.message}");
      return Left(Failure(e.message));
    } catch (e) {
      Log.error("Get Active Subscription Error: ${e.toString()}");
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, List<PackageSubscriptionModel>>>
  getSubscriptionsByUser({required String userId}) async {
    try {
      final response = await supabaseClient
          .from('PackageSubscriptions')
          .select()
          .eq('userId', userId)
          .order('created_at', ascending: false);

      final subscriptions = response
          .map((data) => PackageSubscriptionModel.fromMap(data))
          .toList();

      return Right(subscriptions);
    } on PostgrestException catch (e) {
      Log.error("Get Subscriptions by User Error: ${e.message}");
      return Left(Failure(e.message));
    } catch (e) {
      Log.error("Get Subscriptions by User Error: ${e.toString()}");
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, PackageSubscriptionModel>> updateSubscription({
    required PackageSubscriptionModel subscription,
  }) async {
    try {
      final response = await supabaseClient
          .from('PackageSubscriptions')
          .update(subscription.toMap())
          .eq('userId', subscription.userId)
          .eq('packageId', subscription.packageId)
          .select()
          .single();

      Log.info("Update Subscription Response: ${response.toString()}");

      return Right(PackageSubscriptionModel.fromMap(response));
    } on PostgrestException catch (e) {
      Log.error("Update Subscription Error: ${e.message}");
      return Left(Failure(e.message));
    } catch (e) {
      Log.error("Update Subscription Error: ${e.toString()}");
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, PackageSubscriptionModel>> incrementGroupsCreated({
    required String userId,
    required String packageId,
  }) async {
    try {
      // First get the current subscription
      final currentSubscription = await supabaseClient
          .from('PackageSubscriptions')
          .select()
          .eq('userId', userId)
          .eq('packageId', packageId)
          .single();

      final currentCount = currentSubscription['totalGroupsCreated'] as int;

      final response = await supabaseClient
          .from('PackageSubscriptions')
          .update({
            'totalGroupsCreated': currentCount + 1,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('userId', userId)
          .eq('packageId', packageId)
          .select()
          .single();

      Log.info("Increment Groups Created Response: ${response.toString()}");

      return Right(PackageSubscriptionModel.fromMap(response));
    } on PostgrestException catch (e) {
      Log.error("Increment Groups Created Error: ${e.message}");
      return Left(Failure(e.message));
    } catch (e) {
      Log.error("Increment Groups Created Error: ${e.toString()}");
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, PackageSubscriptionModel>> deactivateSubscription({
    required String userId,
    required String packageId,
  }) async {
    try {
      final response = await supabaseClient
          .from('PackageSubscriptions')
          .update({
            'isActive': false,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('userId', userId)
          .eq('packageId', packageId)
          .select()
          .single();

      Log.info("Deactivate Subscription Response: ${response.toString()}");

      return Right(PackageSubscriptionModel.fromMap(response));
    } on PostgrestException catch (e) {
      Log.error("Deactivate Subscription Error: ${e.message}");
      return Left(Failure(e.message));
    } catch (e) {
      Log.error("Deactivate Subscription Error: ${e.toString()}");
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, List<PackageSubscriptionModel>>>
  getExpiredSubscriptions() async {
    try {
      final now = DateTime.now().toIso8601String();
      final response = await supabaseClient
          .from('PackageSubscriptions')
          .select()
          .lt('subscriptionEndDate', now)
          .eq('isActive', true)
          .order('subscriptionEndDate', ascending: false);

      final subscriptions = response
          .map((data) => PackageSubscriptionModel.fromMap(data))
          .toList();

      return Right(subscriptions);
    } on PostgrestException catch (e) {
      Log.error("Get Expired Subscriptions Error: ${e.message}");
      return Left(Failure(e.message));
    } catch (e) {
      Log.error("Get Expired Subscriptions Error: ${e.toString()}");
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, void>> deleteSubscription({
    required String userId,
    required String packageId,
  }) async {
    try {
      await supabaseClient
          .from('PackageSubscriptions')
          .delete()
          .eq('userId', userId)
          .eq('packageId', packageId);

      Log.info(
        "Delete Subscription Success for User: $userId, Package: $packageId",
      );

      return const Right(null);
    } on PostgrestException catch (e) {
      Log.error("Delete Subscription Error: ${e.message}");
      return Left(Failure(e.message));
    } catch (e) {
      Log.error("Delete Subscription Error: ${e.toString()}");
      return Left(Failure(e.toString()));
    }
  }
}
