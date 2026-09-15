import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import 'package:larnity/src/core/constants/app_assets.dart';
import 'package:larnity/src/core/constants/app_size.dart';
import 'package:larnity/src/core/constants/app_strings.dart';
import 'package:larnity/src/core/extensions/extensions.dart';
import 'package:larnity/src/core/extensions/path_extension.dart';
import 'package:larnity/src/core/extensions/screen_size_extension.dart';
import 'package:larnity/src/core/router/router.dart';
import 'package:larnity/src/core/theme/app_colors.dart';
import 'package:larnity/src/core/theme/theme.dart';
import 'package:larnity/src/core/ui/widgets/app_dropdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:larnity/src/features/auth/presentation/provider/auth_provider.dart';

class ExploreNestedRoute extends ConsumerWidget {
  ExploreNestedRoute({Key? key, required this.navigationShell})
    : super(key: key ?? const ValueKey('exploreNestedRoute'));

  final StatefulNavigationShell navigationShell;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  final AppDropdownController _larnityDropdownController =
      AppDropdownController();

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
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
        actions: [
          GestureDetector(
            onTap: () {
              // Navigate to notification screen when icon is tapped
              context.pushNamed(Routes.notification);
            },
            child: AppDropdown(
              controller: _larnityDropdownController,
              button: HugeIcon(
                icon: HugeIconsStrokeRounded.notification01,
                color: Colors.grey,
              ),
              overlayWidth: 0.9.sw,
              overlayAlignment: Alignment.centerRight,
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
                          children: const [
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
                    child: const Text("See all notifications(0)"),
                  ),
                ],
              ),
              items: [],
            ),
          ),
          AppSizes.xs.pw,
        ],
      ),
      endDrawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.xlg),
                child: AppDropdown(
                  button: Row(
                    children: [
                      Expanded(child: Image.asset(AppAssets.images.logoWhite)),
                      AppSizes.xs.pw,
                      HugeIcon(
                        icon: HugeIconsStrokeRounded.unfoldMore,
                        color: AppColors.white,
                      ),
                    ],
                  ),
                  overlayHeight: 1 * 70 + 120,
                  overlayRadius: AppSizes.xs,
                  top: Padding(
                    padding: const EdgeInsets.all(AppSizes.sm),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'All Groups',
                          style: AppTextStyles.subtitle1(
                            color: AppColors.white,
                          ),
                        ),
                        Divider(color: AppColors.borderBrown),
                        AppSizes.xs.ph,
                        GestureDetector(
                          onTap: () {
                            context.goNamed(Routes.explore);
                          },
                          child: Row(
                            children: const [
                              Icon(Icons.explore_outlined, color: Colors.grey),
                              SizedBox(width: 8),
                              Text("Explore Groups"),
                            ],
                          ),
                        ),
                        Divider(color: AppColors.borderBrown),
                        Divider(height: 1, color: AppColors.borderBrown),
                      ],
                    ),
                  ),
                  items: [
                    AppDropdownItem(
                      value: 'sifat',
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          _larnityDropdownController.close();
                          context.pushNamed(Routes.group);
                        },
                        child: Row(
                          children: [
                            HugeIcon(
                              icon: HugeIconsStrokeRounded.user,
                              color: AppColors.white,
                            ),
                            const SizedBox(width: 8),
                            const Text("Sifat"),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ListTile(
              leading: HugeIcon(
                icon: HugeIconsStrokeRounded.home03,
                color: AppColors.white,
              ),
              title: const Text('Home'),
              onTap: () => _goBranch(0),
            ),
            ListTile(
              leading: HugeIcon(
                icon: HugeIconsStrokeRounded.compass01,
                color: AppColors.white,
              ),
              title: const Text('Explore'),
              onTap: () => _goBranch(1),
            ),
            ListTile(
              leading: HugeIcon(
                icon: HugeIconsStrokeRounded.bookmark01,
                color: AppColors.white,
              ),
              title: const Text('Saved'),
              onTap: () => _goBranch(2),
            ),
            ListTile(
              leading: HugeIcon(
                icon: HugeIconsStrokeRounded.calendar01,
                color: AppColors.white,
              ),
              title: const Text('My Learning'),
              onTap: () => _goBranch(3),
            ),
            ListTile(
              leading: HugeIcon(
                icon: HugeIconsStrokeRounded.wallet01,
                color: AppColors.white,
              ),
              title: const Text('Wallet'),
              onTap: () => _goBranch(4),
            ),
            ListTile(
              leading: HugeIcon(
                icon: HugeIconsStrokeRounded.settings01,
                color: AppColors.white,
              ),
              title: const Text('Settings'),
              onTap: () => context.push(Routes.profileSettings.p),
            ),
            ListTile(
              leading: HugeIcon(
                icon: HugeIconsStrokeRounded.logout02,
                color: AppColors.white,
              ),
              title: const Text('Log out'),
              onTap: () {
                ref.read(authProvider.notifier).signOut();
              },
            ),
          ],
        ),
      ),
      body: navigationShell,
    );
  }
}
