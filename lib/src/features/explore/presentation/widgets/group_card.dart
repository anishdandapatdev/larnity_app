import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import 'package:larnity/src/core/constants/app_size.dart';
import 'package:larnity/src/core/extensions/extensions.dart';
import 'package:larnity/src/core/extensions/screen_size_extension.dart';
import 'package:larnity/src/core/theme/app_colors.dart';
import 'package:larnity/src/core/theme/theme.dart';
import 'package:larnity/src/features/group/data/models/group_model.dart';
import 'package:larnity/src/features/group/presentation/provider/group_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:larnity/src/core/router/router.dart';

class GroupCard extends ConsumerWidget {
  final GroupModel? group;
  
  const GroupCard({super.key, this.group});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use actual group data if available
    final groupName = group?.name ?? "Untitled Group";
    final groupDescription = group?.description ?? "No description provided";
    final groupCategory = group?.category ?? "Uncategorized";
    final memberCount = "0"; // This would come from actual data in a real implementation
    final price = group?.lifetimePrice != null ? "₹${group!.lifetimePrice}/lifetime" : "Free";

    return GestureDetector(
      onTap: () {
        if (group != null) {
          // Set the selected group in the provider
          ref.read(groupProvider.notifier).setSelectedGroup(group);
          // Navigate to the group details screen
          context.pushNamed(Routes.groupDetails);
        }
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.xs),
        ),
        color: AppColors.darkBgContainer,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Group image or icon
            Container(
              height: 0.12.sh,
              decoration: BoxDecoration(
                color: AppColors.primaryOrange,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppSizes.xs),
                ),
              ),
              child: group?.thumbnail != null
                  ? Image.network(
                      group!.thumbnail!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => 
                        Center(
                          child: Icon(
                            Icons.group,
                            size: 30,
                            color: AppColors.white,
                          ),
                        ),
                    )
                  : Center(
                      child: Icon(
                        Icons.group,
                        size: 30,
                        color: AppColors.white,
                      ),
                    ),
            ),
            // Group details
            Padding(
              padding: EdgeInsets.all(AppSizes.xs),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Group name
                  Text(
                    groupName,
                    style: AppTextStyles.bodyText1(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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