import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:larnity/src/core/constants/app_size.dart';
import 'package:larnity/src/core/constants/app_strings.dart';
import 'package:larnity/src/core/extensions/extensions.dart';
import 'package:larnity/src/core/theme/app_colors.dart';
import 'package:larnity/src/core/theme/theme.dart';
import 'package:larnity/src/core/ui/widgets/app_button.dart';
import 'package:larnity/src/core/ui/widgets/app_dropdown.dart';
import 'package:larnity/src/core/utils/show_snackbar.dart';
import 'package:larnity/src/features/group/data/models/promotion_model.dart';
import 'package:larnity/src/features/group/presentation/provider/promotion_provider.dart';

class CreatePromoCode extends ConsumerStatefulWidget {
  final String groupId;
  const CreatePromoCode({super.key, required this.groupId});

  @override
  ConsumerState<CreatePromoCode> createState() => _CreatePromoCodeState();
}

class _CreatePromoCodeState extends ConsumerState<CreatePromoCode> {
  late final TextEditingController _codeController;
  late final TextEditingController _discountController;
  late final TextEditingController _maxUsesController;
  String _selectedPlan = 'MONTHLY';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController(text: _generateRandomCode());
    _discountController = TextEditingController(text: '10');
    _maxUsesController = TextEditingController(text: '50');
  }

  String _generateRandomCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(8, (_) => chars.codeUnitAt(random.nextInt(chars.length))),
    );
  }

  @override
  void dispose() {
    _codeController.dispose();
    _discountController.dispose();
    _maxUsesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final code = _codeController.text.trim().toUpperCase();
    if (code.isEmpty) {
      showErrorToast(content: 'Please enter or generate a promo code');
      return;
    }

    final discount = double.tryParse(_discountController.text.trim()) ?? 10;

    setState(() => _isLoading = true);

    final promotion = PromotionModel(
      createdAt: DateTime.now(),
      title: 'Promo $code ($discount% off)',
      startAt: DateTime.now(),
      endAt: DateTime.now().add(const Duration(days: 30)),
      promoCodeld: code,
      groupld: widget.groupId,
      isShowRemainingUses: true,
      isActive: true,
    );

    ref.read(promotionProvider.notifier).createPromotion(
          promotion: promotion,
          successCallBack: () {
            if (mounted) {
              setState(() => _isLoading = false);
              showInfoToast(content: 'Promo code $code created successfully!');
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
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.close, color: Colors.white),
              ),
            ],
          ),
          Text(AppStrings.createNewPromoCode, style: AppTextStyles.headline4()),
          Text(
            AppStrings.createNewPromoCodeDesc,
            style: AppTextStyles.overLine(color: AppColors.skyBlue),
          ),
          AppSizes.lg.ph,
          Text(AppStrings.promoCode, style: AppTextStyles.overLine()),
          AppSizes.xxxs.ph,
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _codeController,
                  style: const TextStyle(color: Colors.white),
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.darkBgContainer,
                    hintText: AppStrings.promoCodeHint,
                    hintStyle: AppTextStyles.button(color: AppColors.skyBlue),
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
              ),
              AppSizes.xs.pw,
              AppButton(
                isExpanded: false,
                height: 52,
                onPressed: () {
                  setState(() => _codeController.text = _generateRandomCode());
                },
                label: AppStrings.autoGenerate,
                labelStyle: AppTextStyles.button(color: AppColors.white),
                bgColor: Colors.transparent,
                borderColor: AppColors.skyBlue.withValues(alpha: 0.5),
              ),
            ],
          ),
          AppSizes.xs.ph,
          Text(AppStrings.planType, style: AppTextStyles.overLine()),
          AppSizes.xxxs.ph,
          AppDropdown(
            button: Container(
              padding: const EdgeInsets.all(AppSizes.xs),
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.skyBlue.withValues(alpha: 0.5),
                ),
                borderRadius: BorderRadius.circular(AppSizes.xs),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _selectedPlan == 'MONTHLY' ? "Monthly Plan" : "Yearly Plan",
                    style: AppTextStyles.bodyText2(color: AppColors.white),
                  ),
                  const Icon(Icons.keyboard_arrow_down, color: AppColors.white),
                ],
              ),
            ),
            onItemSelected: (val) {
              setState(() => _selectedPlan = val);
            },
            items: const [
              AppDropdownItem(
                value: "MONTHLY",
                label: "Monthly Plan",
              ),
              AppDropdownItem(
                value: "YEARLY",
                label: "Yearly Plan",
              ),
            ],
          ),
          AppSizes.xs.ph,
          Text(AppStrings.discountPercentage, style: AppTextStyles.overLine()),
          AppSizes.xxxs.ph,
          TextFormField(
            controller: _discountController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.darkBgContainer,
              hintText: "10",
              suffixText: "%",
              suffixStyle: const TextStyle(color: Colors.white),
              hintStyle: AppTextStyles.button(color: AppColors.skyBlue),
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
          Text(AppStrings.maxUses, style: AppTextStyles.overLine()),
          AppSizes.xxxs.ph,
          TextFormField(
            controller: _maxUsesController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.darkBgContainer,
              hintText: AppStrings.maxUsesUnlimitedHint,
              hintStyle: AppTextStyles.button(color: AppColors.skyBlue),
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
            onPressed: _isLoading ? () {} : _submit,
            bgColor: AppColors.primaryOrange,
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
                    AppStrings.generatePromoCode,
                    style: AppTextStyles.button(color: AppColors.black),
                  ),
          ),
        ],
      ),
    );
  }
}
