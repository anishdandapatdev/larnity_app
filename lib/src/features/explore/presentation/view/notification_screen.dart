import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import 'package:larnity/src/core/constants/app_size.dart';
import 'package:larnity/src/core/extensions/extensions.dart';
import 'package:larnity/src/core/theme/app_colors.dart';
import 'package:larnity/src/core/theme/theme.dart';
import 'package:larnity/src/core/ui/widgets/app_dropdown.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: SizedBox.shrink(),
        actions: [
          IconButton(
            onPressed: () {
              context.pop();
            },
            icon: Icon(Icons.close),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSizes.xs),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    HugeIcon(
                      icon: HugeIconsStrokeRounded.notification01,
                      color: AppColors.blue,
                    ),
                    AppSizes.xxs.pw,
                    Text(
                      "Notifications",
                      style: AppTextStyles.headline4().copyWith(
                        fontWeight: AppFontWeights.black,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      "Mark all as read",
                      style: AppTextStyles.subtitle2(color: AppColors.blue),
                    ),
                    AppSizes.xxxs.ph,
                    AppDropdown(
                      button: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSizes.xxs,
                          vertical: AppSizes.xxxs,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(AppSizes.xxxs),
                        ),
                        child: Row(
                          children: [
                            Text(
                              "All groups",
                              style: AppTextStyles.caption2(
                                color: AppColors.black,
                              ),
                            ),
                            AppSizes.xxxs.pw,
                            HugeIcon(
                              icon: HugeIconsStrokeRounded.arrowDown01,
                              color: AppColors.black,
                            ),
                          ],
                        ),
                      ),
                      items: [
                        AppDropdownItem(value: "all", label: 'All Groups'),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            Divider(color: AppColors.white),
            AppSizes.xs.ph,
            Expanded(
              child: ListView.separated(
                itemBuilder: (context, index) => Container(
                  decoration: BoxDecoration(
                    color: AppColors.black,
                    border: Border.all(color: AppColors.borderBrown),
                    borderRadius: BorderRadius.circular(AppSizes.xxxs),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSizes.xs),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "🎉Group Created",
                              style: AppTextStyles.bodyText1(),
                            ),
                            HugeIcon(
                              icon: HugeIconsStrokeRounded.delete02,
                              color: AppColors.red,
                            ),
                          ],
                        ),
                        AppSizes.xxs.ph,
                        Text(
                          "You’ve successfully created the group \"sifat\". Next, complete your group onboarding and submit it for review.",
                        ),
                        AppSizes.xxs.ph,
                        Row(
                          children: [
                            Text("5 days ago"),
                            AppSizes.lg.pw,
                            Text("in sifat"),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                separatorBuilder: (_, _) => AppSizes.xxxs.ph,
                itemCount: 5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
