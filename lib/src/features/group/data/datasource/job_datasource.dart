import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:larnity/src/core/error/failures.dart';
import 'package:larnity/src/core/service/supabase/src/supabase_provider.dart';
import 'package:larnity/src/core/service/supabase/src/supabase_table.dart';
import 'package:larnity/src/core/utils/logger.dart';
import 'package:larnity/src/features/group/data/models/job_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final jobDataSourceProvider = Provider<JobDataSource>((ref) {
  return JobDataSource(supabaseClient: ref.watch(supabaseClientProvider));
});

class JobDataSource {
  final SupabaseClient supabaseClient;

  JobDataSource({required this.supabaseClient});

  Future<Either<Failure, JobModel>> createJob({required JobModel job}) async {
    try {
      final response = await supabaseClient
          .from(SupabaseTable.job)
          .insert(job.toMap())
          .select()
          .single();

      Log.info("Created job: ${response['id']}");
      return Right(JobModel.fromMap(response));
    } on PostgrestException catch (e) {
      Log.error("createJob error: ${e.message}");
      return Left(Failure(e.message));
    } catch (e) {
      Log.error("createJob error: ${e.toString()}");
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, JobModel>> getJob({required String jobId}) async {
    try {
      final response = await supabaseClient
          .from(SupabaseTable.job)
          .select()
          .eq('id', jobId)
          .single();

      return Right(JobModel.fromMap(response));
    } on PostgrestException catch (e) {
      Log.error("getJob error: ${e.message}");
      return Left(Failure(e.message));
    } catch (e) {
      Log.error("getJob error: ${e.toString()}");
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, List<JobModel>>> getJobsByGroup({
    required String groupId,
    int limit = 50,
    int offset = 0,
    bool activeOnly = true,
  }) async {
    try {
      var query = supabaseClient
          .from(SupabaseTable.job)
          .select()
          .eq('groupId', groupId);

      if (activeOnly) {
        final now = DateTime.now().toIso8601String();
        query = query.or('postingEndDate.is.null,postingEndDate.gt.$now');
      }

      final response = await query
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      final jobs = response.map((data) => JobModel.fromMap(data)).toList();
      Log.info("Fetched ${jobs.length} jobs for group $groupId");
      return Right(jobs);
    } on PostgrestException catch (e) {
      Log.error("getJobsByGroup error: ${e.message}");
      return Left(Failure(e.message));
    } catch (e) {
      Log.error("getJobsByGroup error: ${e.toString()}");
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, List<JobModel>>> getActiveJobs({
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final now = DateTime.now().toIso8601String();
      final response = await supabaseClient
          .from(SupabaseTable.job)
          .select()
          .or('postingEndDate.is.null,postingEndDate.gt.$now')
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      final jobs = response.map((data) => JobModel.fromMap(data)).toList();
      return Right(jobs);
    } on PostgrestException catch (e) {
      Log.error("getActiveJobs error: ${e.message}");
      return Left(Failure(e.message));
    } catch (e) {
      Log.error("getActiveJobs error: ${e.toString()}");
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, List<JobModel>>> getExpiredJobs({
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final now = DateTime.now().toIso8601String();
      final response = await supabaseClient
          .from(SupabaseTable.job)
          .select()
          .lt('postingEndDate', now)
          .order('postingEndDate', ascending: false)
          .range(offset, offset + limit - 1);

      final jobs = response.map((data) => JobModel.fromMap(data)).toList();
      return Right(jobs);
    } on PostgrestException catch (e) {
      Log.error("getExpiredJobs error: ${e.message}");
      return Left(Failure(e.message));
    } catch (e) {
      Log.error("getExpiredJobs error: ${e.toString()}");
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, List<JobModel>>>
  getJobsWithGoogleSheetIntegration() async {
    try {
      final response = await supabaseClient
          .from(SupabaseTable.job)
          .select()
          .not('googleSheetId', 'is', 'null')
          .order('created_at', ascending: false);

      final jobs = response.map((data) => JobModel.fromMap(data)).toList();
      return Right(jobs);
    } on PostgrestException catch (e) {
      Log.error("getJobsWithGoogleSheet error: ${e.message}");
      return Left(Failure(e.message));
    } catch (e) {
      Log.error("getJobsWithGoogleSheet error: ${e.toString()}");
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, JobModel>> updateJob({required JobModel job}) async {
    try {
      final response = await supabaseClient
          .from(SupabaseTable.job)
          .update(job.toMap())
          .eq('id', job.id!)
          .select()
          .single();

      Log.info("Updated job: ${response['id']}");
      return Right(JobModel.fromMap(response));
    } on PostgrestException catch (e) {
      Log.error("updateJob error: ${e.message}");
      return Left(Failure(e.message));
    } catch (e) {
      Log.error("updateJob error: ${e.toString()}");
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, JobModel>> updateJobGoogleSheet({
    required String jobId,
    required String googleSheetId,
  }) async {
    try {
      final response = await supabaseClient
          .from(SupabaseTable.job)
          .update({
            'googleSheetId': googleSheetId,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', jobId)
          .select()
          .single();

      Log.info("Updated job Google Sheet: $jobId");
      return Right(JobModel.fromMap(response));
    } on PostgrestException catch (e) {
      Log.error("updateJobGoogleSheet error: ${e.message}");
      return Left(Failure(e.message));
    } catch (e) {
      Log.error("updateJobGoogleSheet error: ${e.toString()}");
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, void>> deleteJob({required String jobId}) async {
    try {
      await supabaseClient
          .from(SupabaseTable.job)
          .delete()
          .eq('id', jobId);

      Log.info("Deleted job: $jobId");
      return const Right(null);
    } on PostgrestException catch (e) {
      Log.error("deleteJob error: ${e.message}");
      return Left(Failure(e.message));
    } catch (e) {
      Log.error("deleteJob error: ${e.toString()}");
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, void>> deleteJobsByGroup({
    required String groupId,
  }) async {
    try {
      await supabaseClient
          .from(SupabaseTable.job)
          .delete()
          .eq('groupId', groupId);

      Log.info("Deleted all jobs for group: $groupId");
      return const Right(null);
    } on PostgrestException catch (e) {
      Log.error("deleteJobsByGroup error: ${e.message}");
      return Left(Failure(e.message));
    } catch (e) {
      Log.error("deleteJobsByGroup error: ${e.toString()}");
      return Left(Failure(e.toString()));
    }
  }

  /// Real-time subscription for jobs.
  Stream<List<JobModel>> subscribeToGroupJobs(String groupId) {
    return supabaseClient
        .from(SupabaseTable.job)
        .stream(primaryKey: ['id'])
        .eq('groupId', groupId)
        .order('created_at', ascending: false)
        .map((data) => data.map((item) => JobModel.fromMap(item)).toList());
  }
}
