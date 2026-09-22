import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:larnity/src/core/constants/app_size.dart';
import 'package:larnity/src/core/extensions/extensions.dart';
import 'package:larnity/src/core/theme/app_colors.dart';
import 'package:larnity/src/core/theme/theme.dart';

class ManageGroupTabCard extends StatelessWidget {
  const ManageGroupTabCard({
    super.key,
    required this.onSwitch,
    required this.icon,
    required this.title,
    this.value = true,
  });

  final void Function(bool) onSwitch;
  final List<List<dynamic>> icon;
  final String title;
  final bool value;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkBrown,
        borderRadius: BorderRadius.circular(AppSizes.xxxs),
      ),
      child: SwitchListTile(
        value: value,
        onChanged: onSwitch,
        activeThumbColor: AppColors.black,
        activeTrackColor: AppColors.white,
        title: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: HugeIcon(icon: icon, color: AppColors.primaryOrange),
            ),
            AppSizes.xs.pw,
            Text(title, style: AppTextStyles.bodyText1()),
          ],
        ),
      ),
    );
  }
}
