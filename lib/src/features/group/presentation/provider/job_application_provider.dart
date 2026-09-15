import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:larnity/src/core/utils/async_states.dart';
import 'package:larnity/src/features/group/data/datasource/job_application_datasource.dart';
import 'package:larnity/src/features/group/data/models/job_application_model.dart';

// ── State ──────────────────────────────────────────────────────────────────

class JobApplicationState {
  final AsyncState? applyState;
  final AsyncState? checkState;
  final bool hasApplied;
  final String? error;
  final List<JobApplicationModel> applications;

  const JobApplicationState({
    this.applyState,
    this.checkState,
    this.hasApplied = false,
    this.error,
    this.applications = const [],
  });

  JobApplicationState copyWith({
    AsyncState? applyState,
    AsyncState? checkState,
    bool? hasApplied,
    String? error,
    List<JobApplicationModel>? applications,
  }) {
    return JobApplicationState(
      applyState: applyState ?? this.applyState,
      checkState: checkState ?? this.checkState,
      hasApplied: hasApplied ?? this.hasApplied,
      error: error ?? this.error,
      applications: applications ?? this.applications,
    );
  }
}

// ── Provider ───────────────────────────────────────────────────────────────

/// Keyed by jobId so each job card has isolated state.
final jobApplicationProvider = NotifierProvider.autoDispose
    .family<JobApplicationNotifier, JobApplicationState, String>(
  JobApplicationNotifier.new,
);

class JobApplicationNotifier
    extends AutoDisposeFamilyNotifier<JobApplicationState, String> {
  String get _jobId => arg;

  @override
  JobApplicationState build(String arg) => const JobApplicationState(
        applyState: AsyncState.initial,
        checkState: AsyncState.initial,
      );

  /// Check if the current user has already applied for this job.
  Future<void> checkIfApplied({required String userId}) async {
    state = state.copyWith(checkState: AsyncState.loading);
    final ds = ref.read(jobApplicationDataSourceProvider);
    final result = await ds.hasApplied(jobId: _jobId, userId: userId);
    result.fold(
      (failure) => state = state.copyWith(
          checkState: AsyncState.failure, error: failure.message),
      (applied) => state = state.copyWith(
          checkState: AsyncState.success, hasApplied: applied),
    );
  }

  /// Submit a job application.
  Future<void> apply({
    required String userId,
    String? resumeUrl,
    void Function()? onSuccess,
    void Function(String)? onFailure,
  }) async {
    state = state.copyWith(applyState: AsyncState.loading);
    final ds = ref.read(jobApplicationDataSourceProvider);
    final application = JobApplicationModel(
      jobId: _jobId,
      userId: userId,
      resumeUrl: resumeUrl,
    );
    final result = await ds.applyForJob(application: application);
    result.fold(
      (failure) {
        state = state.copyWith(
            applyState: AsyncState.failure, error: failure.message);
        onFailure?.call(failure.message);
      },
      (app) {
        state = state.copyWith(
          applyState: AsyncState.success,
          hasApplied: true,
          applications: [...state.applications, app],
        );
        onSuccess?.call();
      },
    );
  }
}
