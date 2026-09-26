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
import 'package:larnity/src/features/group/presentation/provider/challenge_provider.dart';
import 'package:larnity/src/features/group/presentation/provider/group_provider.dart';
import 'package:larnity/src/features/group/presentation/widgets/settings/create_challenge.dart';

class ChallengeSettingsScreen extends ConsumerWidget {
  const ChallengeSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupState = ref.watch(groupProvider);
    final group = groupState.group;
    final isOwnerOrAdmin = ref.watch(isGroupAdminOrOwnerProvider);

    if (group == null || group.id == null) {
      return Scaffold(
        backgroundColor: AppColors.darkBg,
        appBar: AppBar(
          backgroundColor: AppColors.darkBg,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: const Center(
          child: Text(
            "No group selected",
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    if (!isOwnerOrAdmin) {
      return Scaffold(
        backgroundColor: AppColors.darkBg,
        appBar: AppBar(
          backgroundColor: AppColors.darkBg,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text("Challenge Settings", style: TextStyle(color: Colors.white)),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock_outline, size: 64, color: AppColors.primaryOrange),
                AppSizes.sm.ph,
                Text(
                  "Access Restricted",
                  style: AppTextStyles.headline2(color: AppColors.white),
                ),
                AppSizes.xs.ph,
                Text(
                  "Only group owners and admins can configure challenges.",
                  style: AppTextStyles.bodyText1(color: AppColors.skyBlue),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    final challengeState = ref.watch(challengeProvider(group.id!));
    final challenges = challengeState.challenges ?? [];
    final isLoading = challengeState.fetchState == AsyncState.loading;

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: AppBar(
        backgroundColor: AppColors.darkBg,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "Challenges",
          style: AppTextStyles.headline3(color: AppColors.white),
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
                      AppStrings.challenges,
                      style: AppTextStyles.headline2(color: AppColors.white),
                    ),
                    Text(
                      "${challenges.length} ${AppStrings.challengesAvailable}",
                      style: AppTextStyles.overLine(color: AppColors.grey500),
                    ),
                  ],
                ),
                AppButton(
                  isExpanded: false,
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => const AlertDialog(
                        backgroundColor: AppColors.darkBgContainer,
                        content: CreateChallenge(),
                      ),
                    );
                  },
                  prefix: const HugeIcon(
                    icon: HugeIconsStrokeRounded.addCircle,
                    color: AppColors.black,
                  ),
                  label: AppStrings.createChallenge,
                  labelStyle: AppTextStyles.bodyText2(color: AppColors.black),
                  bgColor: AppColors.primaryOrange,
                  radius: AppSizes.xxxs,
                ),
              ],
            ),
            AppSizes.md.ph,
            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryOrange,
                      ),
                    )
                  : challenges.isEmpty
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const HugeIcon(
                              icon: HugeIconsStrokeRounded.champion,
                              color: AppColors.creamWhite,
                              size: 50,
                            ),
                            AppSizes.lg.ph,
                            Text(
                              AppStrings.noChallengeYet,
                              style: AppTextStyles.headline3(color: Colors.white),
                            ),
                            Text(
                              AppStrings.noChallengeDesc,
                              style: AppTextStyles.overLine(color: AppColors.grey500),
                              textAlign: TextAlign.center,
                            ),
                            AppSizes.xs.ph,
                            AppButton(
                              isExpanded: false,
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => const AlertDialog(
                                    backgroundColor: AppColors.darkBgContainer,
                                    content: CreateChallenge(),
                                  ),
                                );
                              },
                              prefix: const HugeIcon(
                                icon: HugeIconsStrokeRounded.addCircle,
                                color: AppColors.black,
                              ),
                              label: AppStrings.createFirstChallenge,
                              labelStyle:
                                  AppTextStyles.bodyText2(color: AppColors.black),
                              bgColor: AppColors.primaryOrange,
                              radius: AppSizes.xxxs,
                            ),
                          ],
                        )
                      : ListView.separated(
                          itemCount: challenges.length,
                          separatorBuilder: (_, _) => AppSizes.xs.ph,
                          itemBuilder: (context, index) {
                            final c = challenges[index];
                            final isLive = c.status == 'LIVE';
                            final isOpen = c.status == 'REGISTRATION_OPEN';

                            return Container(
                              padding: const EdgeInsets.all(AppSizes.xs),
                              decoration: BoxDecoration(
                                color: AppColors.darkBgContainer,
                                borderRadius:
                                    BorderRadius.circular(AppSizes.xxxs),
                                border: Border.all(
                                  color: isLive
                                      ? AppColors.lightGreen
                                      : (isOpen
                                          ? AppColors.primaryOrange
                                          : AppColors.skyBlue.withValues(alpha: 0.3)),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: AppColors.bgBlue,
                                      borderRadius:
                                          BorderRadius.circular(AppSizes.xxxs),
                                      image: c.image != null
                                          ? DecorationImage(
                                              image: NetworkImage(c.image!),
                                              fit: BoxFit.cover,
                                            )
                                          : null,
                                    ),
                                    child: c.image == null
                                        ? const Center(
                                            child: HugeIcon(
                                              icon:
                                                  HugeIconsStrokeRounded.champion,
                                              color: AppColors.primaryOrange,
                                            ),
                                          )
                                        : null,
                                  ),
                                  AppSizes.xs.pw,
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          c.title ?? 'Untitled Challenge',
                                          style: AppTextStyles.headline4(
                                            color: Colors.white,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          "${c.type ?? 'FREE'} • Prize: ${c.prize ?? 'N/A'}",
                                          style: AppTextStyles.caption2(
                                            color: AppColors.skyBlue,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isLive
                                          ? AppColors.lightGreen.withValues(alpha: 0.2)
                                          : (isOpen
                                              ? AppColors.primaryOrange
                                                  .withValues(alpha: 0.2)
                                              : Colors.grey.withValues(alpha: 0.2)),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      c.status ?? 'OPEN',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: isLive
                                            ? AppColors.lightGreen
                                            : (isOpen
                                                ? AppColors.primaryOrange
                                                : Colors.grey),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

