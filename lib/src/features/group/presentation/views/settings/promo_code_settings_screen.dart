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
import 'package:larnity/src/core/utils/async_states.dart';
import 'package:larnity/src/core/utils/show_snackbar.dart';
import 'package:larnity/src/features/group/presentation/provider/group_provider.dart';
import 'package:larnity/src/features/group/presentation/provider/promotion_provider.dart';
import 'package:larnity/src/features/group/presentation/widgets/settings/create_promo_code.dart';

class PromoCodeSettingsScreen extends ConsumerStatefulWidget {
  const PromoCodeSettingsScreen({super.key});

  @override
  ConsumerState<PromoCodeSettingsScreen> createState() =>
      _PromoCodeSettingsScreenState();
}

class _PromoCodeSettingsScreenState
    extends ConsumerState<PromoCodeSettingsScreen> {
  String? _initializedGroupId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchPromotions();
  }

  void _fetchPromotions() {
    final groupId = ref.read(groupProvider).group?.id;
    if (groupId != null && groupId != _initializedGroupId) {
      _initializedGroupId = groupId;
      Future.microtask(() {
        ref.read(promotionProvider.notifier).getPromotionsByGroup(groupld: groupId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final group = ref.watch(groupProvider).group;
    final isOwnerOrAdmin = ref.watch(isGroupAdminOrOwnerProvider);

    if (group == null || group.id == null) {
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
          child: Text("No group selected", style: TextStyle(color: Colors.white)),
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
          title: const Text("Promo Codes", style: TextStyle(color: Colors.white)),
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
                  "Only group owners and admins can manage promo codes.",
                  style: AppTextStyles.bodyText1(color: AppColors.skyBlue),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    final promotionState = ref.watch(promotionProvider);
    final promotions = (promotionState.promotions ?? [])
        .where((p) => p.groupld == group.id)
        .toList();
    final isLoading = promotionState.state == AsyncState.loading && promotions.isEmpty;

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: AppBar(
        backgroundColor: AppColors.darkBg,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "Promo Codes",
          style: AppTextStyles.headline3(color: AppColors.white),
        ),
      ),
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
                      builder: (context) => AlertDialog(
                        backgroundColor: AppColors.darkBgContainer,
                        content: CreatePromoCode(groupId: group.id!),
                      ),
                    );
                  },
                  prefix: const HugeIcon(
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
              child: Builder(
                builder: (context) {
                  if (isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (promotions.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const HugeIcon(
                            icon: HugeIconsStrokeRounded.ticket03,
                            color: Colors.grey,
                            size: 48,
                          ),
                          AppSizes.xs.ph,
                          Text(
                            AppStrings.noPromoCode,
                            style: AppTextStyles.bodyText1(color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: promotions.length,
                    separatorBuilder: (_, _) => AppSizes.xs.ph,
                    itemBuilder: (context, index) {
                      final promo = promotions[index];
                      return Container(
                        padding: const EdgeInsets.all(AppSizes.xs),
                        decoration: BoxDecoration(
                          color: AppColors.bgBlue,
                          border: Border.all(
                            color: AppColors.skyBlue.withValues(alpha: 0.3),
                          ),
                          borderRadius: BorderRadius.circular(AppSizes.xxxs),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(AppSizes.xs),
                              decoration: BoxDecoration(
                                color: AppColors.primaryOrange.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(AppSizes.xxxs),
                              ),
                              child: const HugeIcon(
                                icon: HugeIconsStrokeRounded.ticket03,
                                color: AppColors.primaryOrange,
                              ),
                            ),
                            AppSizes.xs.pw,
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        promo.promoCodeld,
                                        style: AppTextStyles.headline4(
                                          color: AppColors.white,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.copy,
                                          size: 16,
                                          color: Colors.grey,
                                        ),
                                        onPressed: () {
                                          Clipboard.setData(
                                            ClipboardData(text: promo.promoCodeld),
                                          );
                                          showInfoToast(
                                            content: 'Code copied to clipboard!',
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                  Text(
                                    promo.title,
                                    style: AppTextStyles.caption(
                                      color: AppColors.skyBlue,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSizes.xs,
                                vertical: AppSizes.xxs,
                              ),
                              decoration: BoxDecoration(
                                color: promo.isActive
                                    ? Colors.green.withValues(alpha: 0.2)
                                    : Colors.red.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(AppSizes.xxxs),
                              ),
                              child: Text(
                                promo.isActive ? "ACTIVE" : "INACTIVE",
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: promo.isActive ? Colors.green : Colors.red,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
