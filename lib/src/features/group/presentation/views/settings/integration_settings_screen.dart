import 'package:flutter/material.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import 'package:larnity/src/core/constants/app_size.dart';
import 'package:larnity/src/core/constants/app_strings.dart';
import 'package:larnity/src/core/extensions/extensions.dart';
import 'package:larnity/src/core/theme/app_colors.dart';
import 'package:larnity/src/features/group/presentation/widgets/settings/assign_paid_course.dart';
import 'package:larnity/src/features/group/presentation/widgets/settings/free_challenge_access.dart';
import 'package:larnity/src/features/group/presentation/widgets/settings/google_sheet_integration.dart';
import 'package:larnity/src/features/group/presentation/widgets/settings/group_tab_settings.dart';
import 'package:larnity/src/features/group/presentation/widgets/settings/integration_card.dart';
import 'package:larnity/src/features/group/presentation/widgets/settings/invitation_link.dart';
import 'package:larnity/src/features/group/presentation/widgets/settings/invite_members.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:larnity/src/core/theme/theme.dart';
import 'package:larnity/src/features/group/presentation/provider/group_provider.dart';

class IntegrationSettingsScreen extends ConsumerWidget {
  const IntegrationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOwnerOrAdmin = ref.watch(isGroupAdminOrOwnerProvider);
    if (!isOwnerOrAdmin) {
      return Scaffold(
        backgroundColor: AppColors.darkBg,
        appBar: AppBar(
          backgroundColor: AppColors.darkBg,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text("Integration Settings", style: TextStyle(color: Colors.white)),
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
                  "Only group owners and admins can configure integrations.",
                  style: AppTextStyles.bodyText1(color: AppColors.skyBlue),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: AppBar(
        backgroundColor: AppColors.darkBg,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "Integrations",
          style: AppTextStyles.headline3(color: AppColors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.xs),
          child: Column(
            children: [
              AppSizes.xs.ph,
              IntegrationCard(
                buttonLabel: AppStrings.inviteMembers,
                description: AppStrings.memberInvitationsDesc,
                icon: HugeIconsStrokeRounded.userMultiple02,
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => Dialog(
                      backgroundColor: AppColors.bgBlue,
                      child: InviteMembers(),
                    ),
                  );
                },
                title: AppStrings.memberInvitations,
              ),
              AppSizes.xs.ph,
              IntegrationCard(
                buttonLabel: AppStrings.connectSheet,
                description: AppStrings.googleSheetIntegrationDesc,
                icon: HugeIconsStrokeRounded.googleSheet,
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => Dialog(
                      backgroundColor: AppColors.bgBlue,
                      child: GoogleSheetIntegration(),
                    ),
                  );
                },
                title: AppStrings.googleSheetIntegration,
              ),
              AppSizes.xs.ph,
              IntegrationCard(
                buttonLabel: AppStrings.manageTabs,
                description: AppStrings.groupTabSettingsDesc,
                icon: HugeIconsStrokeRounded.settings01,
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => Dialog(
                      backgroundColor: AppColors.bgBlue,
                      child: GroupTabSettings(),
                    ),
                  );
                },
                title: AppStrings.groupTabSettings,
              ),
              AppSizes.xs.ph,
              IntegrationCard(
                buttonLabel: AppStrings.assignPaidCourse,
                description: AppStrings.paidCourseAssignmentDesc,
                icon: HugeIconsStrokeRounded.bookOpen01,
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => Dialog(
                      backgroundColor: AppColors.bgBlue,
                      child: AssignPaidCourse(),
                    ),
                  );
                },
                title: AppStrings.paidCourseAssignment,
              ),
              AppSizes.xs.ph,
              IntegrationCard(
                buttonLabel: AppStrings.grantAccess,
                description: AppStrings.grantFreeChallengeAccessDesc,
                icon: HugeIconsStrokeRounded.adventure,
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => Dialog(
                      backgroundColor: AppColors.bgBlue,
                      child: FreeChallengeAccess(),
                    ),
                  );
                },
                title: AppStrings.grantFreeChallengeAccess,
              ),
              AppSizes.xs.ph,
              IntegrationCard(
                buttonLabel: AppStrings.createInvitationLink,
                description: AppStrings.createInvitationLinkDesc,
                icon: HugeIconsStrokeRounded.userMultiple02,
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => Dialog(
                      backgroundColor: AppColors.bgBlue,
                      child: InvitationLink(),
                    ),
                  );
                },
                title: AppStrings.createInvitationLink,
              ),
              AppSizes.xs.ph,
              IntegrationCard(
                buttonLabel: AppStrings.export,
                description: AppStrings.exportUserDataDesc,
                icon: HugeIconsStrokeRounded.zeroCircle,
                onTap: () {},
                title: AppStrings.exportUserData,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
