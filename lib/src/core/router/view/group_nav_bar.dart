import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import 'package:larnity/src/core/constants/app_assets.dart';
import 'package:larnity/src/core/constants/app_size.dart';
import 'package:larnity/src/core/constants/app_strings.dart';
import 'package:larnity/src/core/extensions/extensions.dart';
import 'package:larnity/src/core/router/router.dart';
import 'package:larnity/src/core/theme/app_colors.dart';
import 'package:larnity/src/core/theme/theme.dart';
import 'package:larnity/src/core/ui/widgets/app_button.dart';
import 'package:larnity/src/core/ui/widgets/app_dropdown.dart';
import 'package:larnity/src/features/group/presentation/provider/group_provider.dart';

class GroupNavBar extends ConsumerWidget {
  GroupNavBar({Key? key, required this.navigationShell})
      : super(key: key ?? const ValueKey('ScaffoldWithNestedNavigation'));

  final StatefulNavigationShell navigationShell;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the group provider to get the list of groups
    final groupState = ref.watch(groupProvider);
    final groups = groupState.groups ?? [];
    final isGroupHome = navigationShell.currentIndex == 0;

    return Scaffold(
      key: _scaffoldKey,
      appBar: isGroupHome
          ? AppBar(
              title: Image.asset(AppAssets.images.logoWhite, width: 100),
              centerTitle: false,
              leading: Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () {
                    Scaffold.of(context).openEndDrawer();
                  },
                ),
              ),
              actions: const [SizedBox.shrink()],
            )
          : null,
      endDrawer: isGroupHome
          ? Drawer(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.xs),
          child: Column(
            children: [
              AppSizes.xxxlg.ph,
              AppDropdown(
                button: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSizes.xxxs,
                    vertical: AppSizes.xxxs,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.skyBlue.withValues(alpha: 0.5),
                    ),
                    borderRadius: BorderRadius.circular(AppSizes.xs),
                  ),
                  child: Row(
                    children: [
                      AppSizes.xs.pw,
                      Expanded(
                        child: Text(
                          groupState.group?.name ?? "Select Group",
                          style: AppTextStyles.overLine(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Spacer(),
                      HugeIcon(
                        icon: HugeIconsStrokeRounded.arrowUpDown,
                        color: AppColors.white,
                      ),
                    ],
                  ),
                ),
                overlayHeight: 1 * 70 + 120,
                overlayRadius: AppSizes.xs,
                top: Padding(
                  padding: const EdgeInsets.all(AppSizes.sm),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Groups',
                        style: AppTextStyles.subtitle1(color: AppColors.white),
                      ),
                      Divider(color: AppColors.borderBrown),
                      AppSizes.xs.ph,
                      GestureDetector(
                        onTap: () {
                          context.goNamed(Routes.explore);
                        },
                        child: Row(
                          children: [
                            Icon(Icons.explore_outlined, color: Colors.grey),
                            8.pw,
                            Text("Explore Groups"),
                          ],
                        ),
                      ),
                      Divider(color: AppColors.borderBrown),
                    ],
                  ),
                ),
                items: groups.map((group) {
                  return AppDropdownItem(
                    value: group.id,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        // Set the selected group and navigate to the group screen
                        ref.read(groupProvider.notifier).setSelectedGroup(group);
                        context.pushNamed(Routes.group);
                      },
                      child: Row(
                        children: [
                          // Show group icon if available, otherwise use a default icon
                          group.icon != null 
                            ? Image.network(
                                group.icon!,
                                width: 20,
                                height: 20,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) => 
                                  HugeIcon(
                                    icon: HugeIconsStrokeRounded.user,
                                    color: AppColors.white,
                                    size: 20,
                                  ),
                              )
                            : HugeIcon(
                                icon: HugeIconsStrokeRounded.user,
                                color: AppColors.white,
                                size: 20,
                              ),
                          8.pw,
                          // Show group name
                          Text(group.name),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              AppSizes.xxxlg.ph,
              AppButton(
                onPressed: () {},
                padding: EdgeInsets.zero,
                bgColor: Colors.transparent,
                child: Row(
                  children: [
                    Text(
                      "CHANNELS",
                      style: AppTextStyles.overLine(color: AppColors.white),
                    ),
                    Spacer(),
                    Icon(Icons.add, color: AppColors.white),
                  ],
                ),
              ),
              AppSizes.lg.ph,

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          context.goNamed(Routes.explore);
                        },
                        child: Row(
                          children: [
                            HugeIcon(
                              icon: HugeIconsStrokeRounded.home03,
                              color: Colors.grey,
                            ),
                            8.pw,
                            Text("General", style: AppTextStyles.button()),
                          ],
                        ),
                      ),
                      AppSizes.xs.ph,
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          context.goNamed(Routes.explore);
                        },
                        child: Row(
                          children: [
                            HugeIcon(
                              icon: HugeIconsStrokeRounded.notification01,
                              color: Colors.grey,
                            ),
                            8.pw,
                            Text("Annoucements", style: AppTextStyles.button()),
                          ],
                        ),
                      ),
                      AppSizes.xs.ph,
                      Theme(
                        data: Theme.of(
                          context,
                        ).copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          title: Text(
                            "Settings",
                            style: AppTextStyles.button(),
                          ),
                          tilePadding: EdgeInsets.zero,
                          leading: HugeIcon(
                            icon: HugeIconsStrokeRounded.settings01,
                            color: Colors.grey,
                          ),
                          children: [
                            ListTile(
                              onTap: () {
                                context.pushNamed(Routes.generalSettings);
                              },
                              leading: HugeIcon(
                                icon: HugeIconsStrokeRounded.settings01,
                                color: Colors.grey,
                              ),
                              title: Text("General"),
                            ),
                            ListTile(
                              onTap: () {
                                context.pushNamed(Routes.subscriptionSettings);
                              },
                              leading: HugeIcon(
                                icon: HugeIconsStrokeRounded.wallet01,
                                color: Colors.grey,
                              ),
                              title: Text("Subscriptions"),
                            ),
                            ListTile(
                              onTap: () {
                                context.pushNamed(Routes.paymentSettings);
                              },
                              leading: HugeIcon(
                                icon: HugeIconsStrokeRounded.building01,
                                color: Colors.grey,
                              ),
                              title: Text("Payment Method"),
                            ),
                            ListTile(
                              onTap: () {
                                context.pushNamed(Routes.offerSettings);
                              },
                              leading: HugeIcon(
                                icon: HugeIconsStrokeRounded.package,
                                color: Colors.grey,
                              ),
                              title: Text("Offer"),
                            ),
                            ListTile(
                              onTap: () {
                                context.pushNamed(Routes.challengeSettings);
                              },
                              leading: HugeIcon(
                                icon: HugeIconsStrokeRounded.award02,
                                color: Colors.grey,
                              ),
                              title: Text("Challenge"),
                            ),
                            ListTile(
                              onTap: () {
                                context.pushNamed(Routes.integrationSettings);
                              },
                              leading: HugeIcon(
                                icon: HugeIconsStrokeRounded.link01,
                                color: Colors.grey,
                              ),
                              title: Text("Integration"),
                            ),
                            ListTile(
                              onTap: () {
                                context.pushNamed(Routes.promoCodeSettings);
                              },
                              leading: HugeIcon(
                                icon: HugeIconsStrokeRounded.ticket03,
                                color: Colors.grey,
                              ),
                              title: Text("Promo Code"),
                            ),
                            ListTile(
                              onTap: () {
                                context.pushNamed(
                                  Routes.memberManagementSettings,
                                );
                              },
                              leading: HugeIcon(
                                icon: HugeIconsStrokeRounded.man,
                                color: Colors.grey,
                              ),
                              title: Text("Member Management"),
                            ),
                            ListTile(
                              onTap: () {
                                context.pushNamed(Routes.leaveReasonsSettings);
                              },
                              leading: HugeIcon(
                                icon: HugeIconsStrokeRounded.userBlock02,
                                color: Colors.grey,
                              ),
                              title: Text("Leave Reason"),
                            ),
                            ListTile(
                              onTap: () {
                                context.pushNamed(Routes.managerSettings);
                              },
                              leading: HugeIcon(
                                icon: HugeIconsStrokeRounded.userShield02,
                                color: Colors.grey,
                              ),
                              title: Text("Manager"),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      )
    : null,
      body: navigationShell,
      bottomNavigationBar: BottomAppBar(
        height: 60,
        color: Theme.of(context).colorScheme.surface,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _BuildNavItem(
              onTap: () => _goBranch(0),
              icon: HugeIcon(
                icon: HugeIconsStrokeRounded.home03,
                color: Colors.grey,
                size: 32,
              ),
              isSelected: navigationShell.currentIndex == 0,
            ),
            _BuildNavItem(
              onTap: () {},
              icon: AppDropdown(
                button: HugeIcon(
                  icon: HugeIconsStrokeRounded.notification01,
                  color: Colors.grey,
                  size: 32,
                ),
                gapFromButton: 16,
                alignWithDevice: true,
                overlayHeight: 260,
                top: Padding(
                  padding: const EdgeInsets.all(AppSizes.xs),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            "Notifications",
                            style: AppTextStyles.button().copyWith(
                              fontWeight: AppFontWeights.bold,
                            ),
                          ),
                        ],
                      ),
                      AppSizes.xs.ph,
                      RichText(
                        text: TextSpan(
                          text: AppStrings.markAllAsRead,
                          style: AppTextStyles.subtitle2(
                            color: AppColors.primaryOrange,
                          ),
                          recognizer: TapGestureRecognizer()..onTap = () {},
                        ),
                      ),
                      AppSizes.xs.ph,
                      AppDropdown(
                        button: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSizes.xs,
                            vertical: AppSizes.xxs,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.borderBrown),
                            borderRadius: BorderRadius.circular(AppSizes.xxxs),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("All groups"),
                              Icon(Icons.keyboard_arrow_down),
                            ],
                          ),
                        ),
                        items: [
                          AppDropdownItem(value: 'all', label: "All groups"),
                        ],
                      ),
                      Divider(color: AppColors.borderBrown),
                    ],
                  ),
                ),
                bottom: Column(
                  children: [
                    Divider(color: AppColors.borderBrown),
                    TextButton(
                      onPressed: () {
                        context.pushNamed(Routes.notification);
                      },
                      child: Text("See all notifications(0)"),
                    ),
                  ],
                ),
                items: [],
              ),
              isSelected: navigationShell.currentIndex == 1,
            ),
            _BuildNavItem(
              onTap: () => _goBranch(2),
              icon: HugeIcon(
                icon: HugeIconsStrokeRounded.message02,
                color: Colors.grey,
                size: 32,
              ),
              isSelected: navigationShell.currentIndex == 2,
            ),
            _BuildNavItem(
              onTap: () {
                context.pushNamed(Routes.generalSettings);
              },
              icon: HugeIcon(
                icon: HugeIconsStrokeRounded.settings01,
                color: Colors.grey,
                size: 32,
              ),
              isSelected: false,
            ),
          ],
        ),
      ),
    );
  }
}

// Custom Bottom Nav Bar Item

class _BuildNavItem extends StatelessWidget {
  const _BuildNavItem({
    required this.onTap,
    required this.icon,
    required this.isSelected,
  });

  final Widget icon;
  final void Function() onTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: InkWell(onTap: onTap, child: icon),
      // IconButton(
      //   onPressed: onTap,
      //   style: ButtonStyle(visualDensity: VisualDensity.compact),
      //   icon: isSelected
      //       ? Column(
      //           children: [
      //             selectedIcon,
      //             Text(
      //               label,
      //               style: TextStyle(
      //                 color: isSelected
      //                     ? AppColors.primaryOrange
      //                     : AppColors.gray,
      //                 fontSize: 8,
      //                 fontWeight: isSelected
      //                     ? FontWeight.bold
      //                     : FontWeight.normal,
      //               ),
      //             ),
      //           ],
      //         )
      //       : Column(
      //           children: [
      //             icon,
      //             Text(
      //               label,
      //               style: TextStyle(
      //                 color: isSelected
      //                     ? AppColors.primaryOrange
      //                     : AppColors.gray,
      //                 fontSize: 8,
      //                 fontWeight: isSelected
      //                     ? FontWeight.bold
      //                     : FontWeight.normal,
      //               ),
      //             ),
      //           ],
      //         ),
      // ),
    );
  }
}
