import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:larnity/src/core/constants/app_size.dart';
import 'package:larnity/src/core/constants/app_strings.dart';
import 'package:larnity/src/core/extensions/extensions.dart';
import 'package:larnity/src/core/theme/app_colors.dart';
import 'package:larnity/src/core/theme/theme.dart';
import 'package:larnity/src/core/ui/widgets/app_button.dart';
import 'package:larnity/src/core/ui/widgets/app_dropdown.dart';
import 'package:larnity/src/core/utils/show_snackbar.dart';
import 'package:larnity/src/features/group/data/models/group_model.dart';
import 'package:larnity/src/features/group/presentation/provider/group_provider.dart';
import 'package:larnity/src/features/group/presentation/provider/promotion_provider.dart';

class OfferSettingsScreen extends ConsumerStatefulWidget {
  const OfferSettingsScreen({super.key});

  @override
  ConsumerState<OfferSettingsScreen> createState() =>
      _OfferSettingsScreenState();
}

class _OfferSettingsScreenState extends ConsumerState<OfferSettingsScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _daysController;
  late final TextEditingController _hoursController;
  late final TextEditingController _minutesController;

  String? _selectedPromoCode;
  bool _showRemaining = true;
  bool _isOfferActive = false;
  bool _isLoading = false;
  String? _initializedGroupId;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _daysController = TextEditingController(text: '0');
    _hoursController = TextEditingController(text: '0');
    _minutesController = TextEditingController(text: '0');
  }

  void _syncWithGroup(GroupModel? group) {
    if (group == null || group.id == _initializedGroupId) return;
    _initializedGroupId = group.id;

    final offer = group.landingSettings?['activeOffer'] as Map<String, dynamic>?;
    if (offer != null) {
      _titleController.text = offer['title']?.toString() ?? '';
      _selectedPromoCode = offer['promoCode']?.toString();
      _daysController.text = (offer['days'] ?? 0).toString();
      _hoursController.text = (offer['hours'] ?? 0).toString();
      _minutesController.text = (offer['minutes'] ?? 0).toString();
      _showRemaining = offer['showRemaining'] as bool? ?? true;
      _isOfferActive = offer['isActive'] as bool? ?? false;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _daysController.dispose();
    _hoursController.dispose();
    _minutesController.dispose();
    super.dispose();
  }

  Future<void> _saveOffer(GroupModel currentGroup) async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      showErrorToast(content: "Please enter an offer title");
      return;
    }

    final days = int.tryParse(_daysController.text.trim()) ?? 0;
    final hours = int.tryParse(_hoursController.text.trim()) ?? 0;
    final minutes = int.tryParse(_minutesController.text.trim()) ?? 0;

    final expiresAt = DateTime.now()
        .add(Duration(days: days, hours: hours, minutes: minutes))
        .toIso8601String();

    setState(() => _isLoading = true);

    final currentSettings =
        Map<String, dynamic>.from(currentGroup.landingSettings ?? {});
    currentSettings['activeOffer'] = {
      'title': title,
      'promoCode': _selectedPromoCode ?? '',
      'days': days,
      'hours': hours,
      'minutes': minutes,
      'expiresAt': expiresAt,
      'showRemaining': _showRemaining,
      'isActive': _isOfferActive,
      'updatedAt': DateTime.now().toIso8601String(),
    };

    final updatedGroup = currentGroup.copyWith(
      landingSettings: currentSettings,
    );

    await ref.read(groupProvider.notifier).updateGroup(
          group: updatedGroup,
          successCallBack: () {
            if (mounted) {
              setState(() => _isLoading = false);
              showSuccessToast(content: "Offer settings saved successfully");
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
    final isOwnerOrAdmin = ref.watch(isGroupAdminOrOwnerProvider);

    if (group == null) {
      return Scaffold(
        backgroundColor: AppColors.darkBg,
        appBar: AppBar(
          backgroundColor: AppColors.darkBg,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: const Center(
          child: Text(
            "No group selected",
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    if (!isOwnerOrAdmin) {
      return Scaffold(
        backgroundColor: AppColors.darkBg,
        appBar: AppBar(
          backgroundColor: AppColors.darkBg,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text("Offer Settings", style: TextStyle(color: Colors.white)),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock_outline, size: 64, color: AppColors.primaryOrange),
                AppSizes.sm.ph,
                Text(
                  "Access Restricted",
                  style: AppTextStyles.headline2(color: AppColors.white),
                ),
                AppSizes.xs.ph,
                Text(
                  "Only group owners and admins can configure offers.",
                  style: AppTextStyles.bodyText1(color: AppColors.skyBlue),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    _syncWithGroup(group);

    final offer = group.landingSettings?['activeOffer'] as Map<String, dynamic>?;
    final bool isExpired;
    if (offer != null && offer['expiresAt'] != null) {
      final exp = DateTime.tryParse(offer['expiresAt'] as String);
      isExpired = exp != null && exp.isBefore(DateTime.now());
    } else {
      isExpired = false;
    }

    final promoState = ref.watch(promotionProvider);
    final promotions = promoState.promotions ?? [];

    final promoDropdownItems = promotions.map((p) {
      return AppDropdownItem(
        value: p.promoCodeld,
        label: "${p.promoCodeld} (${p.title})",
      );
    }).toList();

    if (promoDropdownItems.isEmpty) {
      promoDropdownItems.add(
        const AppDropdownItem(value: "", label: "No Promo Codes Available"),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: AppBar(
        backgroundColor: AppColors.darkBg,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "Offers",
          style: AppTextStyles.headline3(color: AppColors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.xs),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSizes.xs.ph,
              if (isExpired && _isOfferActive)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSizes.xs),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.red),
                    borderRadius: BorderRadius.circular(AppSizes.xxxs),
                    color: AppColors.redContainer,
                  ),
                  child: Text(
                    "The previous limited-time offer has expired",
                    style: AppTextStyles.overLine(color: AppColors.red),
                  ),
                )
              else if (_isOfferActive)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSizes.xs),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.lightGreen),
                    borderRadius: BorderRadius.circular(AppSizes.xxxs),
                    color: AppColors.lightGreen.withValues(alpha: 0.1),
                  ),
                  child: Text(
                    "Limited-time offer is currently ACTIVE",
                    style: AppTextStyles.overLine(color: AppColors.lightGreen),
                  ),
                ),
              AppSizes.md.ph,
              Text(
                AppStrings.limiteTimeOffer,
                style: AppTextStyles.headline1(color: AppColors.white),
              ),
              AppSizes.xs.ph,
              Text(AppStrings.offerTitle, style: AppTextStyles.overLine()),
              AppSizes.xxxs.ph,
              TextFormField(
                controller: _titleController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.darkBgContainer,
                  hintText: "e.g. 50% Off Early Bird Special",
                  hintStyle: AppTextStyles.button(color: AppColors.grey600),
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
                AppStrings.selectOfferPromoCode,
                style: AppTextStyles.overLine(),
              ),
              AppSizes.xxxs.ph,
              AppDropdown(
                button: Container(
                  padding: const EdgeInsets.all(AppSizes.xs),
                  decoration: BoxDecoration(
                    color: AppColors.bgBlue,
                    border: Border.all(
                      color: AppColors.skyBlue.withValues(alpha: 0.5),
                    ),
                    borderRadius: BorderRadius.circular(AppSizes.xxxs),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _selectedPromoCode != null && _selectedPromoCode!.isNotEmpty
                              ? _selectedPromoCode!
                              : (promotions.isNotEmpty
                                  ? 'Select Promo Code'
                                  : 'No Promo Codes Created'),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      const Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
                items: promoDropdownItems,
                onItemSelected: (val) {
                  if (val.isNotEmpty) {
                    setState(() {
                      _selectedPromoCode = val;
                    });
                  }
                },
              ),
              AppSizes.xs.ph,
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(AppStrings.days, style: AppTextStyles.overLine()),
                        AppSizes.xxxs.ph,
                        TextFormField(
                          controller: _daysController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: AppColors.darkBgContainer,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppSizes.xxxs,
                              ),
                              borderSide: BorderSide(
                                color: AppColors.skyBlue.withValues(alpha: 0.5),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppSizes.xxxs,
                              ),
                              borderSide:
                                  const BorderSide(color: AppColors.skyBlue),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  AppSizes.xxxs.pw,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(AppStrings.hours, style: AppTextStyles.overLine()),
                        AppSizes.xxxs.ph,
                        TextFormField(
                          controller: _hoursController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: AppColors.darkBgContainer,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppSizes.xxxs,
                              ),
                              borderSide: BorderSide(
                                color: AppColors.skyBlue.withValues(alpha: 0.5),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppSizes.xxxs,
                              ),
                              borderSide:
                                  const BorderSide(color: AppColors.skyBlue),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  AppSizes.xxxs.pw,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.minutes,
                          style: AppTextStyles.overLine(),
                        ),
                        AppSizes.xxxs.ph,
                        TextFormField(
                          controller: _minutesController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: AppColors.darkBgContainer,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppSizes.xxxs,
                              ),
                              borderSide: BorderSide(
                                color: AppColors.skyBlue.withValues(alpha: 0.5),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppSizes.xxxs,
                              ),
                              borderSide:
                                  const BorderSide(color: AppColors.skyBlue),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              AppSizes.xs.ph,
              SwitchListTile(
                value: _showRemaining,
                onChanged: (val) => setState(() => _showRemaining = val),
                title: Text(
                  AppStrings.remainingPromoCode,
                  style: AppTextStyles.button(),
                ),
                activeThumbColor: AppColors.primaryOrange,
              ),
              AppSizes.xs.ph,
              SwitchListTile(
                value: _isOfferActive,
                onChanged: (val) => setState(() => _isOfferActive = val),
                title: Text(AppStrings.onOff, style: AppTextStyles.button()),
                activeThumbColor: AppColors.primaryOrange,
              ),
              AppSizes.xs.ph,
              AppButton(
                isExpanded: false,
                isLoading: _isLoading,
                onPressed: _isLoading ? () {} : () => _saveOffer(group),
                label: AppStrings.saveOffer,
                labelStyle: AppTextStyles.bodyText2(color: AppColors.black),
                bgColor: AppColors.white,
                radius: AppSizes.xxxs,
              ),
              AppSizes.xs.ph,
            ],
          ),
        ),
      ),
    );
  }
}

