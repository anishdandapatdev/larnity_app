
import 'package:date_time_format/date_time_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:larnity/src/core/constants/app_size.dart';
import 'package:larnity/src/core/extensions/extensions.dart';
import 'package:larnity/src/core/extensions/screen_size_extension.dart';
import 'package:larnity/src/core/extensions/slugify_extension.dart';
import 'package:larnity/src/core/router/router.dart';
import 'package:larnity/src/core/theme/app_colors.dart';
import 'package:larnity/src/core/theme/theme.dart';
import 'package:larnity/src/core/ui/widgets/app_button.dart';
import 'package:larnity/src/core/utils/async_states.dart';
import 'package:larnity/src/core/utils/logger.dart';
import 'package:larnity/src/core/utils/show_snackbar.dart';
import 'package:larnity/src/features/auth/presentation/provider/auth_provider.dart';
import 'package:larnity/src/features/explore/domain/category.dart';
import 'package:larnity/src/features/explore/presentation/state/cubit/explore_group_provider.dart';
import 'package:larnity/src/features/group/data/models/group_model.dart';
import 'package:larnity/src/features/group/presentation/provider/group_provider.dart';
import 'package:larnity/src/features/package/presentation/provider/package_provider.dart';
import 'package:larnity/src/features/package_subscription/presentation/providers/package_subscription_provider.dart';

class PackageSubscriptionScreen extends ConsumerWidget {
  const PackageSubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the expanded state
    final isExpanded = ref.watch(exploreGroupExpandedProvider);

    // Get the list of visible categories based on expanded state
    final visibleCategories = isExpanded
        ? categories.sublist(1)
        : categories.sublist(1, 5);

    // Packages
    final packageState = ref.watch(packageProvider);
    final packageSubscriptionState = ref.watch(packageSubscriptionProvider);

    final groupState = ref.watch(groupProvider);
    final groupNotifier = ref.watch(groupProvider.notifier);

    final userId = ref.watch(authProvider).user?.id;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.goNamed(Routes.explore);
            }
          },
        ),
        title: const Text(
          'My Subscription',
          style: TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.xs),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Builder(
                builder: (context) {
                  if (packageSubscriptionState.state == AsyncState.loading &&
                      packageState.state == AsyncState.loading) {
                    return Center(child: CircularProgressIndicator());
                  } else if (packageSubscriptionState.state ==
                          AsyncState.failure &&
                      packageState.state == AsyncState.failure) {
                    return Center(child: Text("Failed to load data"));
                  } else if (packageSubscriptionState.state ==
                          AsyncState.success &&
                      packageState.state == AsyncState.success) {
                    Log.info("Packages: ${packageState.packages}");
                    final packages = packageState.packages;
                    final myPackage = (packages != null && packages.isNotEmpty)
                        ? packages
                              .where(
                                (p) =>
                                    p.id ==
                                    packageSubscriptionState
                                        .activeSubscription
                                        ?.packageId,
                              )
                              .firstOrNull
                        : null;

                    return Container(
                      padding: const EdgeInsets.all(AppSizes.xxlg),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.skyBlue),
                        borderRadius: BorderRadius.circular(AppSizes.xs),
                      ),
                      child: Column(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Your Package",
                                style: AppTextStyles.headline2(
                                  color: AppColors.blue,
                                ),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "${myPackage?.name ?? "N/A"}-₹ ${myPackage?.monthlyPrice} /${myPackage != null && myPackage.isFreeTrialPack ? "${myPackage.freeTrialDays}" : "30"} Days",
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSizes.xxxs,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: AppColors.green,
                                      ),
                                      borderRadius: BorderRadius.circular(
                                        AppSizes.lg,
                                      ),
                                    ),
                                    child: Text(
                                      "Active",
                                      style:
                                          AppTextStyles.caption2(
                                            color: AppColors.green,
                                          ).copyWith(
                                            fontWeight: AppFontWeights.black,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                "Group Created",
                                style: AppTextStyles.overLine(
                                  color: AppColors.blue,
                                ),
                              ),
                              Text(
                                "${packageSubscriptionState.totalGroupsCreated}/${myPackage?.maxGroups ?? "1"}",
                                style: AppTextStyles.headline2(
                                  color: AppColors.white,
                                ),
                              ),
                              SizedBox(
                                width: 0.3.sw,
                                child: LinearProgressIndicator(
                                  value: 1,
                                  color: AppColors.blue,
                                  minHeight: AppSizes.xxxs,
                                  borderRadius: BorderRadius.circular(
                                    AppSizes.xxxs,
                                  ),
                                ),
                              ),
                              AppSizes.lg.ph,
                              Text(
                                "Subscription Period",
                                style: AppTextStyles.overLine(
                                  color: AppColors.blue,
                                ),
                              ),
                              Text(
                                "${packageSubscriptionState.activeSubscription?.subscriptionStartDate?.format("d F Y")} - ${packageSubscriptionState.activeSubscription?.subscriptionEndDate?.format("d F Y")}",
                                style: AppTextStyles.headline4(
                                  color: AppColors.white,
                                ),
                              ),
                              Text(
                                "${packageSubscriptionState.activeSubscription?.remainingDuration?.inDays} days remaining",
                                style: AppTextStyles.subtitle2(
                                  color: AppColors.white,
                                ),
                              ),
                              AppSizes.xlg.ph,
                              AppButton(
                                onPressed: () {
                                  context.pushNamed(Routes.package);
                                },
                                borderColor: AppColors.blue,
                                bgColor: AppColors.blue,
                                label: "Upgrade Package",
                                labelStyle: AppTextStyles.overLine(
                                  color: AppColors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  } else {
                    return SizedBox.shrink();
                  }
                },
              ),
              AppSizes.xlg.ph,
              Container(
                decoration: BoxDecoration(
                  color: AppColors.bgBlue,
                  border: Border.all(color: AppColors.skyBlue),
                  borderRadius: BorderRadius.circular(AppSizes.xs),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.xs),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            "Create New Group",
                            style: AppTextStyles.headline2(
                              color: AppColors.white,
                            ),
                          ),
                        ],
                      ),
                      AppSizes.xs.ph,
                      Wrap(
                        spacing: AppSizes.xxxs,
                        runSpacing: AppSizes.xxxs,
                        alignment: WrapAlignment.center,
                        children: visibleCategories
                            .map(
                              (c) => AppButton(
                                isExpanded: false,
                                label: c.name,
                                labelStyle: AppTextStyles.subtitle2(
                                  color: groupState.selectedCategory == c
                                      ? AppColors.primaryOrange
                                      : AppColors.white,
                                ),
                                bgColor: AppColors.darkBgContainer.withValues(
                                  alpha: 0.2,
                                ),
                                borderColor: groupState.selectedCategory == c
                                    ? AppColors.primaryOrange
                                    : AppColors.borderBrown,
                                prefix: HugeIcon(
                                  icon: c.icon,
                                  color: groupState.selectedCategory == c
                                      ? AppColors.primaryOrange
                                      : AppColors.white,
                                ),
                                radius: AppSizes.xxs,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSizes.xxs,
                                  vertical: AppSizes.xxxs,
                                ),
                                onPressed: () {
                                  groupNotifier.selectCategory(category: c);
                                },
                              ),
                            )
                            .toList(),
                      ),
                      AppSizes.xs.ph,
                      AppButton(
                        isExpanded: false,
                        label: isExpanded ? "Show Less" : "Show More",
                        labelStyle: AppTextStyles.bodyText1(
                          color: AppColors.white,
                        ),
                        suffix: Icon(
                          isExpanded
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: AppColors.white,
                        ),
                        bgColor: Colors.transparent,
                        onPressed: () {
                          // Toggle the expanded state
                          ref
                                  .read(exploreGroupExpandedProvider.notifier)
                                  .state =
                              !isExpanded;
                        },
                      ),
                      TextFormField(
                        controller: groupNotifier.groupNameController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppColors.skyBlue.withValues(alpha: 0.5),
                            ),
                            borderRadius: BorderRadius.circular(AppSizes.xxxs),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppColors.skyBlue.withValues(alpha: 0.2),
                            ),
                            borderRadius: BorderRadius.circular(AppSizes.xxxs),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.skyBlue),
                            borderRadius: BorderRadius.circular(AppSizes.xxxs),
                          ),
                          hintText: "Enter group name",
                          hintStyle: AppTextStyles.subtitle2(
                            color: AppColors.skyBlue.withValues(alpha: 0.8),
                          ),
                        ),
                      ),
                      if (groupState.groupName != null &&
                          groupState.groupName!.isNotEmpty) ...[
                        AppSizes.xxxs.ph,
                        Row(
                          children: [
                            Text("slug:"),
                            AppSizes.xxxs.pw,
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppSizes.xxxs,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.skyBlue.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                "/${groupState.groupName!.slugify()}",
                              ),
                            ),
                          ],
                        ),
                      ],
                      AppSizes.xs.ph,
                      AppButton(
                        isLoading: groupState.createState == AsyncState.loading,
                        onPressed: () {
                          if (userId != null &&
                              groupNotifier
                                  .groupNameController
                                  .text
                                  .isNotEmpty &&
                              groupState.selectedCategory != null) {
                            final group = GroupModel(
                              createdAt: DateTime.now(),
                              name: groupNotifier.groupNameController.text,
                              slug:
                                  "${groupNotifier.groupNameController.text.slugify()}-9347529354",

                              userId: userId,
                              category: groupState.selectedCategory!.name
                                  .slugify(),
                              privacy: GroupPrivacy.PUBLIC,
                              packageSubscriptionId: packageSubscriptionState
                                  .activeSubscription
                                  ?.id,
                              status: GroupStatus.CREATED,
                            );
                            Log.info("Group: ${group.toMap()}");
                            groupNotifier.createGroup(
                              group: group,
                              successCallBack: () {
                                groupNotifier.refreshGroupsForCurrentUser();
                              },
                            );
                          } else if (userId == null) {
                            showErrorToast(content: "User not found");
                          } else if (groupNotifier
                              .groupNameController
                              .text
                              .isEmpty) {
                            showErrorToast(content: "Enter group name");
                          } else if (groupState.selectedCategory == null) {
                            showErrorToast(content: "Select Category");
                          }
                        },
                        bgColor: AppColors.white,
                        radius: AppSizes.xxxs,
                        label: "Create Group",
                        prefix: const Icon(Icons.add),
                      ),
                    ],
                  ),
                ),
              ),
              AppSizes.lg.ph,
              Container(
                decoration: BoxDecoration(
                  color: AppColors.bgBlue,
                  border: Border.all(color: AppColors.skyBlue),
                  borderRadius: BorderRadius.circular(AppSizes.xs),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.xs),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            "Your Groups",
                            style: AppTextStyles.headline2(
                              color: AppColors.white,
                            ),
                          ),
                        ],
                      ),
                      AppSizes.xs.ph,
                      Builder(
                        builder: (context) {
                          if (groupState.fetchState == AsyncState.loading) {
                            return Center(child: CircularProgressIndicator());
                          } else if (groupState.fetchState ==
                              AsyncState.failure) {
                            return Center(child: Text('Something went wrong'));
                          } else if (groupState.fetchState ==
                                  AsyncState.success &&
                              groupState.groups != null &&
                              groupState.groups!.isNotEmpty) {
                            return ListView.separated(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index) {
                                final group = groupState.groups![index];
                                Log.info("Group: ${group.toMap()}");
                                return AppButton(
                                  isExpanded: false,
                                  onPressed: () {
                                    // Navigate to the group screen
                                    context.pushNamed(Routes.group);
                                  },
                                  bgColor: Colors.transparent,
                                  borderColor: AppColors.skyBlue
                                      .withValues(alpha: 0.5),
                                  radius: AppSizes.xxxs,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Row(
                                          children: [
                                            Container(
                                              height: 24,
                                              width: 24,
                                              decoration: BoxDecoration(
                                                color: AppColors.white
                                                    .withValues(
                                                      alpha: 0.1,
                                                    ),
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      4,
                                                    ),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  group.name.substring(
                                                    0,
                                                    2,
                                                  ),
                                                  style:
                                                      AppTextStyles.bodyText2(
                                                        color: AppColors
                                                            .white
                                                            .withValues(
                                                              alpha: 0.8,
                                                            ),
                                                      ),
                                                ),
                                              ),
                                            ),
                                            AppSizes.xxxs.pw,
                                            Expanded(
                                              child: Text(
                                                group.name,
                                                style:
                                                    AppTextStyles.bodyText2(
                                                  color:
                                                      AppColors.white,
                                                ),
                                                overflow:
                                                    TextOverflow.ellipsis,
                                                maxLines: 1,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        "View",
                                        style: AppTextStyles.bodyText1(
                                          color: AppColors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              separatorBuilder: (_, _) => AppSizes.xs.ph,
                              itemCount: groupState.groups!.length,
                            );
                          } else {
                            return Center(
                              child: Text("You haven't created any groups yet"),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              AppSizes.xxxlg.ph,
            ],
          ),
        ),
      ),
    );
  }
}
