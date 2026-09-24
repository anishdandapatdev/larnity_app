import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import 'package:larnity/src/core/constants/app_size.dart';
import 'package:larnity/src/core/extensions/extensions.dart';
import 'package:larnity/src/core/service/supabase/src/supabase_storage_service.dart';
import 'package:larnity/src/core/theme/app_colors.dart';
import 'package:larnity/src/core/theme/theme.dart';
import 'package:larnity/src/features/group/data/models/group_model.dart';
import 'package:larnity/src/features/group/presentation/provider/group_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:larnity/src/core/router/router.dart';

class GroupCard extends ConsumerWidget {
  final GroupModel? group;

  const GroupCard({super.key, this.group});

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

  Widget _buildPlaceholderBanner(String name) {
    return Container(
      width: double.infinity,
      height: 140,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryOrange.withValues(alpha: 0.3),
            AppColors.darkBgContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.group_outlined,
          size: 48,
          color: AppColors.white.withValues(alpha: 0.6),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupName = group?.name ?? "Untitled Group";
    final groupDescription = group?.description ?? "No description provided";
    final groupCategory = group?.category ?? "Uncategorized";
    final memberCount = group?.memberCount != null ? "${group!.memberCount}" : "0";

    final bannerUrl = _resolveImageUrl(ref, group?.thumbnail) ??
        _resolveImageUrl(ref, group?.icon);
    final iconUrl = _resolveImageUrl(ref, group?.icon) ??
        _resolveImageUrl(ref, group?.thumbnail);

    final price = group?.lifetimePrice != null
        ? "₹${group!.lifetimePrice}/lifetime"
        : (group?.monthlyPrice != null
            ? "₹${group!.monthlyPrice}/month"
            : (group?.yearlyPrice != null
                ? "₹${group!.yearlyPrice}/year"
                : "Free"));

    return GestureDetector(
      onTap: () {
        if (group != null) {
          ref.read(groupProvider.notifier).setSelectedGroup(group);
          context.pushNamed(Routes.groupDetails, extra: group);
        }
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.xs),
        ),
        color: AppColors.darkBgContainer,
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Group image or banner
            ClipRRect(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppSizes.xs),
              ),
              child: SizedBox(
                height: 140,
                width: double.infinity,
                child: bannerUrl != null
                    ? Image.network(
                        bannerUrl,
                        width: double.infinity,
                        height: 140,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return Container(
                            color: AppColors.darkBg,
                            child: const Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) =>
                            _buildPlaceholderBanner(groupName),
                      )
                    : _buildPlaceholderBanner(groupName),
              ),
            ),
            // Group details
            Padding(
              padding: EdgeInsets.all(AppSizes.xs),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Group icon & name
                  Row(
                    children: [
                      if (iconUrl != null) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(AppSizes.xxxs),
                          child: Image.network(
                            iconUrl,
                            width: 28,
                            height: 28,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) =>
                                const SizedBox.shrink(),
                          ),
                        ),
                        AppSizes.xxs.pw,
                      ],
                      Expanded(
                        child: Text(
                          groupName,
                          style: AppTextStyles.bodyText1().copyWith(
                            fontWeight: AppFontWeights.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  AppSizes.xxxs.ph,
                  // Group category
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSizes.xxxs,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryOrange.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      groupCategory,
                      style: AppTextStyles.caption2(
                        color: AppColors.primaryOrange,
                      ),
                    ),
                  ),
                  AppSizes.xxxs.ph,
                  // Group description
                  Text(
                    groupDescription,
                    style: AppTextStyles.caption2(
                      color: AppColors.white.withValues(alpha: 0.7),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  AppSizes.xxxs.ph,
                  Divider(color: AppColors.borderBrown, height: 1),
                  AppSizes.xxxs.ph,
                  // Group stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          HugeIcon(
                            icon: HugeIconsStrokeRounded.userMultiple02,
                            color: AppColors.white,
                            size: 14,
                          ),
                          AppSizes.xxxs.pw,
                          Text(
                            "$memberCount Members",
                            style: AppTextStyles.caption2(),
                          ),
                        ],
                      ),
                      Text(
                        price,
                        style: AppTextStyles.caption2(
                          color: AppColors.primaryOrange,
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
    );
  }
}