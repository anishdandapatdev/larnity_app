import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import 'package:larnity/src/core/constants/app_size.dart';
import 'package:larnity/src/core/constants/app_strings.dart';
import 'package:larnity/src/core/extensions/extensions.dart';
import 'package:larnity/src/core/theme/app_colors.dart';
import 'package:larnity/src/core/theme/theme.dart';
import 'package:larnity/src/core/ui/widgets/app_button.dart';
import 'package:larnity/src/core/utils/async_states.dart';
import 'package:larnity/src/features/group/presentation/provider/group_provider.dart';
import 'package:larnity/src/features/group/presentation/provider/job_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:larnity/src/core/router/router.dart';
import 'package:larnity/src/features/group/presentation/widgets/add_job.dart';
import 'package:larnity/src/features/group/presentation/widgets/job_card.dart';

class JobRoomScreen extends ConsumerStatefulWidget {
  const JobRoomScreen({super.key});

  @override
  ConsumerState<JobRoomScreen> createState() => _JobRoomScreenState();
}

class _JobRoomScreenState extends ConsumerState<JobRoomScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final groupId = ref.read(groupProvider).group?.id;
      if (groupId != null) {
        ref.read(jobProvider(groupId).notifier).fetchJobs();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final groupId = ref.watch(groupProvider).group?.id;

    if (groupId == null) {
      return const Scaffold(body: Center(child: Text("Group ID not found")));
    }

    final jobState = ref.watch(jobProvider(groupId));
    final jobs = jobState.jobs ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Job Room"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.goNamed(Routes.group);
            }
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.xs),
        child: Column(
          children: [
            AppSizes.xs.ph,
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.jobRoom,
                      style: AppTextStyles.headline2(color: AppColors.white),
                    ),
                    Text(
                      "${jobs.length} ${AppStrings.jobsAvailable}",
                      style: AppTextStyles.overLine(),
                    ),
                  ],
                ),
                AppButton(
                  isExpanded: false,
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => const Dialog(
                        backgroundColor: AppColors.bgBlue,
                        child: AddJob(),
                      ),
                    );
                  },
                  prefix: const HugeIcon(
                    icon: HugeIconsStrokeRounded.addCircle,
                    color: AppColors.black,
                  ),
                  label: AppStrings.postJob,
                  labelStyle: AppTextStyles.bodyText2(color: AppColors.black),
                  bgColor: AppColors.primaryOrange,
                  radius: AppSizes.xxxs,
                ),
              ],
            ),
            AppSizes.lg.ph,
            Expanded(
              child: jobState.fetchState == AsyncState.loading
                  ? const Center(child: CircularProgressIndicator())
                  : jobs.isEmpty
                  ? const Center(
                      child: Text(
                        "No jobs available yet.",
                        style: TextStyle(color: AppColors.skyBlue),
                      ),
                    )
                  : ListView.separated(
                      itemCount: jobs.length,
                      separatorBuilder: (context, index) => AppSizes.xs.ph,
                      itemBuilder: (context, index) {
                        return JobCard(job: jobs[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
