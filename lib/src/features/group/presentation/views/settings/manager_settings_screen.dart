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
import 'package:larnity/src/core/utils/show_snackbar.dart';
import 'package:larnity/src/features/group/presentation/provider/group_provider.dart';
import 'package:larnity/src/features/group/presentation/provider/member_provider.dart';
import 'package:larnity/src/features/group/presentation/widgets/settings/add_manager.dart';

class ManagerSettingsScreen extends ConsumerWidget {
  const ManagerSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupId = ref.watch(groupProvider).group?.id;
    final isOwnerOrAdmin = ref.watch(isGroupAdminOrOwnerProvider);

    if (groupId == null) {
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
          child: Text("No group selected", style: TextStyle(color: Colors.white)),
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
          title: const Text("Manager Settings", style: TextStyle(color: Colors.white)),
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
                  "Only group owners and admins can manage community managers.",
                  style: AppTextStyles.bodyText1(color: AppColors.skyBlue),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    final memberState = ref.watch(memberProvider(groupId));
    final managers = (memberState.members ?? [])
        .where((m) =>
            m.role.toUpperCase() == 'ADMIN' ||
            m.role.toUpperCase() == 'MODERATOR')
        .toList();
    final isLoading = memberState.fetchState == AsyncState.loading && managers.isEmpty;

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: AppBar(
        backgroundColor: AppColors.darkBg,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "Managers",
          style: AppTextStyles.headline3(color: AppColors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.xs),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppSizes.xs.ph,
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.groupManagers,
                        style: AppTextStyles.headline2(color: AppColors.white),
                      ),
                      Text(
                        "Admins and moderators who manage this community.",
                        style: AppTextStyles.overLine(),
                      ),
                    ],
                  ),
                ),
                AppButton(
                  isExpanded: false,
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: AppColors.darkBgContainer,
                        content: AddManager(groupId: groupId),
                      ),
                    );
                  },
                  prefix: const HugeIcon(
                    icon: HugeIconsStrokeRounded.userAdd02,
                    color: AppColors.black,
                  ),
                  label: "Assign Manager",
                  labelStyle: AppTextStyles.bodyText2(color: AppColors.black),
                  bgColor: AppColors.white,
                  radius: AppSizes.xxxs,
                ),
              ],
            ),
            AppSizes.sm.ph,
            Expanded(
              child: Builder(
                builder: (context) {
                  if (isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (managers.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const HugeIcon(
                            icon: HugeIconsStrokeRounded.userShield02,
                            color: Colors.grey,
                            size: 48,
                          ),
                          AppSizes.xs.ph,
                          Text(
                            "No custom managers assigned yet",
                            style: AppTextStyles.bodyText1(color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: managers.length,
                    separatorBuilder: (_, _) => AppSizes.xs.ph,
                    itemBuilder: (context, index) {
                      final manager = managers[index];
                      final profile = manager.profile;
                      final firstName = profile?['firstname'] ?? profile?['first_name'] ?? '';
                      final lastName = profile?['lastname'] ?? profile?['last_name'] ?? '';
                      final name = ('$firstName $lastName').trim().isNotEmpty
                          ? ('$firstName $lastName').trim()
                          : 'Manager ${manager.userId.substring(0, 6)}';
                      final avatarUrl = profile?['avatar_url'] as String?;
                      final role = manager.role.toUpperCase();

                      return Container(
                        padding: const EdgeInsets.all(AppSizes.xs),
                        decoration: BoxDecoration(
                          color: AppColors.bgBlue,
                          border: Border.all(
                            color: AppColors.skyBlue.withValues(alpha: 0.3),
                          ),
                          borderRadius: BorderRadius.circular(AppSizes.xxxs),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: AppColors.primaryOrange,
                              backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
                              child: avatarUrl == null
                                  ? Text(
                                      name.isNotEmpty ? name[0].toUpperCase() : 'M',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  : null,
                            ),
                            AppSizes.xs.pw,
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: AppTextStyles.subtitle1(color: Colors.white),
                                  ),
                                  Text(
                                    role,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: role == 'ADMIN'
                                          ? AppColors.primaryOrange
                                          : Colors.purple,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              tooltip: "Revoke manager role",
                              icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                              onPressed: () {
                                if (manager.id == null) return;
                                ref.read(memberProvider(groupId).notifier).updateMemberRole(
                                      memberId: manager.id!,
                                      role: 'MEMBER',
                                      successCallBack: () {
                                        showInfoToast(content: "Revoked manager role for $name");
                                      },
                                      failureCallBack: (err) {
                                        showErrorToast(content: err);
                                      },
                                    );
                              },
                            ),
                          ],
                        ),
                      );
                    },
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
