import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:larnity/src/core/constants/app_size.dart';
import 'package:larnity/src/core/constants/app_strings.dart';
import 'package:larnity/src/core/extensions/extensions.dart';
import 'package:larnity/src/core/extensions/screen_size_extension.dart';
import 'package:larnity/src/core/theme/app_colors.dart';
import 'package:larnity/src/core/theme/theme.dart';
import 'package:larnity/src/core/ui/widgets/app_button.dart';
import 'package:larnity/src/core/utils/async_states.dart';
import 'package:larnity/src/features/auth/presentation/provider/auth_provider.dart';
import 'package:larnity/src/features/group/data/models/job_model.dart';
import 'package:larnity/src/features/group/presentation/provider/group_provider.dart';
import 'package:larnity/src/features/group/presentation/provider/job_application_provider.dart';
import 'package:larnity/src/features/group/presentation/provider/job_provider.dart';

class JobCard extends ConsumerStatefulWidget {
  final JobModel job;
  const JobCard({super.key, required this.job});

  @override
  ConsumerState<JobCard> createState() => _JobCardState();
}

class _JobCardState extends ConsumerState<JobCard> {
  @override
  void initState() {
    super.initState();
    // Check application status after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = ref.read(authProvider).user?.id;
      if (userId != null && widget.job.id != null) {
        ref
            .read(jobApplicationProvider(widget.job.id!).notifier)
            .checkIfApplied(userId: userId);
      }
    });
  }

  void _showApplySheet() {
    if (widget.job.id == null) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ApplyBottomSheet(job: widget.job),
    );
  }

  @override
  Widget build(BuildContext context) {
    final jobId = widget.job.id;
    final appState =
        jobId != null ? ref.watch(jobApplicationProvider(jobId)) : null;
    final hasApplied = appState?.hasApplied ?? false;
    final isCheckingStatus = appState?.checkState == AsyncState.loading;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkBgContainer,
        borderRadius: BorderRadius.circular(AppSizes.xs),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Image banner
          Container(
            height: 0.2.sh,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.primaryOrange,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppSizes.xs),
                topRight: Radius.circular(AppSizes.xs),
              ),
              image: widget.job.image != null && widget.job.image!.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(widget.job.image!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(AppSizes.xs),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title + delete
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        widget.job.title,
                        style: AppTextStyles.headline4(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: AppColors.red),
                      onPressed: () {
                        final groupId = ref.read(groupProvider).group?.id;
                        if (groupId != null && widget.job.id != null) {
                          ref.read(jobProvider(groupId).notifier).deleteJob(
                            jobId: widget.job.id!,
                            successCallBack: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Job deleted')),
                              );
                            },
                          );
                        }
                      },
                    ),
                  ],
                ),

                AppSizes.xs.ph,

                // Description
                Text(
                  widget.job.description ?? '',
                  style: AppTextStyles.overLine(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                AppSizes.xs.ph,

                // Closing date
                if (widget.job.postingEndDate != null)
                  Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          color: AppColors.white, size: 14),
                      AppSizes.xs.pw,
                      Text(
                        'Closes: ${DateFormat('MMM dd, yyyy').format(widget.job.postingEndDate!)}',
                        style: AppTextStyles.overLine(color: AppColors.creamWhite),
                      ),
                    ],
                  ),

                AppSizes.xs.ph,

                // Apply Now button
                isCheckingStatus
                    ? const Center(
                        child: SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: AppColors.primaryOrange),
                        ),
                      )
                    : AppButton(
                        onPressed: hasApplied ? () {} : _showApplySheet,
                        label: hasApplied
                            ? '✓ Applied'
                            : AppStrings.applyNow,
                        labelStyle: AppTextStyles.button(
                          color: hasApplied ? AppColors.white : AppColors.black,
                        ),
                        bgColor: hasApplied
                            ? AppColors.skyBlue.withValues(alpha: 0.4)
                            : AppColors.primaryOrange,
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Apply Bottom Sheet ──────────────────────────────────────────────────────

class _ApplyBottomSheet extends ConsumerStatefulWidget {
  final JobModel job;
  const _ApplyBottomSheet({required this.job});

  @override
  ConsumerState<_ApplyBottomSheet> createState() => _ApplyBottomSheetState();
}

class _ApplyBottomSheetState extends ConsumerState<_ApplyBottomSheet> {
  final _resumeUrlController = TextEditingController();

  @override
  void dispose() {
    _resumeUrlController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final userId = ref.read(authProvider).user?.id;
    if (userId == null || widget.job.id == null) return;

    final resumeUrl = _resumeUrlController.text.trim();

    await ref.read(jobApplicationProvider(widget.job.id!).notifier).apply(
      userId: userId,
      resumeUrl: resumeUrl.isEmpty ? null : resumeUrl,
      onSuccess: () {
        if (!mounted) return;
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 Application submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      },
      onFailure: (err) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to apply: $err')),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isApplying =
        ref.watch(jobApplicationProvider(widget.job.id ?? '')).applyState ==
            AsyncState.loading;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bgBlue,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        AppSizes.md,
        AppSizes.sm,
        AppSizes.md,
        MediaQuery.of(context).viewInsets.bottom + AppSizes.md,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.creamWhite.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          AppSizes.sm.ph,

          // Title
          Text('Apply for Job', style: AppTextStyles.headline3()),
          AppSizes.xxxs.ph,
          Text(
            widget.job.title,
            style: AppTextStyles.overLine(color: AppColors.skyBlue),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          AppSizes.md.ph,

          // Resume URL Field
          Text('Resume URL (optional)', style: AppTextStyles.overLine()),
          AppSizes.xxxs.ph,
          TextFormField(
            controller: _resumeUrlController,
            style: AppTextStyles.bodyText1(color: AppColors.white),
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.darkBgContainer,
              hintText: 'Paste link to Google Drive, Dropbox, portfolio, etc.',
              hintStyle: AppTextStyles.button(color: AppColors.skyBlue),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.xxxs),
                borderSide: BorderSide(
                  color: AppColors.skyBlue.withValues(alpha: 0.4),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.xxxs),
                borderSide: const BorderSide(color: AppColors.primaryOrange),
              ),
            ),
            keyboardType: TextInputType.url,
            enabled: !isApplying,
          ),

          AppSizes.md.ph,

          // Submit button
          AppButton(
            onPressed: isApplying ? () {} : _submit,
            label: isApplying ? 'Submitting...' : 'Submit Application',
            labelStyle: AppTextStyles.button(
              color: isApplying ? AppColors.white : AppColors.black,
            ),
            bgColor: isApplying ? AppColors.skyBlue : AppColors.primaryOrange,
            radius: AppSizes.xxxs,
          ),

          AppSizes.xs.ph,

          // Skip resume option
          if (!isApplying)
            Center(
              child: TextButton(
                onPressed: () {
                  _resumeUrlController.clear();
                  _submit();
                },
                child: Text(
                  'Apply without resume',
                  style: AppTextStyles.overLine(color: AppColors.skyBlue),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
