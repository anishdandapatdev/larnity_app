import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import 'package:larnity/src/core/constants/app_assets.dart';
import 'package:larnity/src/core/constants/app_size.dart';
import 'package:larnity/src/core/constants/app_strings.dart';
import 'package:larnity/src/core/extensions/extensions.dart';
import 'package:larnity/src/core/theme/app_colors.dart';
import 'package:larnity/src/core/theme/theme.dart';
import 'package:larnity/src/core/ui/widgets/app_button.dart';
import 'package:larnity/src/core/utils/show_snackbar.dart';
import 'package:larnity/src/features/group/presentation/provider/group_provider.dart';

class PaymentSettingsScreen extends ConsumerStatefulWidget {
  const PaymentSettingsScreen({super.key});

  @override
  ConsumerState<PaymentSettingsScreen> createState() =>
      _PaymentSettingsScreenState();
}

class _PaymentSettingsScreenState extends ConsumerState<PaymentSettingsScreen> {
  bool _isLoading = false;

  void _configureGateway(String gatewayName, String currentConfigKey) {
    final group = ref.read(groupProvider).group;
    if (group == null) return;

    final controller = TextEditingController(
      text: (group.landingSettings?[currentConfigKey] as String?) ?? '',
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.darkBgContainer,
        title: Text(
          "Connect $gatewayName",
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Enter your $gatewayName Merchant / Vendor Account ID:",
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
            AppSizes.xs.ph,
            TextFormField(
              controller: controller,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.bgBlue,
                hintText: "e.g. VEND_123456",
                hintStyle: const TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryOrange,
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              _saveGatewayConfig(currentConfigKey, controller.text.trim());
            },
            child: const Text(
              "Save & Connect",
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _saveGatewayConfig(String key, String value) {
    final group = ref.read(groupProvider).group;
    if (group == null) return;

    setState(() => _isLoading = true);

    final currentSettings = Map<String, dynamic>.from(group.landingSettings ?? {});
    currentSettings[key] = value;
    currentSettings['preferredGateway'] = key.contains('cashfree') ? 'Cashfree' : 'Paymintro';

    final updated = group.copyWith(landingSettings: currentSettings);

    ref.read(groupProvider.notifier).updateGroup(
          group: updated,
          successCallBack: () {
            if (mounted) {
              setState(() => _isLoading = false);
              showInfoToast(content: "Payment settings saved successfully!");
            }
          },
          failureCallBack: (err) {
            if (mounted) {
              setState(() => _isLoading = false);
              showErrorToast(content: err);
            }
          },
        );
  }

  @override
  Widget build(BuildContext context) {
    final group = ref.watch(groupProvider).group;

    if (group == null) {
      return const Scaffold(
        backgroundColor: AppColors.darkBg,
        body: Center(
          child: Text("No group selected", style: TextStyle(color: Colors.white)),
        ),
      );
    }

    final paymintroVendor = group.landingSettings?['paymintroVendorId'] as String?;
    final cashfreeVendor = group.landingSettings?['cashfreeVendorId'] as String?;

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.xs),
        child: Column(
          children: [
            AppSizes.xs.ph,
            // Paymintro Card
            Container(
              padding: const EdgeInsets.all(AppSizes.xs),
              decoration: BoxDecoration(
                color: AppColors.black,
                border: Border.all(
                  color: paymintroVendor != null && paymintroVendor.isNotEmpty
                      ? Colors.green
                      : AppColors.borderBrown,
                ),
                borderRadius: BorderRadius.circular(AppSizes.xxxs),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            height: 40,
                            width: 40,
                            decoration: const BoxDecoration(shape: BoxShape.circle),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(AppSizes.xxxlg),
                              child: Image.asset(AppAssets.images.paymintro),
                            ),
                          ),
                          AppSizes.xxxs.pw,
                          Text(
                            AppStrings.paymintro,
                            style: AppTextStyles.button().copyWith(
                              fontWeight: AppFontWeights.bold,
                            ),
                          ),
                        ],
                      ),
                      if (paymintroVendor != null && paymintroVendor.isNotEmpty)
                        const Chip(
                          label: Text("Connected", style: TextStyle(fontSize: 11, color: Colors.green)),
                          backgroundColor: Color(0x224CAF50),
                        ),
                    ],
                  ),
                  AppSizes.xs.ph,
                  Text(
                    AppStrings.paymintroDesc,
                    style: AppTextStyles.overLine(),
                  ),
                  if (paymintroVendor != null && paymintroVendor.isNotEmpty) ...[
                    AppSizes.xs.ph,
                    Text(
                      "Vendor ID: $paymintroVendor",
                      style: AppTextStyles.caption(color: AppColors.skyBlue),
                    ),
                  ],
                  AppSizes.xs.ph,
                  AppButton(
                    isExpanded: false,
                    onPressed: _isLoading
                        ? () {}
                        : () => _configureGateway("Paymintro", "paymintroVendorId"),
                    prefix: const HugeIcon(
                      icon: HugeIconsStrokeRounded.cloud,
                      color: AppColors.black,
                    ),
                    label: paymintroVendor != null && paymintroVendor.isNotEmpty
                        ? "Edit Credentials"
                        : AppStrings.connect,
                    labelStyle: AppTextStyles.bodyText2(),
                    bgColor: AppColors.primaryOrange,
                    radius: AppSizes.xxxs,
                  ),
                ],
              ),
            ),
            AppSizes.xs.ph,
            // Cashfree Card
            Container(
              padding: const EdgeInsets.all(AppSizes.xs),
              decoration: BoxDecoration(
                color: AppColors.black,
                border: Border.all(
                  color: cashfreeVendor != null && cashfreeVendor.isNotEmpty
                      ? Colors.green
                      : AppColors.borderBrown,
                ),
                borderRadius: BorderRadius.circular(AppSizes.xxxs),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            height: 40,
                            width: 40,
                            decoration: const BoxDecoration(shape: BoxShape.circle),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(AppSizes.xxxlg),
                              child: Image.asset(AppAssets.images.cashfree),
                            ),
                          ),
                          AppSizes.xxxs.pw,
                          Text(
                            AppStrings.cashfree,
                            style: AppTextStyles.button().copyWith(
                              fontWeight: AppFontWeights.bold,
                            ),
                          ),
                        ],
                      ),
                      if (cashfreeVendor != null && cashfreeVendor.isNotEmpty)
                        const Chip(
                          label: Text("Connected", style: TextStyle(fontSize: 11, color: Colors.green)),
                          backgroundColor: Color(0x224CAF50),
                        ),
                    ],
                  ),
                  AppSizes.xs.ph,
                  Text(
                    AppStrings.cashfreeDesc,
                    style: AppTextStyles.overLine(),
                  ),
                  if (cashfreeVendor != null && cashfreeVendor.isNotEmpty) ...[
                    AppSizes.xs.ph,
                    Text(
                      "Vendor ID: $cashfreeVendor",
                      style: AppTextStyles.caption(color: AppColors.skyBlue),
                    ),
                  ],
                  AppSizes.xs.ph,
                  AppButton(
                    isExpanded: false,
                    onPressed: _isLoading
                        ? () {}
                        : () => _configureGateway("Cashfree", "cashfreeVendorId"),
                    prefix: const HugeIcon(
                      icon: HugeIconsStrokeRounded.cloud,
                      color: AppColors.primaryOrange,
                    ),
                    label: cashfreeVendor != null && cashfreeVendor.isNotEmpty
                        ? "Edit Vendor Account"
                        : AppStrings.createVendor,
                    labelStyle: AppTextStyles.bodyText2(
                      color: AppColors.primaryOrange,
                    ),
                    bgColor: AppColors.infoCardColor,
                    borderColor: AppColors.primaryOrange,
                    radius: AppSizes.xxxs,
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
