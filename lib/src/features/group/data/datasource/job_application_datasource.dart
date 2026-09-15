import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:larnity/src/core/error/failures.dart';
import 'package:larnity/src/core/service/supabase/src/supabase_provider.dart';
import 'package:larnity/src/core/service/supabase/src/supabase_table.dart';
import 'package:larnity/src/core/utils/logger.dart';
import 'package:larnity/src/features/group/data/models/job_application_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final jobApplicationDataSourceProvider =
    Provider<JobApplicationDataSource>((ref) {
  return JobApplicationDataSource(
      supabaseClient: ref.watch(supabaseClientProvider));
});

class JobApplicationDataSource {
  final SupabaseClient supabaseClient;

  JobApplicationDataSource({required this.supabaseClient});

  /// Apply for a job.
  Future<Either<Failure, JobApplicationModel>> applyForJob({
    required JobApplicationModel application,
  }) async {
    try {
      final response = await supabaseClient
          .from(SupabaseTable.jobApplication)
          .insert(application.toMap())
          .select('*, profiles(*)')
          .single();

      Log.info('Applied for job ${application.jobId}');
      return Right(JobApplicationModel.fromMap(response));
    } on PostgrestException catch (e) {
      Log.error('applyForJob error: ${e.message}');
      return Left(Failure(e.message));
    } catch (e) {
      Log.error('applyForJob error: $e');
      return Left(Failure(e.toString()));
    }
  }

  /// Get applications for a job (for admin view).
  Future<Either<Failure, List<JobApplicationModel>>> getApplicationsForJob({
    required String jobId,
  }) async {
    try {
      final response = await supabaseClient
          .from(SupabaseTable.jobApplication)
          .select('*, profiles(*)')
          .eq('jobId', jobId)
          .order('created_at', ascending: false);

      final applications = (response as List)
          .map((e) => JobApplicationModel.fromMap(e as Map<String, dynamic>))
          .toList();

      return Right(applications);
    } on PostgrestException catch (e) {
      Log.error('getApplicationsForJob error: ${e.message}');
      return Left(Failure(e.message));
    } catch (e) {
      Log.error('getApplicationsForJob error: $e');
      return Left(Failure(e.toString()));
    }
  }

  /// Get my applications.
  Future<Either<Failure, List<JobApplicationModel>>> getMyApplications({
    required String userId,
  }) async {
    try {
      final response = await supabaseClient
          .from(SupabaseTable.jobApplication)
          .select('*')
          .eq('userId', userId)
          .order('created_at', ascending: false);

      final applications = (response as List)
          .map((e) => JobApplicationModel.fromMap(e as Map<String, dynamic>))
          .toList();

      return Right(applications);
    } on PostgrestException catch (e) {
      Log.error('getMyApplications error: ${e.message}');
      return Left(Failure(e.message));
    } catch (e) {
      Log.error('getMyApplications error: $e');
      return Left(Failure(e.toString()));
    }
  }

  /// Check if already applied.
  Future<Either<Failure, bool>> hasApplied({
    required String jobId,
    required String userId,
  }) async {
    try {
      final response = await supabaseClient
          .from(SupabaseTable.jobApplication)
          .select('id')
          .eq('jobId', jobId)
          .eq('userId', userId)
          .maybeSingle();

      return Right(response != null);
    } on PostgrestException catch (e) {
      Log.error('hasApplied error: ${e.message}');
      return Left(Failure(e.message));
    } catch (e) {
      Log.error('hasApplied error: $e');
      return Left(Failure(e.toString()));
    }
  }

  /// Update application status (for admin).
  Future<Either<Failure, JobApplicationModel>> updateStatus({
    required String applicationId,
    required String status,
  }) async {
    try {
      final response = await supabaseClient
          .from(SupabaseTable.jobApplication)
          .update({'status': status})
          .eq('id', applicationId)
          .select('*, profiles(*)')
          .single();

      return Right(JobApplicationModel.fromMap(response));
    } on PostgrestException catch (e) {
      Log.error('updateStatus error: ${e.message}');
      return Left(Failure(e.message));
    } catch (e) {
      Log.error('updateStatus error: $e');
      return Left(Failure(e.toString()));
    }
  }
}
