import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import 'package:larnity/src/core/constants/app_size.dart';
import 'package:larnity/src/core/constants/app_strings.dart';
import 'package:larnity/src/core/extensions/extensions.dart';
import 'package:larnity/src/core/theme/app_colors.dart';
import 'package:larnity/src/core/theme/theme.dart';
import 'package:larnity/src/core/ui/widgets/app_button.dart';
import 'package:larnity/src/core/utils/show_snackbar.dart';
import 'package:larnity/src/features/group/data/models/group_model.dart';
import 'package:larnity/src/features/group/presentation/provider/group_provider.dart';

class SubscriptionSettingsScreen extends ConsumerStatefulWidget {
  const SubscriptionSettingsScreen({super.key});

  @override
  ConsumerState<SubscriptionSettingsScreen> createState() =>
      _SubscriptionSettingsScreenState();
}

class _SubscriptionSettingsScreenState
    extends ConsumerState<SubscriptionSettingsScreen> {
  late final TextEditingController _monthlyCtrl;
  late final TextEditingController _yearlyCtrl;
  late final TextEditingController _lifetimeCtrl;
  bool _isLoading = false;
  String? _initializedGroupId;

  @override
  void initState() {
    super.initState();
    _monthlyCtrl = TextEditingController();
    _yearlyCtrl = TextEditingController();
    _lifetimeCtrl = TextEditingController();
  }

  void _syncWithGroup(GroupModel? group) {
    if (group == null || group.id == _initializedGroupId) return;
    _initializedGroupId = group.id;
    _monthlyCtrl.text = (group.monthlyPrice ?? 0).toString();
    _yearlyCtrl.text = (group.yearlyPrice ?? 0).toString();
    _lifetimeCtrl.text = (group.lifetimePrice ?? 0).toString();
  }

  @override
  void dispose() {
    _monthlyCtrl.dispose();
    _yearlyCtrl.dispose();
    _lifetimeCtrl.dispose();
    super.dispose();
  }

  Future<void> _updatePrices(GroupModel currentGroup) async {
    final monthly = int.tryParse(_monthlyCtrl.text.trim()) ?? 0;
    final yearly = int.tryParse(_yearlyCtrl.text.trim()) ?? 0;
    final lifetime = int.tryParse(_lifetimeCtrl.text.trim()) ?? 0;

    setState(() => _isLoading = true);

    final updatedGroup = currentGroup.copyWith(
      monthlyPrice: monthly,
      yearlyPrice: yearly,
      lifetimePrice: lifetime,
      updatedAt: DateTime.now(),
    );

    ref.read(groupProvider.notifier).updateGroup(
          group: updatedGroup,
          successCallBack: () {
            if (mounted) {
              setState(() => _isLoading = false);
              showInfoToast(content: "Subscription pricing updated successfully!");
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
    final groupState = ref.watch(groupProvider);
    final group = groupState.group;

    if (group == null) {
      return const Scaffold(
        backgroundColor: AppColors.darkBg,
        body: Center(
          child: Text(
            "No group selected",
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    _syncWithGroup(group);

    final monthlyPrice = group.monthlyPrice ?? 0;
    final yearlyPrice = group.yearlyPrice ?? 0;
    final lifetimePrice = group.lifetimePrice ?? 0;
    final yearlyMoPrice = (yearlyPrice / 12).toStringAsFixed(2);

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.xs),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSizes.xs.ph,
              Text(
                AppStrings.groupSubscriptions,
                style: AppTextStyles.headline1(color: AppColors.white),
              ),
              AppSizes.xxxs.ph,
              Container(
                padding: const EdgeInsets.all(AppSizes.xs),
                decoration: BoxDecoration(
                  color: AppColors.bgBlue,
                  border: Border.all(
                    color: AppColors.skyBlue.withValues(alpha: 0.5),
                  ),
                  borderRadius: BorderRadius.circular(AppSizes.xxxs),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.setSubscriptionPrices,
                      style: AppTextStyles.headline4().copyWith(
                        fontWeight: AppFontWeights.bold,
                      ),
                    ),
                    AppSizes.lg.ph,
                    Text(
                      AppStrings.monthlyPrice,
                      style: AppTextStyles.overLine(),
                    ),
                    TextFormField(
                      controller: _monthlyCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.darkBgContainer,
                        prefixText: "₹ ",
                        prefixStyle: const TextStyle(color: Colors.white),
                        hintText: "0",
                        hintStyle: AppTextStyles.button(
                          color: AppColors.skyBlue,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSizes.xxxs),
                          borderSide: BorderSide(
                            color: AppColors.skyBlue.withValues(alpha: 0.5),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSizes.xxxs),
                          borderSide: const BorderSide(color: AppColors.skyBlue),
                        ),
                      ),
                    ),
                    AppSizes.xs.ph,
                    Text(
                      AppStrings.yearlyPrice,
                      style: AppTextStyles.overLine(),
                    ),
                    TextFormField(
                      controller: _yearlyCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.darkBgContainer,
                        prefixText: "₹ ",
                        prefixStyle: const TextStyle(color: Colors.white),
                        hintText: "0",
                        hintStyle: AppTextStyles.button(
                          color: AppColors.skyBlue,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSizes.xxxs),
                          borderSide: BorderSide(
                            color: AppColors.skyBlue.withValues(alpha: 0.5),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSizes.xxxs),
                          borderSide: const BorderSide(color: AppColors.skyBlue),
                        ),
                      ),
                    ),
                    AppSizes.xs.ph,
                    Text(
                      AppStrings.lifetimePrice,
                      style: AppTextStyles.overLine(),
                    ),
                    TextFormField(
                      controller: _lifetimeCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.darkBgContainer,
                        prefixText: "₹ ",
                        prefixStyle: const TextStyle(color: Colors.white),
                        hintText: "0",
                        hintStyle: AppTextStyles.button(
                          color: AppColors.skyBlue,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSizes.xxxs),
                          borderSide: BorderSide(
                            color: AppColors.skyBlue.withValues(alpha: 0.5),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSizes.xxxs),
                          borderSide: const BorderSide(color: AppColors.skyBlue),
                        ),
                      ),
                    ),
                    AppSizes.lg.ph,
                    AppButton(
                      onPressed: _isLoading ? () {} : () => _updatePrices(group),
                      bgColor: AppColors.primaryOrange,
                      radius: AppSizes.xxxs,
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.black,
                              ),
                            )
                          : Text(
                              AppStrings.updatePrices,
                              style: AppTextStyles.bodyText2(color: Colors.black),
                            ),
                    ),
                  ],
                ),
              ),
              AppSizes.lg.ph,
              // Monthly Card
              Container(
                padding: const EdgeInsets.all(AppSizes.xs),
                decoration: BoxDecoration(
                  color: AppColors.bgBlue,
                  border: Border.all(
                    color: AppColors.skyBlue.withValues(alpha: 0.5),
                  ),
                  borderRadius: BorderRadius.circular(AppSizes.xxxs),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppStrings.monthly, style: AppTextStyles.headline4()),
                    Text(
                      AppStrings.billedEveryMonth,
                      style: AppTextStyles.overLine(
                        color: AppColors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    AppSizes.xs.ph,
                    Text("₹$monthlyPrice", style: AppTextStyles.headline1()),
                    AppSizes.xs.ph,
                    Row(
                      children: [
                        HugeIcon(
                          icon: HugeIconsStrokeRounded.user,
                          color: AppColors.white,
                        ),
                        AppSizes.xxxs.pw,
                        Text("Active Tier", style: AppTextStyles.overLine()),
                      ],
                    ),
                  ],
                ),
              ),
              AppSizes.lg.ph,
              // Yearly Card
              Container(
                padding: const EdgeInsets.all(AppSizes.xs),
                decoration: BoxDecoration(
                  color: AppColors.bgBlue,
                  border: Border.all(
                    color: AppColors.skyBlue.withValues(alpha: 0.8),
                  ),
                  borderRadius: BorderRadius.circular(AppSizes.xxxs),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppStrings.yearly, style: AppTextStyles.headline4()),
                    Text(
                      AppStrings.billedEveryYear,
                      style: AppTextStyles.overLine(
                        color: AppColors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    AppSizes.xs.ph,
                    Text("₹$yearlyPrice", style: AppTextStyles.headline1()),
                    Text(
                      "₹$yearlyMoPrice/mo",
                      style: AppTextStyles.overLine(
                        color: AppColors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    AppSizes.xs.ph,
                    Row(
                      children: [
                        HugeIcon(
                          icon: HugeIconsStrokeRounded.user,
                          color: AppColors.white,
                        ),
                        AppSizes.xxxs.pw,
                        Text("Active Tier", style: AppTextStyles.overLine()),
                      ],
                    ),
                  ],
                ),
              ),
              AppSizes.lg.ph,
              // Lifetime Card
              Container(
                padding: const EdgeInsets.all(AppSizes.xs),
                decoration: BoxDecoration(
                  color: AppColors.bgBlue,
                  border: Border.all(
                    color: AppColors.skyBlue.withValues(alpha: 0.5),
                  ),
                  borderRadius: BorderRadius.circular(AppSizes.xxxs),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppStrings.lifetime, style: AppTextStyles.headline4()),
                    Text(
                      AppStrings.oneTimePayment,
                      style: AppTextStyles.overLine(
                        color: AppColors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    AppSizes.xs.ph,
                    Text("₹$lifetimePrice", style: AppTextStyles.headline1()),
                    AppSizes.xs.ph,
                    Row(
                      children: [
                        HugeIcon(
                          icon: HugeIconsStrokeRounded.user,
                          color: AppColors.white,
                        ),
                        AppSizes.xxxs.pw,
                        Text("Active Tier", style: AppTextStyles.overLine()),
                      ],
                    ),
                  ],
                ),
              ),
              AppSizes.lg.ph,
            ],
          ),
        ),
      ),
    );
  }
}
