import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import 'package:larnity/src/core/constants/app_size.dart';
import 'package:larnity/src/core/constants/app_strings.dart';
import 'package:larnity/src/core/extensions/extensions.dart';
import 'package:larnity/src/core/theme/app_colors.dart';
import 'package:larnity/src/core/theme/theme.dart';
import 'package:larnity/src/core/utils/async_states.dart';
import 'package:larnity/src/core/utils/show_snackbar.dart';
import 'package:larnity/src/features/group/presentation/provider/group_provider.dart';
import 'package:larnity/src/features/group/presentation/provider/member_provider.dart';

class MemberManagementScreen extends ConsumerStatefulWidget {
  const MemberManagementScreen({super.key});

  @override
  ConsumerState<MemberManagementScreen> createState() =>
      _MemberManagementScreenState();
}

class _MemberManagementScreenState
    extends ConsumerState<MemberManagementScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query, String groupId) {
    ref.read(memberProvider(groupId).notifier).searchMembers(query: query.trim());
  }

  void _changeRole(String groupId, String memberId, String newRole) {
    ref.read(memberProvider(groupId).notifier).updateMemberRole(
          memberId: memberId,
          role: newRole,
          successCallBack: () {
            showInfoToast(content: "Member role updated to $newRole");
          },
          failureCallBack: (err) {
            showErrorToast(content: err);
          },
        );
  }

  void _removeMember(String groupId, String memberId, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.darkBgContainer,
        title: const Text("Remove Member", style: TextStyle(color: Colors.white)),
        content: Text(
          "Are you sure you want to remove $name from this community?",
          style: const TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.of(ctx).pop();
              ref.read(memberProvider(groupId).notifier).removeMember(
                    memberId: memberId,
                    successCallBack: () {
                      showInfoToast(content: "$name removed from group");
                    },
                    failureCallBack: (err) {
                      showErrorToast(content: err);
                    },
                  );
            },
            child: const Text("Remove", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          title: const Text("Member Management", style: TextStyle(color: Colors.white)),
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
                  "Only group owners and admins can manage members.",
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
    final members = memberState.members ?? [];
    final isLoading = memberState.fetchState == AsyncState.loading && members.isEmpty;

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: AppBar(
        backgroundColor: AppColors.darkBg,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "Member Management",
          style: AppTextStyles.headline3(color: AppColors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.xs),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppSizes.xs.ph,
            Text(AppStrings.allMembers, style: AppTextStyles.headline4()),
            Text(
              AppStrings.allMembersDesc,
              style: AppTextStyles.overLine(color: AppColors.skyBlue),
            ),
            AppSizes.lg.ph,
            TextFormField(
              controller: _searchController,
              onChanged: (val) => _onSearch(val, groupId),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.darkBgContainer,
                hintText: AppStrings.searchMembers,
                prefixIcon: const HugeIcon(
                  icon: HugeIconsStrokeRounded.search01,
                  color: AppColors.white,
                ),
                hintStyle: AppTextStyles.button(color: AppColors.skyBlue),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.xxxs),
                  borderSide: BorderSide(
                    color: AppColors.skyBlue.withValues(alpha: 0.5),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.xxxs),
                  borderSide: const BorderSide(color: AppColors.skyBlue),
                ),
              ),
            ),
            AppSizes.xs.ph,
            Expanded(
              child: Builder(
                builder: (context) {
                  if (isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (members.isEmpty) {
                    return const Center(
                      child: Text(
                        "No members found in this group",
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: members.length,
                    separatorBuilder: (_, _) => AppSizes.xxs.ph,
                    itemBuilder: (context, index) {
                      final member = members[index];
                      final profile = member.profile;
                      final firstName = profile?['firstname'] ?? profile?['first_name'] ?? '';
                      final lastName = profile?['lastname'] ?? profile?['last_name'] ?? '';
                      final fullName = ('$firstName $lastName').trim().isNotEmpty
                          ? ('$firstName $lastName').trim()
                          : 'Member ${member.userId.substring(0, 6)}';
                      final avatarUrl = profile?['avatar_url'] as String?;
                      final role = member.role.toUpperCase();

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
                                      fullName.isNotEmpty ? fullName[0].toUpperCase() : 'M',
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
                                    fullName,
                                    style: AppTextStyles.subtitle1(color: Colors.white),
                                  ),
                                  Text(
                                    "Plan: ${member.planType ?? 'FREE'} • Joined",
                                    style: AppTextStyles.caption(color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSizes.xs,
                                vertical: AppSizes.xxxs,
                              ),
                              decoration: BoxDecoration(
                                color: role == 'ADMIN'
                                    ? AppColors.primaryOrange.withValues(alpha: 0.2)
                                    : role == 'MODERATOR'
                                        ? Colors.purple.withValues(alpha: 0.2)
                                        : Colors.blue.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(AppSizes.xxxs),
                              ),
                              child: Text(
                                role,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: role == 'ADMIN'
                                      ? AppColors.primaryOrange
                                      : role == 'MODERATOR'
                                          ? Colors.purple
                                          : Colors.blue,
                                ),
                              ),
                            ),
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert, color: Colors.white),
                              onSelected: (val) {
                                if (member.id == null) return;
                                if (val == 'REMOVE') {
                                  _removeMember(groupId, member.id!, fullName);
                                } else {
                                  _changeRole(groupId, member.id!, val);
                                }
                              },
                              itemBuilder: (ctx) => [
                                const PopupMenuItem(
                                  value: 'ADMIN',
                                  child: Text('Make Admin'),
                                ),
                                const PopupMenuItem(
                                  value: 'MODERATOR',
                                  child: Text('Make Moderator'),
                                ),
                                const PopupMenuItem(
                                  value: 'MEMBER',
                                  child: Text('Set as Member'),
                                ),
                                const PopupMenuDivider(),
                                const PopupMenuItem(
                                  value: 'REMOVE',
                                  child: Text(
                                    'Remove from Group',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
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
