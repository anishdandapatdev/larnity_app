import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import 'package:larnity/src/core/constants/app_size.dart';
import 'package:larnity/src/core/extensions/extensions.dart';
import 'package:larnity/src/core/service/supabase/src/supabase_storage_service.dart';
import 'package:larnity/src/core/theme/app_colors.dart';
import 'package:larnity/src/core/theme/theme.dart';
import 'package:larnity/src/core/ui/widgets/app_button.dart';
import 'package:go_router/go_router.dart';
import 'package:larnity/src/core/router/router.dart';
import 'package:larnity/src/features/group/data/models/group_model.dart';
import 'package:larnity/src/features/group/presentation/provider/group_provider.dart';
import 'package:larnity/src/features/auth/presentation/provider/auth_provider.dart';

class GroupDetailsScreen extends ConsumerWidget {
  final GroupModel? group;
  const GroupDetailsScreen({super.key, this.group});

  String? _resolveImageUrl(WidgetRef ref, String? rawUrl) {
    if (rawUrl == null || rawUrl.trim().isEmpty) return null;
    final trimmed = rawUrl.trim();
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    try {
      final storage = ref.read(storageServiceProvider);
      return storage.getPublicUrl(
        bucket: StorageBucket.groupImages,
        path: trimmed,
      );
    } catch (_) {
      return null;
    }
  }

  Widget _buildPlaceholderBanner(String name) {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryOrange.withValues(alpha: 0.35),
            AppColors.darkBgContainer,
            AppColors.black,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(
              Icons.group_outlined,
              size: 140,
              color: AppColors.white.withValues(alpha: 0.05),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.groups_rounded,
                size: 52,
                color: AppColors.white.withValues(alpha: 0.7),
              ),
              AppSizes.xxs.ph,
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                child: Text(
                  name,
                  style: AppTextStyles.bodyText1(
                    color: AppColors.white.withValues(alpha: 0.8),
                  ).copyWith(fontWeight: AppFontWeights.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGroupAvatar(String? iconUrl, String groupName) {
    return Container(
      width: 68,
      height: 68,
      decoration: BoxDecoration(
        color: AppColors.darkBgContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryOrange, width: 2.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryOrange.withValues(alpha: 0.3),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: iconUrl != null
          ? Image.network(
              iconUrl,
              width: 68,
              height: 68,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  _buildAvatarFallback(groupName),
            )
          : _buildAvatarFallback(groupName),
    );
  }

  Widget _buildAvatarFallback(String groupName) {
    final initial = groupName.trim().isNotEmpty
        ? groupName.trim().characters.first.toUpperCase()
        : 'G';
    return Container(
      color: AppColors.primaryOrange.withValues(alpha: 0.2),
      child: Center(
        child: Text(
          initial,
          style: AppTextStyles.headline1(color: AppColors.primaryOrange).copyWith(
            fontWeight: AppFontWeights.extraBold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupState = ref.watch(groupProvider);
    final selectedGroup = group ?? groupState.group;
    final currentUserId = ref.watch(authProvider).user?.id;
    final isMemberOrOwner = selectedGroup != null && (
        (selectedGroup.userId != null && selectedGroup.userId == currentUserId) ||
        (groupState.groups?.any((g) => g.id == selectedGroup.id) ?? false)
    );

    if (selectedGroup == null) {
      if (groupState.isLoading) {
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      } else if (groupState.isFailure) {
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Failed to load group details'),
                AppSizes.xs.ph,
                AppButton(
                  onPressed: () {
                    ref.read(groupProvider.notifier).refreshGroupsForCurrentUser();
                  },
                  label: "Retry",
                  labelStyle: AppTextStyles.bodyText2(),
                  bgColor: AppColors.white,
                  radius: AppSizes.xxxs,
                ),
              ],
            ),
          ),
        );
      } else {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.goNamed(Routes.explore);
                }
              },
            ),
          ),
          body: const Center(child: Text('No group selected')),
        );
      }
    }

    final bannerUrl = _resolveImageUrl(ref, selectedGroup.thumbnail) ??
        _resolveImageUrl(ref, selectedGroup.icon);
    final iconUrl = _resolveImageUrl(ref, selectedGroup.icon) ??
        _resolveImageUrl(ref, selectedGroup.thumbnail);

    final isFree = selectedGroup.monthlyPrice == null &&
        selectedGroup.yearlyPrice == null &&
        selectedGroup.lifetimePrice == null;

    final priceLabel = isFree
        ? "Free"
        : (selectedGroup.monthlyPrice != null
            ? "₹${selectedGroup.monthlyPrice}/mo"
            : (selectedGroup.lifetimePrice != null
                ? "₹${selectedGroup.lifetimePrice} lifetime"
                : "₹${selectedGroup.yearlyPrice}/yr"));

    final canEnterDirectly = isFree || isMemberOrOwner;
    final groupSlug = selectedGroup.slug ?? '';
    final groupUrl = groupSlug.isNotEmpty
        ? "https://www.larnity.com/group/$groupSlug"
        : "https://www.larnity.com";

    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        title: Text(
          selectedGroup.name,
          style: AppTextStyles.subtitle1(color: AppColors.white).copyWith(
            fontWeight: AppFontWeights.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.goNamed(Routes.explore);
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: AppColors.white),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: groupUrl));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Community link copied to clipboard!')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner & Overlapping Avatar Section
            Stack(
              clipBehavior: Clip.none,
              children: [
                // Banner
                SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: bannerUrl != null
                      ? Image.network(
                          bannerUrl,
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return Container(
                              color: AppColors.darkBgContainer,
                              child: const Center(
                                child: SizedBox(
                                  width: 28,
                                  height: 28,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) =>
                              _buildPlaceholderBanner(selectedGroup.name),
                        )
                      : _buildPlaceholderBanner(selectedGroup.name),
                ),
                // Gradient overlay at the bottom of the banner
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: 60,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          AppColors.black.withValues(alpha: 0.8),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
                // Floating Avatar
                Positioned(
                  left: AppSizes.sm,
                  bottom: -34,
                  child: _buildGroupAvatar(iconUrl, selectedGroup.name),
                ),
              ],
            ),

            AppSizes.xlg.ph,

            // Group Info & Badges
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Group Name
                  Text(
                    selectedGroup.name,
                    style: AppTextStyles.headline1(color: AppColors.white).copyWith(
                      fontSize: 24,
                      fontWeight: AppFontWeights.extraBold,
                    ),
                  ),

                  AppSizes.xs.ph,

                  // Badges Row
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      // Privacy Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.darkBgContainer,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.borderBrown.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            HugeIcon(
                              icon: selectedGroup.isPublic
                                  ? HugeIconsStrokeRounded.globe02
                                  : HugeIconsStrokeRounded.squareLock01,
                              color: AppColors.primaryOrange,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              selectedGroup.isPublic ? "Public" : "Private",
                              style: AppTextStyles.overLine(color: AppColors.creamWhite),
                            ),
                          ],
                        ),
                      ),

                      // Members Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.darkBgContainer,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.borderBrown.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const HugeIcon(
                              icon: HugeIconsStrokeRounded.userMultiple02,
                              color: AppColors.primaryOrange,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "${selectedGroup.memberCount ?? 0} Members",
                              style: AppTextStyles.overLine(color: AppColors.creamWhite),
                            ),
                          ],
                        ),
                      ),

                      // Price Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: isFree
                              ? AppColors.primaryOrange.withValues(alpha: 0.15)
                              : AppColors.darkBgContainer,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.primaryOrange.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const HugeIcon(
                              icon: HugeIconsStrokeRounded.tag01,
                              color: AppColors.primaryOrange,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              priceLabel,
                              style: AppTextStyles.overLine(
                                color: AppColors.primaryOrange,
                              ).copyWith(fontWeight: AppFontWeights.bold),
                            ),
                          ],
                        ),
                      ),

                      // Category Badge
                      if (selectedGroup.category != null &&
                          selectedGroup.category!.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.darkBgContainer,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.borderBrown.withValues(alpha: 0.5),
                            ),
                          ),
                          child: Text(
                            selectedGroup.category!,
                            style: AppTextStyles.overLine(color: AppColors.creamWhite),
                          ),
                        ),
                    ],
                  ),

                  AppSizes.md.ph,

                  // Action Button
                  if (canEnterDirectly)
                    AppButton(
                      onPressed: () {
                        ref.read(groupProvider.notifier).setSelectedGroup(selectedGroup);
                        context.pushNamed(Routes.group);
                      },
                      label: "Enter Community",
                      labelStyle: AppTextStyles.bodyText2(color: AppColors.black).copyWith(
                        fontWeight: AppFontWeights.bold,
                      ),
                      bgColor: AppColors.primaryOrange,
                      radius: AppSizes.xxs,
                    )
                  else
                    AppButton(
                      onPressed: () {
                        _showPlanSelectionSheet(context);
                      },
                      label: "Join Community • $priceLabel",
                      labelStyle: AppTextStyles.bodyText2(color: AppColors.black).copyWith(
                        fontWeight: AppFontWeights.bold,
                      ),
                      bgColor: AppColors.primaryOrange,
                      radius: AppSizes.xxs,
                    ),

                  AppSizes.md.ph,

                  // About Section Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSizes.sm),
                    decoration: BoxDecoration(
                      color: AppColors.darkBgContainer,
                      borderRadius: BorderRadius.circular(AppSizes.xs),
                      border: Border.all(
                        color: AppColors.borderBrown.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "About this Community",
                          style: AppTextStyles.headline4(color: AppColors.white).copyWith(
                            fontWeight: AppFontWeights.bold,
                          ),
                        ),
                        AppSizes.xs.ph,
                        Text(
                          (selectedGroup.description != null &&
                                  selectedGroup.description!.trim().isNotEmpty)
                              ? selectedGroup.description!
                              : "Welcome to ${selectedGroup.name}! Connect, learn, and grow with fellow members in this community.",
                          style: AppTextStyles.bodyText2(
                            color: AppColors.creamWhite.withValues(alpha: 0.85),
                          ).copyWith(height: 1.5),
                        ),
                      ],
                    ),
                  ),

                  AppSizes.md.ph,

                  // What's Inside / Rooms Section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSizes.sm),
                    decoration: BoxDecoration(
                      color: AppColors.darkBgContainer,
                      borderRadius: BorderRadius.circular(AppSizes.xs),
                      border: Border.all(
                        color: AppColors.borderBrown.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "What's Inside",
                          style: AppTextStyles.headline4(color: AppColors.white).copyWith(
                            fontWeight: AppFontWeights.bold,
                          ),
                        ),
                        AppSizes.xs.ph,
                        Text(
                          "Key rooms and activities available in this community:",
                          style: AppTextStyles.overLine(
                            color: AppColors.creamWhite.withValues(alpha: 0.7),
                          ),
                        ),
                        AppSizes.sm.ph,
                        _buildFeatureTile(
                          icon: HugeIconsStrokeRounded.home03,
                          title: "Discussion Room",
                          subtitle: "Engage in community chats, posts, and announcements",
                        ),
                        const Divider(color: AppColors.borderBrown, height: 16),
                        _buildFeatureTile(
                          icon: HugeIconsStrokeRounded.geometricShapes01,
                          title: "Class Room",
                          subtitle: "Access structured courses, videos, and study guides",
                        ),
                        const Divider(color: AppColors.borderBrown, height: 16),
                        _buildFeatureTile(
                          icon: HugeIconsStrokeRounded.computerVideo,
                          title: "Live Class",
                          subtitle: "Participate in real-time interactive workshops",
                        ),
                        const Divider(color: AppColors.borderBrown, height: 16),
                        _buildFeatureTile(
                          icon: HugeIconsStrokeRounded.sourceCodeSquare,
                          title: "Doubt Room",
                          subtitle: "Ask questions, get help, and solve issues together",
                        ),
                        const Divider(color: AppColors.borderBrown, height: 16),
                        _buildFeatureTile(
                          icon: HugeIconsStrokeRounded.adventure,
                          title: "Challenges Room",
                          subtitle: "Participate in skill challenges and earn rewards",
                        ),
                      ],
                    ),
                  ),

                  AppSizes.md.ph,

                  // Share Link Bar
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.sm,
                      vertical: AppSizes.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.darkBgContainer,
                      borderRadius: BorderRadius.circular(AppSizes.xs),
                      border: Border.all(
                        color: AppColors.borderBrown.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            groupUrl,
                            style: AppTextStyles.overLine(
                              color: AppColors.creamWhite.withValues(alpha: 0.6),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        AppSizes.xs.pw,
                        InkWell(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: groupUrl));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Community link copied to clipboard!'),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(AppSizes.xxxs),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.black,
                              borderRadius: BorderRadius.circular(AppSizes.xxxs),
                              border: Border.all(color: AppColors.borderBrown),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.copy, size: 14, color: AppColors.white),
                                const SizedBox(width: 4),
                                Text(
                                  "Copy",
                                  style: AppTextStyles.overLine(color: AppColors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  AppSizes.xxxlg.ph,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureTile({
    required dynamic icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.primaryOrange.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: HugeIcon(
              icon: icon,
              color: AppColors.primaryOrange,
              size: 20,
            ),
          ),
        ),
        AppSizes.xs.pw,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.subtitle2(color: AppColors.white).copyWith(
                  fontWeight: AppFontWeights.bold,
                ),
              ),
              Text(
                subtitle,
                style: AppTextStyles.overLine(
                  color: AppColors.creamWhite.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

void _showPlanSelectionSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.darkBgContainer,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.xs)),
    ),
    builder: (ctx) {
      return Padding(
        padding: EdgeInsets.fromLTRB(AppSizes.xs, AppSizes.sm, AppSizes.xs, AppSizes.sm),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Choose a plan',
                  style: AppTextStyles.headline4(),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  color: AppColors.creamWhite,
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
              ],
            ),
            AppSizes.xs.ph,
            Text(
              'Select a plan to join this community',
              style: AppTextStyles.overLine(),
            ),
            AppSizes.sm.ph,
            InkWell(
              onTap: () {
                Navigator.of(ctx).pop();
                _showPaymentSheet(context, planName: 'Lifetime', amountINR: 999);
              },
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(AppSizes.xs),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppSizes.xxxs),
                  border: Border.all(color: AppColors.borderBrown),
                  color: AppColors.black,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Lifetime', style: AppTextStyles.headline5()),
                    AppSizes.xxxs.ph,
                    Text('₹999', style: AppTextStyles.headline4()),
                    AppSizes.xxxs.ph,
                    Text(
                      'One-time payment, access forever',
                      style: AppTextStyles.overLine(),
                    ),
                  ],
                ),
              ),
            ),
            AppSizes.sm.ph,
          ],
        ),
      );
    },
  );
}

void _showPaymentSheet(BuildContext context, {required String planName, required int amountINR}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.darkBgContainer,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.xs)),
    ),
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setState) {
          String method = 'Paymintro';
          return Padding(
            padding: EdgeInsets.fromLTRB(AppSizes.xs, AppSizes.sm, AppSizes.xs, AppSizes.sm),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Payment', style: AppTextStyles.headline4()),
                    IconButton(
                      icon: const Icon(Icons.close),
                      color: AppColors.creamWhite,
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
                AppSizes.xs.ph,
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(AppSizes.xs),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppSizes.xxxs),
                    border: Border.all(color: AppColors.borderBrown),
                    color: AppColors.black,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('$planName Plan', style: AppTextStyles.headline5()),
                      AppSizes.xxxs.ph,
                      Text('₹$amountINR for $planName', style: AppTextStyles.bodyText2()),
                    ],
                  ),
                ),
                AppSizes.sm.ph,
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Enter promo code',
                          filled: true,
                          fillColor: AppColors.black,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppSizes.xxxs),
                            borderSide: BorderSide(color: AppColors.borderBrown),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppSizes.xxxs),
                            borderSide: BorderSide(color: AppColors.borderBrown),
                          ),
                        ),
                        style: AppTextStyles.bodyText2(),
                      ),
                    ),
                    AppSizes.xxxs.pw,
                    AppButton(
                      isExpanded: false,
                      height: 48,
                      onPressed: () {},
                      label: 'Apply',
                      labelStyle: AppTextStyles.bodyText2(color: AppColors.white),
                      bgColor: AppColors.black,
                      borderColor: AppColors.white,
                      radius: AppSizes.xxxs,
                    ),
                  ],
                ),
                AppSizes.sm.ph,
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        isExpanded: true,
                        onPressed: () {
                          setState(() => method = 'Paymintro');
                        },
                        label: 'Paymintro',
                        labelStyle: AppTextStyles.bodyText2(color: AppColors.white),
                        bgColor: method == 'Paymintro' ? AppColors.purple : AppColors.black,
                        borderColor: AppColors.white,
                        radius: AppSizes.xxxs,
                      ),
                    ),
                    AppSizes.xxxs.pw,
                    Expanded(
                      child: AppButton(
                        isExpanded: true,
                        onPressed: () {
                          setState(() => method = 'Cashfree');
                        },
                        label: 'Cashfree',
                        labelStyle: AppTextStyles.bodyText2(color: AppColors.white),
                        bgColor: method == 'Cashfree' ? AppColors.purple : AppColors.black,
                        borderColor: AppColors.white,
                        radius: AppSizes.xxxs,
                      ),
                    ),
                  ],
                ),
                AppSizes.sm.ph,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total Amount:', style: AppTextStyles.bodyText2()),
                    Text('₹${amountINR.toStringAsFixed(0)}', style: AppTextStyles.headline5()),
                  ],
                ),
                AppSizes.xs.ph,
                AppButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Redirecting to $method secure payment...')),
                    );
                  },
                  label: 'Pay Securely with $method',
                  labelStyle: AppTextStyles.bodyText2(color: AppColors.white),
                  bgColor: AppColors.purple,
                  radius: AppSizes.xxxs,
                ),
                AppSizes.xxxs.ph,
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: Text('Back', style: AppTextStyles.bodyText2()),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}