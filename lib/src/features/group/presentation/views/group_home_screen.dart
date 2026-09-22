import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import 'package:larnity/src/core/constants/app_size.dart';
import 'package:larnity/src/core/extensions/extensions.dart';
import 'package:larnity/src/core/router/router.dart';
import 'package:larnity/src/core/theme/app_colors.dart';
import 'package:larnity/src/core/theme/theme.dart';
import 'package:larnity/src/features/group/data/models/group_model.dart';
import 'package:larnity/src/features/group/presentation/provider/group_provider.dart';

class GroupHomeScreen extends ConsumerStatefulWidget {
  const GroupHomeScreen({super.key});

  @override
  ConsumerState<GroupHomeScreen> createState() => _GroupHomeScreenState();
}

class _GroupHomeScreenState extends ConsumerState<GroupHomeScreen> {
  bool _dismissedOnboarding = false;

  Widget _buildRoomButton(
    BuildContext context,
    String title,
    dynamic icon,
    String routeName,
  ) {
    return InkWell(
      onTap: () => context.pushNamed(routeName),
      borderRadius: BorderRadius.circular(AppSizes.xxxs),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.black.withValues(alpha: 0.5),
          border: Border.all(
            color: AppColors.primaryOrange.withValues(alpha: 0.5),
          ),
          borderRadius: BorderRadius.circular(AppSizes.xxxs),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            HugeIcon(icon: icon, color: AppColors.primaryOrange, size: 32),
            AppSizes.xs.ph,
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.overLine(color: AppColors.white),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final groupState = ref.watch(groupProvider);
    final group = groupState.group;

    final isApproved = group?.status == GroupStatus.APPROVED;
    final showOnboarding = !_dismissedOnboarding && !isApproved;

    final visibility = group?.landingSettings?['tabVisibility'] as Map?;

    final allRooms = [
      {
        'key': 'discussion',
        'title': 'Discussion Room',
        'icon': HugeIconsStrokeRounded.home03,
        'route': Routes.discussionRoom,
      },
      {
        'key': 'courses',
        'title': 'Class Room',
        'icon': HugeIconsStrokeRounded.geometricShapes01,
        'route': Routes.classRoom,
      },
      {
        'key': 'stage',
        'title': 'Live Class',
        'icon': HugeIconsStrokeRounded.computerVideo,
        'route': Routes.liveClassRoom,
      },
      {
        'key': 'events',
        'title': 'Events Room',
        'icon': HugeIconsStrokeRounded.calendar03,
        'route': Routes.eventRoom,
      },
      {
        'key': 'members',
        'title': 'Members Room',
        'icon': HugeIconsStrokeRounded.userMultiple,
        'route': Routes.membersRoom,
      },
      {
        'key': 'resources',
        'title': 'Doubt Room',
        'icon': HugeIconsStrokeRounded.sourceCodeSquare,
        'route': Routes.doubtRoom,
      },
      {
        'key': 'challenges',
        'title': 'Challenges Room',
        'icon': HugeIconsStrokeRounded.adventure,
        'route': Routes.challengeRoom,
      },
      {
        'key': 'products',
        'title': 'Treasure Room',
        'icon': HugeIconsStrokeRounded.notebook02,
        'route': Routes.treasureRoom,
      },
      {
        'key': 'products',
        'title': 'Product Room',
        'icon': HugeIconsStrokeRounded.shoppingBag01,
        'route': Routes.productRoom,
      },
      {
        'key': 'jobs',
        'title': 'Service Room',
        'icon': HugeIconsStrokeRounded.documentValidation,
        'route': Routes.serviceRoom,
      },
      {
        'key': 'jobs',
        'title': 'Job Room',
        'icon': HugeIconsStrokeRounded.id,
        'route': Routes.jobRoom,
      },
    ];

    final visibleRooms = allRooms.where((r) {
      if (visibility == null) return true;
      final key = r['key'] as String;
      return visibility[key] != false;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.xs),
        child: Column(
          children: [
            AppSizes.xs.ph,
            if (showOnboarding)
              Container(
                padding: const EdgeInsets.all(AppSizes.xs),
                margin: const EdgeInsets.only(bottom: AppSizes.xs),
                decoration: BoxDecoration(
                  color: AppColors.infoCardColor,
                  border: Border.all(
                    color: AppColors.primaryOrange.withValues(alpha: 0.5),
                  ),
                  borderRadius: BorderRadius.circular(AppSizes.xxxs),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const HugeIcon(
                          icon: HugeIconsStrokeRounded.informationDiamond,
                          color: AppColors.primaryOrange,
                        ),
                        AppSizes.xs.pw,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Complete Group Onboarding",
                                style: AppTextStyles.button(
                                  color: AppColors.primaryOrange,
                                ),
                              ),
                              Text(
                                "Your group is not public yet. Please finish onboarding and submit for approval.",
                                style: AppTextStyles.overLine(
                                  color: AppColors.primaryOrange,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _dismissedOnboarding = true;
                            });
                          },
                          icon: const HugeIcon(
                            icon: HugeIconsStrokeRounded.cancel01,
                            color: AppColors.primaryOrange,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            context.pushNamed(Routes.generalSettings);
                          },
                          child: Text(
                            "Go to Settings",
                            style: AppTextStyles.button(
                              color: AppColors.primaryOrange,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            Expanded(
              child: GridView.count(
                crossAxisCount: 3,
                crossAxisSpacing: AppSizes.xs,
                mainAxisSpacing: AppSizes.xs,
                padding: const EdgeInsets.only(bottom: AppSizes.lg),
                children: visibleRooms.map((room) {
                  return _buildRoomButton(
                    context,
                    room['title'] as String,
                    room['icon'],
                    room['route'] as String,
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

