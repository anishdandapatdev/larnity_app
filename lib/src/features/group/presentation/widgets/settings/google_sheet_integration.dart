import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import 'package:larnity/src/core/constants/app_size.dart';
import 'package:larnity/src/core/constants/app_strings.dart';
import 'package:larnity/src/core/extensions/extensions.dart';
import 'package:larnity/src/core/theme/app_colors.dart';
import 'package:larnity/src/core/theme/theme.dart';
import 'package:larnity/src/core/ui/widgets/app_button.dart';
import 'package:larnity/src/core/utils/show_snackbar.dart';
import 'package:larnity/src/features/group/presentation/provider/group_provider.dart';

class GoogleSheetIntegration extends ConsumerStatefulWidget {
  const GoogleSheetIntegration({super.key});

  @override
  ConsumerState<GoogleSheetIntegration> createState() =>
      _GoogleSheetIntegrationState();
}

class _GoogleSheetIntegrationState
    extends ConsumerState<GoogleSheetIntegration> {
  late final TextEditingController _sheetIdController;
  bool _enableSync = false;
  bool _isLoading = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _sheetIdController = TextEditingController();
  }

  void _initFromGroup() {
    if (_initialized) return;
    final group = ref.read(groupProvider).group;
    if (group == null) return;

    _sheetIdController.text = group.googleSheetId ?? '';
    _enableSync = group.enableGoogleSheetSync ?? false;
    _initialized = true;
  }

  @override
  void dispose() {
    _sheetIdController.dispose();
    super.dispose();
  }

  Future<void> _saveSettings() async {
    final group = ref.read(groupProvider).group;
    if (group == null) return;

    setState(() => _isLoading = true);

    final sheetId = _sheetIdController.text.trim();
    final updated = group.copyWith(
      googleSheetId: sheetId.isEmpty ? null : sheetId,
      enableGoogleSheetSync: _enableSync,
    );

    await ref.read(groupProvider.notifier).updateGroup(
          group: updated,
          successCallBack: () {
            if (mounted) {
              setState(() => _isLoading = false);
              showSuccessToast(
                content: "Google Sheet integration updated successfully",
              );
              context.pop();
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
    _initFromGroup();
    final isConnected = _sheetIdController.text.trim().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.all(AppSizes.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.googleSheetIntegration,
                style: AppTextStyles.headline4(color: AppColors.white),
              ),
              IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.close, color: Colors.white),
              ),
            ],
          ),
          Text(
            AppStrings.googleSheetIntegrationDialogDesc,
            style: AppTextStyles.overLine(color: AppColors.skyBlue),
          ),
          AppSizes.md.ph,
          Container(
            padding: const EdgeInsets.all(AppSizes.xs),
            decoration: BoxDecoration(
              color: AppColors.borderBrown,
              borderRadius: BorderRadius.circular(AppSizes.xxxs),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSizes.xxxs),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: AppColors.white.withValues(alpha: 0.1),
                  ),
                  child: const Center(
                    child: HugeIcon(
                      icon: HugeIconsStrokeRounded.googleSheet,
                      color: AppColors.primaryOrange,
                    ),
                  ),
                ),
                AppSizes.xxxs.pw,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isConnected ? "Connected" : AppStrings.notConnected,
                        style: AppTextStyles.headline4(
                          color: isConnected ? AppColors.lightGreen : Colors.white,
                        ),
                      ),
                      Text(
                        isConnected
                            ? "Syncing group members with Google Sheet"
                            : AppStrings.notConnectedDesc,
                        style: AppTextStyles.overLine(
                          color: AppColors.skyBlue,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          AppSizes.xs.ph,
          Text(
            "Google Sheet ID or Spreadsheet URL",
            style: AppTextStyles.overLine(color: AppColors.white),
          ),
          AppSizes.xxxs.ph,
          TextFormField(
            controller: _sheetIdController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.darkBgContainer,
              hintText: "e.g. 1BxiMVs0XRA5nFMdKvBdBZjgmUUqptlbs74OgvE2upms",
              hintStyle: AppTextStyles.button(color: AppColors.grey600),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.xxxs),
                borderSide: BorderSide(
                  color: AppColors.skyBlue.withValues(alpha: 0.4),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.xxxs),
                borderSide: const BorderSide(color: AppColors.skyBlue),
              ),
            ),
          ),
          AppSizes.xs.ph,
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.xs,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: AppColors.borderBrown,
              borderRadius: BorderRadius.circular(AppSizes.xxxs),
            ),
            child: CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: _enableSync,
              activeColor: AppColors.primaryOrange,
              onChanged: (val) => setState(() => _enableSync = val ?? false),
              title: Text(
                AppStrings.enableGoogleSheetSync,
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
              subtitle: Text(
                AppStrings.enableGoogleSheetSyncDesc,
                style: const TextStyle(color: Colors.grey, fontSize: 11),
              ),
            ),
          ),
          AppSizes.md.ph,
          AppButton(
            isLoading: _isLoading,
            onPressed: _isLoading ? () {} : _saveSettings,
            label: AppStrings.saveSettings,
            labelStyle: AppTextStyles.bodyText2(color: AppColors.black),
            bgColor: AppColors.primaryOrange,
            radius: AppSizes.xxxs,
          ),
        ],
      ),
    );
  }
}

