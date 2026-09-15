import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import 'package:larnity/src/core/constants/app_size.dart';
import 'package:larnity/src/core/extensions/extensions.dart';
import 'package:larnity/src/core/router/router.dart';
import 'package:larnity/src/core/theme/app_colors.dart';
import 'package:larnity/src/core/theme/theme.dart';

class GroupHomeScreen extends StatefulWidget {
  const GroupHomeScreen({super.key});

  @override
  State<GroupHomeScreen> createState() => _GroupHomeScreenState();
}

class _GroupHomeScreenState extends State<GroupHomeScreen> {
  bool _showOnboarding = true;

  Widget _buildRoomButton(BuildContext context, String title, dynamic icon, String routeName) {
    return InkWell(
      onTap: () => context.pushNamed(routeName),
      borderRadius: BorderRadius.circular(AppSizes.xxxs),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.black.withValues(alpha: 0.5),
          border: Border.all(color: AppColors.primaryOrange.withValues(alpha: 0.5)),
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
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSizes.xs),
        child: Column(
          children: [
            AppSizes.xs.ph,
            if (_showOnboarding)
              Container(
                padding: EdgeInsets.all(AppSizes.xs),
                margin: EdgeInsets.only(bottom: AppSizes.xs),
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
                        HugeIcon(
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
                              _showOnboarding = false;
                            });
                          },
                          icon: HugeIcon(
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
                padding: EdgeInsets.only(bottom: AppSizes.lg),
                children: [
                  _buildRoomButton(context, "Discussion Room", HugeIconsStrokeRounded.home03, Routes.discussionRoom),
                  _buildRoomButton(context, "Class Room", HugeIconsStrokeRounded.geometricShapes01, Routes.classRoom),
                  _buildRoomButton(context, "Live Class", HugeIconsStrokeRounded.computerVideo, Routes.liveClassRoom),
                  _buildRoomButton(context, "Events Room", HugeIconsStrokeRounded.calendar03, Routes.eventRoom),
                  _buildRoomButton(context, "Members Room", HugeIconsStrokeRounded.userMultiple, Routes.membersRoom),
                  _buildRoomButton(context, "Doubt Room", HugeIconsStrokeRounded.sourceCodeSquare, Routes.doubtRoom),
                  _buildRoomButton(context, "Challenges Room", HugeIconsStrokeRounded.adventure, Routes.challengeRoom),
                  _buildRoomButton(context, "Treasure Room", HugeIconsStrokeRounded.notebook02, Routes.treasureRoom),
                  _buildRoomButton(context, "Product Room", HugeIconsStrokeRounded.shoppingBag01, Routes.productRoom),
                  _buildRoomButton(context, "Service Room", HugeIconsStrokeRounded.documentValidation, Routes.serviceRoom),
                  _buildRoomButton(context, "Job Room", HugeIconsStrokeRounded.id, Routes.jobRoom),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
