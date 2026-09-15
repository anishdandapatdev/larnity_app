import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import 'package:larnity/src/core/constants/app_size.dart';
import 'package:larnity/src/core/constants/app_strings.dart';
import 'package:larnity/src/core/extensions/extensions.dart';
import 'package:larnity/src/core/theme/app_colors.dart';
import 'package:larnity/src/core/theme/theme.dart';
import 'package:larnity/src/core/ui/widgets/app_button.dart';
import 'package:larnity/src/core/ui/widgets/app_table.dart';
import 'package:larnity/src/features/group/presentation/widgets/settings/create_promo_code.dart';

class PromoCodeSettingsScreen extends StatelessWidget {
  PromoCodeSettingsScreen({super.key});

  final List<Map<String, dynamic>> sampleData = [
    {
      'promoCode': '9Z4377BB',
      'planType': 'MONTHLY',
      'discount': 10,
      'usage': '0/5',
      'status': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.xs),
        child: Column(
          children: [
            AppSizes.xs.ph,
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppStrings.promoCodes,
                  style: AppTextStyles.headline2(color: AppColors.white),
                ),

                AppButton(
                  isExpanded: false,
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) =>
                          AlertDialog(content: CreatePromoCode()),
                    );
                  },
                  prefix: HugeIcon(
                    icon: HugeIconsStrokeRounded.addCircle,
                    color: AppColors.black,
                  ),
                  label: AppStrings.createPromoCode,
                  labelStyle: AppTextStyles.bodyText2(color: AppColors.black),
                  bgColor: AppColors.white,
                  radius: AppSizes.xxxs,
                ),
              ],
            ),
            AppSizes.xs.ph,
            Expanded(
              child: AppTable(
                columns: [
                  TableColumn(
                    title: 'Promo Code',
                    width: 140,
                    cellBuilder: (index) => Row(
                      children: [
                        Expanded(
                          child: Text(
                            sampleData[index]['promoCode'],
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
                    title: 'Plan Type',
                    width: 120,
                    cellBuilder: (index) => Text(
                      sampleData[index]['planType'],
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                  TableColumn(
                    title: 'Discount',
                    width: 100,
                    cellBuilder: (index) => Text(
                      '${sampleData[index]['discount']}%',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  TableColumn(
                    title: 'Usage',
                    width: 80,
                    cellBuilder: (index) => Text(
                      sampleData[index]['usage'],
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                  TableColumn(
                    title: 'Status',
                    width: 80,
                    cellBuilder: (index) => Switch(
                      value: sampleData[index]['status'],
                      onChanged: (value) {
                        // Handle switch toggle
                        debugPrint('Toggle status for row $index');
                      },
                      activeThumbColor: Colors.green,
                    ),
                  ),
                  TableColumn(
                    title: 'Actions',
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
                emptyWidget: Text(AppStrings.noPromoCode),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
