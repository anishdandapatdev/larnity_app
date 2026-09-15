import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:larnity/src/core/error/failures.dart';
import 'package:larnity/src/core/service/supabase/src/supabase_provider.dart';
import 'package:larnity/src/core/utils/logger.dart';
import 'package:larnity/src/features/package/data/model/package_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final packageDataSourceProvider = Provider<PackageDataSource>((ref) {
  return PackageDataSource(supabaseClient: ref.watch(supabaseClientProvider));
});

class PackageDataSource {
  final SupabaseClient supabaseClient;

  PackageDataSource({required this.supabaseClient});

  Future<Either<Failure, PackageModel>> createPackage({
    required PackageModel package,
  }) async {
    try {
      final response = await supabaseClient
          .from('GroupCreationPackage')
          .insert(package.toMap())
          .select()
          .single();

      Log.info(
        "Create Group Creation Package Response: ${response.toString()}",
      );

      return Right(PackageModel.fromMap(response));
    } on PostgrestException catch (e) {
      Log.error("Create Group Creation Package Error: ${e.message}");
      return Left(Failure(e.message));
    } catch (e) {
      Log.error("Create Group Creation Package Error: ${e.toString()}");
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, PackageModel>> getPackage({
    required String packageId,
  }) async {
    try {
      final response = await supabaseClient
          .from('GroupCreationPackage')
          .select()
          .eq('id', packageId)
          .single();

      return Right(PackageModel.fromMap(response));
    } on PostgrestException catch (e) {
      Log.error("Get Package Error: ${e.message}");
      return Left(Failure(e.message));
    } catch (e) {
      Log.error("Get Package Error: ${e.toString()}");
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, List<PackageModel>>> getAllPackages({
    bool activeOnly = true,
  }) async {
    try {
      PostgrestTransformBuilder<List<Map<String, dynamic>>> query;

      if (activeOnly) {
        query = supabaseClient
            .from('GroupCreationPackage')
            .select()
            .eq("isActive", true)
            .order('displayOrder', ascending: true)
            .order('monthlyPrice', ascending: true);
      } else {
        query = supabaseClient
            .from('GroupCreationPackage')
            .select()
            .order('displayOrder', ascending: true)
            .order('monthlyPrice', ascending: true);
      }

      final response = await query;

      final packages = response
          .map((data) => PackageModel.fromMap(data))
          .toList();

      return Right(packages);
    } on PostgrestException catch (e) {
      Log.error("Get All Packages Error: ${e.message}");
      return Left(Failure(e.message));
    } catch (e) {
      Log.error("Get All Packages Error: ${e.toString()}");
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, List<PackageModel>>> getActivePackages() async {
    try {
      final response = await supabaseClient
          .from('GroupCreationPackage')
          .select()
          .eq('isActive', true)
          .order('displayOrder', ascending: true)
          .order('monthlyPrice', ascending: true);

      final packages = response
          .map((data) => PackageModel.fromMap(data))
          .toList();

      return Right(packages);
    } on PostgrestException catch (e) {
      Log.error("Get Active Packages Error: ${e.message}");
      return Left(Failure(e.message));
    } catch (e) {
      Log.error("Get Active Packages Error: ${e.toString()}");
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, PackageModel>> getFreeTrialPackage() async {
    try {
      final response = await supabaseClient
          .from('GroupCreationPackage')
          .select()
          .eq('isFreeTrialPack', true)
          .eq('isActive', true)
          .single();

      return Right(PackageModel.fromMap(response));
    } on PostgrestException catch (e) {
      Log.error("Get Free Trial Package Error: ${e.message}");
      return Left(Failure(e.message));
    } catch (e) {
      Log.error("Get Free Trial Package Error: ${e.toString()}");
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, PackageModel>> updatePackage({
    required PackageModel package,
  }) async {
    try {
      final response = await supabaseClient
          .from('GroupCreationPackage')
          .update(package.toMap())
          .eq('id', package.id)
          .select()
          .single();

      Log.info("Update Package Response: ${response.toString()}");

      return Right(PackageModel.fromMap(response));
    } on PostgrestException catch (e) {
      Log.error("Update Package Error: ${e.message}");
      return Left(Failure(e.message));
    } catch (e) {
      Log.error("Update Package Error: ${e.toString()}");
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, PackageModel>> updatePackageStatus({
    required String packageId,
    required bool isActive,
  }) async {
    try {
      final response = await supabaseClient
          .from('GroupCreationPackage')
          .update({'isActive': isActive})
          .eq('id', packageId)
          .select()
          .single();

      Log.info("Update Package Status Response: ${response.toString()}");

      return Right(PackageModel.fromMap(response));
    } on PostgrestException catch (e) {
      Log.error("Update Package Status Error: ${e.message}");
      return Left(Failure(e.message));
    } catch (e) {
      Log.error("Update Package Status Error: ${e.toString()}");
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, void>> deletePackage({
    required String packageId,
  }) async {
    try {
      await supabaseClient
          .from('GroupCreationPackage')
          .delete()
          .eq('id', packageId);

      Log.info("Delete Package Success for ID: $packageId");

      return const Right(null);
    } on PostgrestException catch (e) {
      Log.error("Delete Package Error: ${e.message}");
      return Left(Failure(e.message));
    } catch (e) {
      Log.error("Delete Package Error: ${e.toString()}");
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, PackageModel>> getPackageByDisplayOrder({
    required int displayOrder,
  }) async {
    try {
      final response = await supabaseClient
          .from('GroupCreationPackage')
          .select()
          .eq('displayOrder', displayOrder)
          .eq('isActive', true)
          .single();

      return Right(PackageModel.fromMap(response));
    } on PostgrestException catch (e) {
      Log.error("Get Package by Display Order Error: ${e.message}");
      return Left(Failure(e.message));
    } catch (e) {
      Log.error("Get Package by Display Order Error: ${e.toString()}");
      return Left(Failure(e.toString()));
    }
  }
}
