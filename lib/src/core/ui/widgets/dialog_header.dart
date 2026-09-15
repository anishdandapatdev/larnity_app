import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:larnity/src/core/constants/app_size.dart';
import 'package:larnity/src/core/extensions/extensions.dart';
import 'package:larnity/src/core/theme/app_colors.dart';
import 'package:larnity/src/core/theme/theme.dart';

class DialogHeader extends StatelessWidget {
  final String title;
  final String description;
  const DialogHeader({
    super.key,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              onPressed: () {
                context.pop();
              },
              icon: Icon(Icons.close),
            ),
          ],
        ),
        Text(title, style: AppTextStyles.headline4()),
        Text(
          description,
          style: AppTextStyles.overLine(color: AppColors.skyBlue),
        ),
        AppSizes.lg.ph,
      ],
    );
  }
}
