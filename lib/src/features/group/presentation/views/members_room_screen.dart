import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import 'package:larnity/src/core/constants/app_size.dart';
import 'package:larnity/src/core/constants/app_strings.dart';
import 'package:larnity/src/core/extensions/extensions.dart';
import 'package:larnity/src/core/router/router.dart';
import 'package:larnity/src/core/theme/app_colors.dart';
import 'package:larnity/src/core/theme/theme.dart';
import 'package:larnity/src/core/ui/widgets/app_button.dart';
import 'package:larnity/src/features/group/presentation/provider/group_provider.dart';
import 'package:larnity/src/features/group/presentation/provider/member_provider.dart';
import 'package:larnity/src/core/utils/async_states.dart';

class MembersRoomScreen extends ConsumerStatefulWidget {
  const MembersRoomScreen({super.key});

  @override
  ConsumerState<MembersRoomScreen> createState() => _MembersRoomScreenState();
}

class _MembersRoomScreenState extends ConsumerState<MembersRoomScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query, String groupId) {
    ref
        .read(memberProvider(groupId).notifier)
        .searchMembers(query: query.trim());
  }

  @override
  Widget build(BuildContext context) {
    final groupId = ref.watch(groupProvider).group?.id;

    if (groupId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Members Room")),
        backgroundColor: AppColors.bgBlue,
        body: const Center(
          child: Text(
            "No group selected",
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    final memberState = ref.watch(memberProvider(groupId));
    final members = memberState.members ?? [];
    final isLoading =
        memberState.fetchState == AsyncState.loading && members.isEmpty;

    return Scaffold(
      backgroundColor: AppColors.bgBlue,
      appBar: AppBar(title: const Text("Members Room")),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.xs),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.groupMembers,
                      style: AppTextStyles.headline2(color: AppColors.white),
                    ),
                    Text(
                      AppStrings.membersInTheGroup,
                      style: AppTextStyles.overLine(),
                    ),
                  ],
                ),
                const Spacer(),
              ],
            ),
            AppSizes.xxxlg.ph,
            TextFormField(
              controller: _searchController,
              onChanged: (val) => _onSearchChanged(val, groupId),
              style: const TextStyle(color: AppColors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.darkBgContainer,
                hintText: AppStrings.searchMembers,
                hintStyle: AppTextStyles.button(color: AppColors.skyBlue),
                prefixIcon: const HugeIcon(
                  icon: HugeIconsStrokeRounded.search01,
                  color: AppColors.white,
                ),
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
            AppSizes.xxxlg.ph,
            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryOrange,
                      ),
                    )
                  : members.isEmpty
                  ? Center(
                      child: Text(
                        memberState.searchQuery?.isNotEmpty == true
                            ? 'No members found matching "${memberState.searchQuery}"'
                            : 'No members found in this group.',
                        style: const TextStyle(color: AppColors.skyBlue),
                      ),
                    )
                  : ListView.builder(
                      itemCount: members.length,
                      itemBuilder: (context, index) {
                        final member = members[index];
                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppSizes.xs),
                          margin: const EdgeInsets.only(bottom: AppSizes.xs),
                          decoration: BoxDecoration(
                            color: AppColors.black.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(AppSizes.xs),
                            border: Border.all(
                              color: AppColors.primaryOrange.withValues(
                                alpha: 0.3,
                              ),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 24,
                                    backgroundColor: AppColors.primaryOrange,
                                    backgroundImage: member.memberImage != null
                                        ? NetworkImage(member.memberImage!)
                                        : null,
                                    child: member.memberImage == null
                                        ? const Icon(
                                            Icons.person,
                                            color: AppColors.white,
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
                                          member.memberName,
                                          style: AppTextStyles.headline3(
                                            color: AppColors.white,
                                          ),
                                        ),
                                        Text(
                                          member.role.toUpperCase(),
                                          style: AppTextStyles.overLine(
                                            color:
                                                member.isAdmin ||
                                                    member.isManager
                                                ? AppColors.primaryOrange
                                                : AppColors.creamWhite,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              AppSizes.xs.ph,
                              Row(
                                children: [
                                  Expanded(
                                    child: AppButton(
                                      onPressed: () {
                                        context.goNamed(
                                          Routes.chatting,
                                          // Assuming you pass the user ID as extra to the chat screen
                                          extra: {'userId': member.userId},
                                        );
                                      },
                                      label: AppStrings.startChat,
                                      prefix: const HugeIcon(
                                        icon: HugeIconsStrokeRounded.message02,
                                        color: AppColors.black,
                                      ),
                                      labelStyle: AppTextStyles.caption2(
                                        color: AppColors.black,
                                      ),
                                      bgColor: AppColors.primaryOrange,
                                      isExpanded: false,
                                    ),
                                  ),
                                ],
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
