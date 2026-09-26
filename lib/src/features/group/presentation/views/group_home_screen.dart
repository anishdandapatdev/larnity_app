import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import 'package:larnity/src/core/constants/app_size.dart';
import 'package:larnity/src/core/extensions/extensions.dart';
import 'package:larnity/src/core/router/router.dart';
import 'package:larnity/src/core/service/supabase/src/supabase_storage_service.dart';
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

  String? _resolveImageUrl(WidgetRef ref, String? rawUrl) {
    if (rawUrl == null || rawUrl.trim().isEmpty) return null;
    final trimmed = rawUrl.trim();
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    try {
      final storage = ref.read(storageServiceProvider);
      return storage.getPublicUrl(
        bucket: StorageBucket.groupImages,
        path: trimmed,
      );
    } catch (_) {
      return null;
    }
  }

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
        'key': 'treasure',
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
        'key': 'services',
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

    final bannerUrl = _resolveImageUrl(ref, group?.thumbnail) ??
        _resolveImageUrl(ref, group?.icon);
    final iconUrl = _resolveImageUrl(ref, group?.icon) ??
        _resolveImageUrl(ref, group?.thumbnail);

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.xs),
        child: Column(
          children: [
            AppSizes.xs.ph,
            if (group != null) ...[
              Container(
                margin: const EdgeInsets.only(bottom: AppSizes.xs),
                height: 84,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppSizes.xxxs),
                  border: Border.all(
                    color: AppColors.borderBrown.withValues(alpha: 0.5),
                  ),
                  color: AppColors.darkBgContainer,
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  children: [
                    if (bannerUrl != null)
                      Positioned.fill(
                        child: Image.network(
                          bannerUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const SizedBox.shrink(),
                        ),
                      ),
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.black.withValues(alpha: 0.9),
                              AppColors.black.withValues(alpha: 0.6),
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.xs,
                        vertical: AppSizes.xxs,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.primaryOrange,
                                width: 1.5,
                              ),
                              color: AppColors.black,
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: iconUrl != null
                                ? Image.network(
                                    iconUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) => Center(
                                      child: Text(
                                        group.name.isNotEmpty
                                            ? group.name.characters.first.toUpperCase()
                                            : 'G',
                                        style: AppTextStyles.headline4(
                                          color: AppColors.primaryOrange,
                                        ),
                                      ),
                                    ),
                                  )
                                : Center(
                                    child: Text(
                                      group.name.isNotEmpty
                                          ? group.name.characters.first.toUpperCase()
                                          : 'G',
                                      style: AppTextStyles.headline4(
                                        color: AppColors.primaryOrange,
                                      ),
                                    ),
                                  ),
                          ),
                          AppSizes.xs.pw,
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  group.name,
                                  style: AppTextStyles.subtitle1(
                                    color: AppColors.white,
                                  ).copyWith(fontWeight: AppFontWeights.bold),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                AppSizes.xxxs.ph,
                                Row(
                                  children: [
                                    HugeIcon(
                                      icon: group.isPublic
                                          ? HugeIconsStrokeRounded.globe02
                                          : HugeIconsStrokeRounded.squareLock01,
                                      color: AppColors.primaryOrange,
                                      size: 13,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      "${group.memberCount ?? 0} Members",
                                      style: AppTextStyles.overLine(
                                        color: AppColors.creamWhite,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
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

