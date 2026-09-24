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
import 'package:url_launcher/url_launcher.dart';

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

    final monthly = selectedGroup.monthlyPrice ?? 0;
    final yearly = selectedGroup.yearlyPrice ?? 0;
    final lifetime = selectedGroup.lifetimePrice ?? 0;

    final isFree = monthly <= 0 && yearly <= 0 && lifetime <= 0;

    final String priceLabel;
    if (isFree) {
      priceLabel = "Free";
    } else if (monthly > 0) {
      priceLabel = "₹$monthly/mo";
    } else if (lifetime > 0) {
      priceLabel = "₹$lifetime lifetime";
    } else if (yearly > 0) {
      priceLabel = "₹$yearly/yr";
    } else {
      priceLabel = "Free";
    }

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
                        _showPlanSelectionSheet(context, selectedGroup);
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

void _showPlanSelectionSheet(BuildContext context, GroupModel group) {
  showModalBottomSheet(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: AppColors.darkBgContainer,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      final monthly = group.monthlyPrice;
      final yearly = group.yearlyPrice;
      final lifetime = group.lifetimePrice;

      final plans = <Map<String, dynamic>>[];
      if (monthly != null && monthly > 0) {
        plans.add({
          'name': 'Monthly Plan',
          'amount': monthly,
          'formattedPrice': '₹$monthly',
          'subtitle': 'Billed every month, cancel anytime',
          'isRecommended': false,
        });
      }
      if (yearly != null && yearly > 0) {
        plans.add({
          'name': 'Yearly Plan',
          'amount': yearly,
          'formattedPrice': '₹$yearly',
          'subtitle': 'Billed annually, save more',
          'isRecommended': false,
        });
      }
      if (lifetime != null && lifetime > 0) {
        plans.add({
          'name': 'Lifetime Access',
          'amount': lifetime,
          'formattedPrice': '₹$lifetime',
          'subtitle': 'One-time payment, access forever',
          'isRecommended': true,
        });
      }

      if (plans.isEmpty) {
        plans.add({
          'name': 'Full Access',
          'amount': 999,
          'formattedPrice': '₹999',
          'subtitle': 'Standard community membership',
          'isRecommended': true,
        });
      }

      return SafeArea(
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.85,
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              AppSizes.sm,
              AppSizes.xs,
              AppSizes.sm,
              AppSizes.md,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: AppSizes.xs),
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Choose a Plan',
                      style: AppTextStyles.headline4(color: AppColors.white).copyWith(
                        fontWeight: AppFontWeights.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.creamWhite),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
                AppSizes.xxs.ph,
                Text(
                  'Select a plan to join ${group.name}',
                  style: AppTextStyles.overLine(
                    color: AppColors.creamWhite.withValues(alpha: 0.7),
                  ),
                ),
                AppSizes.sm.ph,
                ...plans.map((p) {
                  return _buildPlanCard(
                    title: p['name'] as String,
                    price: p['formattedPrice'] as String,
                    subtitle: p['subtitle'] as String,
                    isRecommended: p['isRecommended'] as bool,
                    onTap: () {
                      Navigator.of(ctx).pop();
                      _showPaymentSheet(
                        context,
                        group: group,
                        planName: p['name'] as String,
                        amountINR: p['amount'] as int,
                      );
                    },
                  );
                }),
              ],
            ),
          ),
        ),
      );
    },
  );
}

Widget _buildPlanCard({
  required String title,
  required String price,
  required String subtitle,
  required bool isRecommended,
  required VoidCallback onTap,
}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(AppSizes.xxs),
    child: Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppSizes.xs),
      padding: const EdgeInsets.all(AppSizes.sm),
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(AppSizes.xxs),
        border: Border.all(
          color: isRecommended
              ? AppColors.primaryOrange
              : AppColors.borderBrown.withValues(alpha: 0.6),
          width: isRecommended ? 1.5 : 1.0,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.headline5(color: AppColors.white).copyWith(
                        fontWeight: AppFontWeights.bold,
                      ),
                    ),
                    if (isRecommended) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primaryOrange,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          "RECOMMENDED",
                          style: AppTextStyles.overLine(color: AppColors.black).copyWith(
                            fontWeight: AppFontWeights.bold,
                            fontSize: 9,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                AppSizes.xxs.ph,
                Text(
                  subtitle,
                  style: AppTextStyles.overLine(
                    color: AppColors.creamWhite.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          AppSizes.xs.pw,
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                price,
                style: AppTextStyles.headline4(color: AppColors.primaryOrange).copyWith(
                  fontWeight: AppFontWeights.bold,
                ),
              ),
              AppSizes.xxxs.ph,
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Select",
                    style: AppTextStyles.overLine(color: AppColors.primaryOrange),
                  ),
                  const SizedBox(width: 2),
                  const Icon(Icons.arrow_forward_ios, size: 10, color: AppColors.primaryOrange),
                ],
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

void _showPaymentSheet(
  BuildContext context, {
  required GroupModel group,
  required String planName,
  required int amountINR,
}) {
  showModalBottomSheet(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: AppColors.darkBgContainer,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      final preferred = group.landingSettings?['preferredGateway'] as String?;
      String method = (preferred != null && preferred.isNotEmpty) ? preferred : 'Cashfree';
      final promoController = TextEditingController();

      return StatefulBuilder(
        builder: (ctx, setState) {
          return SafeArea(
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(ctx).size.height * 0.88,
              ),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  AppSizes.sm,
                  AppSizes.xs,
                  AppSizes.sm,
                  AppSizes.md,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 44,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: AppSizes.xs),
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Payment Details',
                          style: AppTextStyles.headline4(color: AppColors.white).copyWith(
                            fontWeight: AppFontWeights.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: AppColors.creamWhite),
                          onPressed: () => Navigator.of(ctx).pop(),
                        ),
                      ],
                    ),
                    AppSizes.xs.ph,
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSizes.sm),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppSizes.xxs),
                        border: Border.all(color: AppColors.borderBrown),
                        color: AppColors.black,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                planName,
                                style: AppTextStyles.headline5(color: AppColors.white).copyWith(
                                  fontWeight: AppFontWeights.bold,
                                ),
                              ),
                              AppSizes.xxxs.ph,
                              Text(
                                'Community Membership',
                                style: AppTextStyles.overLine(
                                  color: AppColors.creamWhite.withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '₹$amountINR',
                            style: AppTextStyles.headline4(color: AppColors.primaryOrange).copyWith(
                              fontWeight: AppFontWeights.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    AppSizes.sm.ph,
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: promoController,
                            decoration: InputDecoration(
                              hintText: 'Enter promo code',
                              hintStyle: AppTextStyles.overLine(
                                color: AppColors.creamWhite.withValues(alpha: 0.5),
                              ),
                              filled: true,
                              fillColor: AppColors.black,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppSizes.xxxs),
                                borderSide: const BorderSide(color: AppColors.borderBrown),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppSizes.xxxs),
                                borderSide: const BorderSide(color: AppColors.borderBrown),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppSizes.xxxs),
                                borderSide: const BorderSide(color: AppColors.primaryOrange),
                              ),
                            ),
                            style: AppTextStyles.bodyText2(color: AppColors.white),
                          ),
                        ),
                        AppSizes.xxs.pw,
                        AppButton(
                          isExpanded: false,
                          height: 48,
                          onPressed: () {
                            if (promoController.text.trim().isNotEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Invalid promo code')),
                              );
                            }
                          },
                          label: 'Apply',
                          labelStyle: AppTextStyles.bodyText2(color: AppColors.white),
                          bgColor: AppColors.black,
                          borderColor: AppColors.white,
                          radius: AppSizes.xxxs,
                        ),
                      ],
                    ),
                    AppSizes.sm.ph,
                    Text(
                      'Payment Method',
                      style: AppTextStyles.subtitle2(color: AppColors.white).copyWith(
                        fontWeight: AppFontWeights.bold,
                      ),
                    ),
                    AppSizes.xs.ph,
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => setState(() => method = 'Paymintro'),
                            borderRadius: BorderRadius.circular(AppSizes.xxs),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: method == 'Paymintro'
                                    ? AppColors.primaryOrange.withValues(alpha: 0.2)
                                    : AppColors.black,
                                borderRadius: BorderRadius.circular(AppSizes.xxs),
                                border: Border.all(
                                  color: method == 'Paymintro'
                                      ? AppColors.primaryOrange
                                      : AppColors.borderBrown,
                                  width: method == 'Paymintro' ? 1.5 : 1.0,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  'Paymintro',
                                  style: AppTextStyles.bodyText2(
                                    color: method == 'Paymintro'
                                        ? AppColors.primaryOrange
                                        : AppColors.white,
                                  ).copyWith(fontWeight: AppFontWeights.bold),
                                ),
                              ),
                            ),
                          ),
                        ),
                        AppSizes.xs.pw,
                        Expanded(
                          child: InkWell(
                            onTap: () => setState(() => method = 'Cashfree'),
                            borderRadius: BorderRadius.circular(AppSizes.xxs),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: method == 'Cashfree'
                                    ? AppColors.primaryOrange.withValues(alpha: 0.2)
                                    : AppColors.black,
                                borderRadius: BorderRadius.circular(AppSizes.xxs),
                                border: Border.all(
                                  color: method == 'Cashfree'
                                      ? AppColors.primaryOrange
                                      : AppColors.borderBrown,
                                  width: method == 'Cashfree' ? 1.5 : 1.0,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  'Cashfree',
                                  style: AppTextStyles.bodyText2(
                                    color: method == 'Cashfree'
                                        ? AppColors.primaryOrange
                                        : AppColors.white,
                                  ).copyWith(fontWeight: AppFontWeights.bold),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    AppSizes.sm.ph,
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.black,
                        borderRadius: BorderRadius.circular(AppSizes.xxs),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Amount:',
                            style: AppTextStyles.bodyText1(color: AppColors.creamWhite),
                          ),
                          Text(
                            '₹${amountINR.toStringAsFixed(0)}',
                            style: AppTextStyles.headline4(color: AppColors.primaryOrange).copyWith(
                              fontWeight: AppFontWeights.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    AppSizes.sm.ph,
                    AppButton(
                      onPressed: () async {
                        String? paymentUrl;
                        final landingSettings = group.landingSettings;

                        if (method == 'Cashfree') {
                          if (landingSettings != null) {
                            final btn = landingSettings['button'];
                            if (btn is Map && btn['url'] != null && btn['url'].toString().trim().isNotEmpty) {
                              paymentUrl = btn['url'].toString().trim();
                            } else if (landingSettings['paymentUrl'] != null && landingSettings['paymentUrl'].toString().trim().isNotEmpty) {
                              paymentUrl = landingSettings['paymentUrl'].toString().trim();
                            }
                          }
                        } else {
                          // Paymintro
                          if (landingSettings != null && landingSettings['paymintroUrl'] != null && landingSettings['paymintroUrl'].toString().trim().isNotEmpty) {
                            paymentUrl = landingSettings['paymintroUrl'].toString().trim();
                          }
                        }

                        // If no specific payment form was configured by the creator, fallback to group page on web
                        if (paymentUrl == null || paymentUrl.isEmpty) {
                          final slug = group.slug ?? group.id;
                          paymentUrl = "https://www.larnity.com/group/$slug";
                        }

                        if (!paymentUrl.startsWith('http://') && !paymentUrl.startsWith('https://')) {
                          paymentUrl = 'https://$paymentUrl';
                        }

                        final uri = Uri.tryParse(paymentUrl);
                        if (uri != null) {
                          Navigator.of(ctx).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Opening $method payment page...'),
                              duration: const Duration(seconds: 2),
                              backgroundColor: AppColors.primaryOrange,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          try {
                            final launched = await launchUrl(
                              uri,
                              mode: LaunchMode.externalApplication,
                            );
                            if (!launched && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Could not open payment link: $paymentUrl'),
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error opening payment page: $e'),
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
                            }
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Invalid payment link configured for this group.'),
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                        }
                      },
                      label: 'Pay Securely with $method',
                      labelStyle: AppTextStyles.bodyText2(color: AppColors.black).copyWith(
                        fontWeight: AppFontWeights.bold,
                      ),
                      bgColor: AppColors.primaryOrange,
                      radius: AppSizes.xxs,
                    ),
                    AppSizes.xxs.ph,
                    Center(
                      child: TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: Text(
                          'Cancel',
                          style: AppTextStyles.bodyText2(color: AppColors.creamWhite),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}