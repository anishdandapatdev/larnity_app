import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import 'package:larnity/src/core/constants/app_size.dart';
import 'package:larnity/src/core/constants/app_strings.dart';
import 'package:larnity/src/core/extensions/extensions.dart';
import 'package:larnity/src/core/theme/app_colors.dart';
import 'package:larnity/src/core/theme/theme.dart';
import 'package:larnity/src/core/ui/widgets/app_table.dart';

class MemberManagementScreen extends StatelessWidget {
  MemberManagementScreen({super.key});

  final List<Map<String, dynamic>> sampleData = [
    {
      AppStrings.memberName: 'Alex',
      AppStrings.activePlan: 'MONTHLY',
      AppStrings.remainingDays: 10,
      AppStrings.status: true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.xs),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppStrings.allMembers, style: AppTextStyles.headline4()),
            Text(
              AppStrings.allMembersDesc,
              style: AppTextStyles.overLine(color: AppColors.skyBlue),
            ),
            AppSizes.lg.ph,
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.darkBgContainer,
                      hintText: AppStrings.searchMembers,
                      prefixIcon: HugeIcon(
                        icon: HugeIconsStrokeRounded.search01,
                        color: AppColors.white,
                      ),
                      hintStyle: AppTextStyles.button(color: AppColors.skyBlue),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSizes.xxxs),
                        borderSide: BorderSide(
                          color: AppColors.skyBlue.withValues(alpha: 0.5),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSizes.xxxs),
                        borderSide: BorderSide(color: AppColors.skyBlue),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            AppSizes.xs.ph,
            Expanded(
              child: AppTable(
                columns: [
                  TableColumn(
                    title: AppStrings.memberName,
                    width: 140,
                    cellBuilder: (index) => Row(
                      children: [
                        Expanded(
                          child: Text(
                            sampleData[index][AppStrings.memberName],
                            style: const TextStyle(fontWeight: FontWeight.w500),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.copy, size: 16, color: Colors.grey),
                      ],
                    ),
                  ),
                  TableColumn(
                    title: AppStrings.activePlan,
                    width: 120,
                    cellBuilder: (index) => Text(
                      sampleData[index][AppStrings.activePlan],
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                  TableColumn(
                    title: AppStrings.remainingDays,
                    width: 160,
                    cellBuilder: (index) => Text(
                      '${sampleData[index][AppStrings.remainingDays]}%',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  TableColumn(
                    title: AppStrings.status,
                    width: 80,
                    cellBuilder: (index) => Switch(
                      value: sampleData[index][AppStrings.status],
                      onChanged: (value) {
                        // Handle switch toggle
                        debugPrint('Toggle status for row $index');
                      },
                      activeThumbColor: Colors.green,
                    ),
                  ),
                  TableColumn(
                    title: AppStrings.actions,
                    width: 100,
                    cellBuilder: (index) => ElevatedButton(
                      onPressed: () {
                        debugPrint('Delete row $index');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade600,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        minimumSize: Size.zero,
                      ),
                      child: const Text(
                        'Delete',
                        style: TextStyle(fontSize: 12, color: Colors.white),
                      ),
                    ),
                  ),
                ],
                rowCount: 0,
                emptyWidget: Text(AppStrings.noResults),
              ),
            ),
            AppSizes.xs.ph,
          ],
        ),
      ),
    );
  }
}
