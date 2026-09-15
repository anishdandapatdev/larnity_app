import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:larnity/src/core/utils/async_states.dart';
import 'package:larnity/src/features/group/data/datasource/job_datasource.dart';
import 'package:larnity/src/features/group/data/datasource/job_application_datasource.dart';
import 'package:larnity/src/features/group/data/models/job_model.dart';
import 'package:larnity/src/features/group/data/models/job_application_model.dart';

class JobState {
  final AsyncState? fetchState;
  final AsyncState? createState;
  final String? error;
  final List<JobModel>? jobs;
  final List<JobApplicationModel>? applications;

  JobState({this.fetchState, this.createState, this.error, this.jobs, this.applications});

  JobState copyWith({
    AsyncState? fetchState, AsyncState? createState, String? error,
    List<JobModel>? jobs, List<JobApplicationModel>? applications,
  }) => JobState(
    fetchState: fetchState ?? this.fetchState,
    createState: createState ?? this.createState,
    error: error ?? this.error,
    jobs: jobs ?? this.jobs,
    applications: applications ?? this.applications,
  );
}

final jobProvider = NotifierProvider.autoDispose
    .family<JobNotifier, JobState, String>(JobNotifier.new);

class JobNotifier extends AutoDisposeFamilyNotifier<JobState, String> {
  @override
  JobState build(String arg) {
    Future.microtask(() => fetchJobs());
    return JobState(fetchState: AsyncState.initial);
  }

  String get _groupId => arg;

  Future<void> fetchJobs() async {
    final ds = ref.read(jobDataSourceProvider);
    state = state.copyWith(fetchState: AsyncState.loading);
    final result = await ds.getJobsByGroup(groupId: _groupId);
    result.fold(
      (f) => state = state.copyWith(fetchState: AsyncState.failure, error: f.message),
      (jobs) => state = state.copyWith(fetchState: AsyncState.success, jobs: jobs),
    );
  }

  Future<void> createJob({
    required JobModel job,
    void Function()? successCallBack,
    void Function(String error)? failureCallBack,
  }) async {
    final ds = ref.read(jobDataSourceProvider);
    state = state.copyWith(createState: AsyncState.loading);
    final result = await ds.createJob(job: job);
    result.fold(
      (f) { state = state.copyWith(createState: AsyncState.failure, error: f.message); failureCallBack?.call(f.message); },
      (created) { state = state.copyWith(createState: AsyncState.success, jobs: [created, ...(state.jobs ?? [])]); successCallBack?.call(); },
    );
  }

  Future<void> deleteJob({
    required String jobId,
    void Function()? successCallBack,
    void Function(String error)? failureCallBack,
  }) async {
    final ds = ref.read(jobDataSourceProvider);
    final result = await ds.deleteJob(jobId: jobId);
    result.fold(
      (f) => failureCallBack?.call(f.message),
      (_) { state = state.copyWith(jobs: state.jobs?.where((j) => j.id != jobId).toList()); successCallBack?.call(); },
    );
  }

  Future<void> applyForJob({
    required String jobId,
    required String userId,
    String? resumeUrl,
    String? coverLetter,
    void Function()? successCallBack,
    void Function(String error)? failureCallBack,
  }) async {
    final ds = ref.read(jobApplicationDataSourceProvider);
    final result = await ds.applyForJob(
      application: JobApplicationModel(
        jobId: jobId, userId: userId,
        resumeUrl: resumeUrl, coverLetter: coverLetter,
      ),
    );
    result.fold(
      (f) => failureCallBack?.call(f.message),
      (_) => successCallBack?.call(),
    );
  }
}
