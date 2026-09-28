import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import 'package:larnity/src/core/constants/app_size.dart';
import 'package:larnity/src/core/constants/app_strings.dart';
import 'package:larnity/src/core/extensions/extensions.dart';
import 'package:larnity/src/core/router/router.dart';
import 'package:larnity/src/core/service/supabase/src/supabase_storage_service.dart';
import 'package:larnity/src/core/theme/app_colors.dart';
import 'package:larnity/src/core/theme/theme.dart';
import 'package:larnity/src/core/ui/widgets/app_button.dart';
import 'package:larnity/src/core/ui/widgets/app_dropdown.dart';
import 'package:larnity/src/core/utils/async_states.dart';
import 'package:larnity/src/core/utils/show_snackbar.dart';
import 'package:larnity/src/features/auth/presentation/provider/auth_provider.dart';
import 'package:larnity/src/features/group/data/models/challenge_model.dart';
import 'package:larnity/src/features/group/presentation/provider/challenge_provider.dart';
import 'package:larnity/src/features/group/presentation/provider/group_provider.dart';
import 'package:larnity/src/features/group/presentation/widgets/settings/create_challenge.dart';

class ChallengeRoomScreen extends ConsumerStatefulWidget {
  const ChallengeRoomScreen({super.key});

  @override
  ConsumerState<ChallengeRoomScreen> createState() =>
      _ChallengeRoomScreenState();
}

class _ChallengeRoomScreenState extends ConsumerState<ChallengeRoomScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedStatus = AppStrings.allStatus;
  String _selectedType = AppStrings.allTypes;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _resolveImageUrl(String? img) {
    if (img == null || img.isEmpty) return '';
    if (img.startsWith('http://') || img.startsWith('https://')) return img;
    try {
      final storage = ref.read(storageServiceProvider);
      return storage.getPublicUrl(bucket: StorageBucket.groupImages, path: img);
    } catch (_) {
      return img;
    }
  }

  void _openCreateChallengeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AlertDialog(
        backgroundColor: AppColors.darkBgContainer,
        content: CreateChallenge(),
      ),
    );
  }

  void _showChallengeDetailsSheet(
    BuildContext context,
    ChallengeModel c,
    bool isOwnerOrAdmin,
    String groupId,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (ctx, scrollController) => Container(
          decoration: const BoxDecoration(
            color: AppColors.darkBgContainer,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(AppSizes.sm),
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              AppSizes.xs.ph,
              if (c.image != null && c.image!.isNotEmpty) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    _resolveImageUrl(c.image),
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 140,
                      color: AppColors.darkBg,
                      child: const Center(
                        child: Icon(Icons.emoji_events, color: AppColors.primaryOrange, size: 48),
                      ),
                    ),
                  ),
                ),
                AppSizes.xs.ph,
              ],
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      c.title ?? 'Untitled Challenge',
                      style: AppTextStyles.headline3(color: Colors.white),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: c.isLive
                          ? AppColors.lightGreen.withValues(alpha: 0.2)
                          : AppColors.primaryOrange.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      c.status ?? 'OPEN',
                      style: TextStyle(
                        color: c.isLive ? AppColors.lightGreen : AppColors.primaryOrange,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              AppSizes.xxs.ph,
              Row(
                children: [
                  Chip(
                    label: Text(
                      c.type == 'PAID'
                          ? "Registration: \$${c.price?.toStringAsFixed(2)}"
                          : "FREE Registration",
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    backgroundColor: AppColors.bgBlue,
                  ),
                  AppSizes.xxs.pw,
                  if (c.prize != null && c.prize!.isNotEmpty)
                    Chip(
                      label: Text(
                        "Prize: ${c.prize}",
                        style: const TextStyle(color: AppColors.primaryOrange, fontSize: 12),
                      ),
                      backgroundColor: AppColors.bgBlue,
                    ),
                ],
              ),
              if (c.startDate != null || c.endDate != null) ...[
                AppSizes.xs.ph,
                Row(
                  children: [
                    const HugeIcon(
                      icon: HugeIconsStrokeRounded.calendar03,
                      color: AppColors.skyBlue,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "${c.startDate != null ? "${c.startDate!.day}/${c.startDate!.month}/${c.startDate!.year}" : "TBD"} - ${c.endDate != null ? "${c.endDate!.day}/${c.endDate!.month}/${c.endDate!.year}" : "TBD"}",
                      style: AppTextStyles.caption1(color: AppColors.skyBlue),
                    ),
                  ],
                ),
              ],
              if (c.description != null && c.description!.isNotEmpty) ...[
                AppSizes.sm.ph,
                Text("Description", style: AppTextStyles.subtitle2(color: AppColors.white)),
                AppSizes.xxxs.ph,
                Text(c.description!, style: AppTextStyles.bodyText2(color: AppColors.creamWhite)),
              ],
              if (c.rules != null && c.rules!.isNotEmpty) ...[
                AppSizes.sm.ph,
                Text("Rules", style: AppTextStyles.subtitle2(color: AppColors.white)),
                AppSizes.xxxs.ph,
                Text(c.rules!, style: AppTextStyles.bodyText2(color: AppColors.creamWhite)),
              ],
              AppSizes.md.ph,
              Row(
                children: [
                  if (c.isRegistrationOpen)
                    Expanded(
                      child: AppButton(
                        onPressed: () {
                          final userId = ref.read(authProvider).user?.id;
                          if (userId == null) {
                            showErrorToast(content: "Please sign in to register.");
                            return;
                          }
                          ref.read(challengeProvider(groupId).notifier).registerForChallenge(
                            challengeId: c.id!,
                            userId: userId,
                            successCallBack: () {
                              Navigator.pop(sheetContext);
                              showSuccessToast(content: "Registered successfully!");
                            },
                            failureCallBack: (err) {
                              showErrorToast(content: err);
                            },
                          );
                        },
                        label: "Register Now",
                        bgColor: AppColors.primaryOrange,
                        labelStyle: AppTextStyles.button(color: Colors.black),
                      ),
                    ),
                  if (isOwnerOrAdmin) ...[
                    if (c.isRegistrationOpen) const SizedBox(width: 12),
                    Expanded(
                      child: AppButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (dialogCtx) => AlertDialog(
                              backgroundColor: AppColors.darkBgContainer,
                              title: const Text("Delete Challenge", style: TextStyle(color: Colors.white)),
                              content: const Text(
                                "Are you sure you want to delete this challenge?",
                                style: TextStyle(color: AppColors.creamWhite),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(dialogCtx),
                                  child: const Text("Cancel", style: TextStyle(color: AppColors.skyBlue)),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(dialogCtx);
                                    Navigator.pop(sheetContext);
                                    ref.read(challengeProvider(groupId).notifier).deleteChallenge(
                                      challengeId: c.id!,
                                      successCallBack: () {
                                        showSuccessToast(content: "Challenge deleted.");
                                      },
                                      failureCallBack: (err) {
                                        showErrorToast(content: err);
                                      },
                                    );
                                  },
                                  child: const Text("Delete", style: TextStyle(color: AppColors.red)),
                                ),
                              ],
                            ),
                          );
                        },
                        label: "Delete",
                        bgColor: AppColors.red.withValues(alpha: 0.8),
                        labelStyle: AppTextStyles.button(color: Colors.white),
                      ),
                    ),
                  ],
                ],
              ),
              AppSizes.lg.ph,
            ],
          ),
        ),
      ),
    );
  }

  List<ChallengeModel> _filterChallenges(List<ChallengeModel> all) {
    final query = _searchController.text.trim().toLowerCase();

    return all.where((c) {
      if (query.isNotEmpty) {
        final title = c.title?.toLowerCase() ?? '';
        final desc = c.description?.toLowerCase() ?? '';
        if (!title.contains(query) && !desc.contains(query)) {
          return false;
        }
      }

      if (_selectedStatus != AppStrings.allStatus) {
        if (_selectedStatus == AppStrings.registrationOpen &&
            c.status != 'REGISTRATION_OPEN') {
          return false;
        } else if (_selectedStatus == AppStrings.live && c.status != 'LIVE') {
          return false;
        } else if (_selectedStatus == AppStrings.finished &&
            c.status != 'FINISHED') {
          return false;
        }
      }

      if (_selectedType != AppStrings.allTypes) {
        if (_selectedType == AppStrings.free && c.type != 'FREE') {
          return false;
        } else if (_selectedType == AppStrings.paid && c.type != 'PAID') {
          return false;
        }
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final groupState = ref.watch(groupProvider);
    final group = groupState.group;

    if (group == null || group.id == null) {
      return Scaffold(
        backgroundColor: AppColors.darkBg,
        appBar: AppBar(
          title: const Text("Challenges Room"),
          backgroundColor: AppColors.darkBg,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.goNamed(Routes.group);
              }
            },
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

    final challengeState = ref.watch(challengeProvider(group.id!));
    final rawChallenges = challengeState.challenges ?? [];
    final stats = challengeState.stats;
    final totalCount = stats?['total'] ?? rawChallenges.length;
    final activeCount = stats?['active'] ??
        rawChallenges.where((c) => c.status == 'REGISTRATION_OPEN').length;
    final liveCount = stats?['live'] ??
        rawChallenges.where((c) => c.status == 'LIVE').length;

    final filtered = _filterChallenges(rawChallenges);
    final isLoading = challengeState.fetchState == AsyncState.loading;
    final isOwnerOrAdmin = ref.watch(isGroupAdminOrOwnerProvider);

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: AppBar(
        title: const Text("Challenges Room"),
        backgroundColor: AppColors.darkBg,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.goNamed(Routes.group);
            }
          },
        ),
        actions: [
          if (isOwnerOrAdmin)
            IconButton(
              icon: const HugeIcon(
                icon: HugeIconsStrokeRounded.addCircle,
                color: AppColors.primaryOrange,
              ),
              tooltip: "Create Challenge",
              onPressed: () => _openCreateChallengeDialog(context),
            ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primaryOrange,
        backgroundColor: AppColors.darkBgContainer,
        onRefresh: () async {
          await ref.read(challengeProvider(group.id!).notifier).fetchChallenges();
          await ref.read(challengeProvider(group.id!).notifier).fetchStats();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.xs),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                AppSizes.md.ph,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.currentChallenges,
                            style: AppTextStyles.headline4(color: Colors.white),
                          ),
                          Text(
                            AppStrings.currentChallengesDesc,
                            style: AppTextStyles.overLine(color: AppColors.skyBlue),
                          ),
                        ],
                      ),
                    ),
                    if (isOwnerOrAdmin) ...[
                      AppSizes.xs.pw,
                      AppButton(
                        isExpanded: false,
                        onPressed: () => _openCreateChallengeDialog(context),
                        prefix: const HugeIcon(
                          icon: HugeIconsStrokeRounded.addCircle,
                          color: AppColors.black,
                          size: 16,
                        ),
                        label: AppStrings.createChallenge,
                        labelStyle: AppTextStyles.caption1(color: AppColors.black),
                        bgColor: AppColors.primaryOrange,
                        radius: AppSizes.xxxs,
                      ),
                    ],
                  ],
                ),
              AppSizes.md.ph,
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(AppSizes.xs),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.skyBlue),
                        borderRadius: BorderRadius.circular(AppSizes.xs),
                        color: AppColors.darkBgContainer,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.blue,
                              borderRadius:
                                  BorderRadius.circular(AppSizes.xxxs),
                            ),
                            child: const Center(
                              child: HugeIcon(
                                icon: HugeIconsStrokeRounded.champion,
                                color: AppColors.white,
                                size: 20,
                              ),
                            ),
                          ),
                          AppSizes.xxs.pw,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppStrings.totalChallenges,
                                  style: AppTextStyles.overLine(
                                    color: AppColors.blue,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  "$totalCount",
                                  style: AppTextStyles.headline2(
                                    color: AppColors.blue,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  AppSizes.xxxs.pw,
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(AppSizes.xs),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.green),
                        borderRadius: BorderRadius.circular(AppSizes.xs),
                        color: AppColors.darkBgContainer,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.green,
                              borderRadius:
                                  BorderRadius.circular(AppSizes.xxxs),
                            ),
                            child: const Center(
                              child: HugeIcon(
                                icon: HugeIconsStrokeRounded.calendar04,
                                color: AppColors.white,
                                size: 20,
                              ),
                            ),
                          ),
                          AppSizes.xxs.pw,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppStrings.active,
                                  style: AppTextStyles.overLine(
                                    color: AppColors.green,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  "$activeCount",
                                  style: AppTextStyles.headline2(
                                    color: AppColors.green,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  AppSizes.xxxs.pw,
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(AppSizes.xs),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.purple),
                        borderRadius: BorderRadius.circular(AppSizes.xs),
                        color: AppColors.darkBgContainer,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.purple,
                              borderRadius:
                                  BorderRadius.circular(AppSizes.xxxs),
                            ),
                            child: const Center(
                              child: HugeIcon(
                                icon: HugeIconsStrokeRounded.stars,
                                color: AppColors.white,
                                size: 20,
                              ),
                            ),
                          ),
                          AppSizes.xxs.pw,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppStrings.liveNow,
                                  style: AppTextStyles.overLine(
                                    color: AppColors.purple,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  "$liveCount",
                                  style: AppTextStyles.headline2(
                                    color: AppColors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              AppSizes.md.ph,
              TextFormField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.darkBgContainer,
                  hintText: AppStrings.searchChallenges,
                  prefixIcon: const HugeIcon(
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
                    borderSide: const BorderSide(color: AppColors.skyBlue),
                  ),
                ),
              ),
              AppSizes.xs.ph,
              Row(
                children: [
                  Expanded(
                    child: AppDropdown(
                      button: Container(
                        padding: const EdgeInsets.all(AppSizes.xs),
                        decoration: BoxDecoration(
                          color: AppColors.darkBgContainer,
                          border: Border.all(
                            color: AppColors.skyBlue.withValues(alpha: 0.5),
                          ),
                          borderRadius: BorderRadius.circular(AppSizes.xs),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const HugeIcon(
                              icon: HugeIconsStrokeRounded.filter,
                              color: AppColors.white,
                            ),
                            Text(
                              _selectedStatus,
                              style: AppTextStyles.bodyText2(
                                color: AppColors.white,
                              ),
                            ),
                            const Icon(
                              Icons.keyboard_arrow_down,
                              color: AppColors.white,
                            ),
                          ],
                        ),
                      ),
                      items: const [
                        AppDropdownItem(
                          value: AppStrings.allStatus,
                          label: AppStrings.allStatus,
                        ),
                        AppDropdownItem(
                          value: AppStrings.registrationOpen,
                          label: AppStrings.registrationOpen,
                        ),
                        AppDropdownItem(
                          value: AppStrings.live,
                          label: AppStrings.live,
                        ),
                        AppDropdownItem(
                          value: AppStrings.finished,
                          label: AppStrings.finished,
                        ),
                      ],
                      onItemSelected: (val) {
                        setState(() => _selectedStatus = val);
                      },
                    ),
                  ),
                  AppSizes.xs.pw,
                  Expanded(
                    child: AppDropdown(
                      button: Container(
                        padding: const EdgeInsets.all(AppSizes.xs),
                        decoration: BoxDecoration(
                          color: AppColors.darkBgContainer,
                          border: Border.all(
                            color: AppColors.skyBlue.withValues(alpha: 0.5),
                          ),
                          borderRadius: BorderRadius.circular(AppSizes.xs),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const HugeIcon(
                              icon: HugeIconsStrokeRounded.userMultiple02,
                              color: AppColors.white,
                            ),
                            Text(
                              _selectedType,
                              style: AppTextStyles.bodyText2(
                                color: AppColors.white,
                              ),
                            ),
                            const Icon(
                              Icons.keyboard_arrow_down,
                              color: AppColors.white,
                            ),
                          ],
                        ),
                      ),
                      items: const [
                        AppDropdownItem(
                          value: AppStrings.allTypes,
                          label: AppStrings.allTypes,
                        ),
                        AppDropdownItem(
                          value: AppStrings.free,
                          label: AppStrings.free,
                        ),
                        AppDropdownItem(
                          value: AppStrings.paid,
                          label: AppStrings.paid,
                        ),
                      ],
                      onItemSelected: (val) {
                        setState(() => _selectedType = val);
                      },
                    ),
                  ),
                ],
              ),
              AppSizes.md.ph,
              if (isLoading)
                const Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryOrange,
                    ),
                  ),
                )
              else if (filtered.isEmpty)
                Column(
                  children: [
                    AppSizes.lg.ph,
                    Container(
                      height: 80,
                      width: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.skyBlue.withValues(alpha: 0.2),
                      ),
                      child: const HugeIcon(
                        icon: HugeIconsStrokeRounded.champion,
                        color: AppColors.skyBlue,
                        size: 36,
                      ),
                    ),
                    AppSizes.md.ph,
                    Text(
                      AppStrings.noChallengesAvailable,
                      style: AppTextStyles.headline2(color: Colors.white),
                    ),
                    AppSizes.xs.ph,
                    Text(
                      AppStrings.noChallengesAvailableDesc,
                      style: AppTextStyles.overLine(color: AppColors.skyBlue),
                      textAlign: TextAlign.center,
                    ),
                    AppSizes.md.ph,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const HugeIcon(
                          icon: HugeIconsStrokeRounded.calendar04,
                          color: AppColors.skyBlue,
                        ),
                        AppSizes.xs.pw,
                        Text(
                          AppStrings.newChallengesComingSoon,
                          style: AppTextStyles.overLine(
                            color: AppColors.skyBlue,
                          ),
                        ),
                      ],
                    ),
                    if (isOwnerOrAdmin) ...[
                      AppSizes.md.ph,
                      AppButton(
                        isExpanded: false,
                        onPressed: () => _openCreateChallengeDialog(context),
                        prefix: const HugeIcon(
                          icon: HugeIconsStrokeRounded.addCircle,
                          color: AppColors.black,
                          size: 16,
                        ),
                        label: AppStrings.createChallenge,
                        labelStyle: AppTextStyles.bodyText2(color: AppColors.black),
                        bgColor: AppColors.primaryOrange,
                        radius: AppSizes.xxxs,
                      ),
                    ],
                    AppSizes.xxlg.ph,
                  ],
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filtered.length,
                  separatorBuilder: (_, _) => AppSizes.xs.ph,
                  itemBuilder: (context, index) {
                    final c = filtered[index];
                    final isLive = c.status == 'LIVE';

                    return GestureDetector(
                      onTap: () => _showChallengeDetailsSheet(context, c, isOwnerOrAdmin, group.id!),
                      child: Container(
                        padding: const EdgeInsets.all(AppSizes.xs),
                        decoration: BoxDecoration(
                          color: AppColors.darkBgContainer,
                          borderRadius: BorderRadius.circular(AppSizes.xxxs),
                          border: Border.all(
                            color: isLive
                                ? AppColors.lightGreen
                                : AppColors.skyBlue.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (c.image != null && c.image!.isNotEmpty)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: Image.network(
                                  _resolveImageUrl(c.image),
                                  height: 140,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    height: 140,
                                    width: double.infinity,
                                    color: AppColors.darkBg,
                                    child: const Center(
                                      child: Icon(Icons.emoji_events_outlined, color: AppColors.primaryOrange, size: 40),
                                    ),
                                  ),
                                ),
                              ),
                            if (c.image != null && c.image!.isNotEmpty) AppSizes.xs.ph,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    c.title ?? 'Untitled Challenge',
                                    style: AppTextStyles.headline3(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isLive
                                        ? AppColors.lightGreen.withValues(alpha: 0.2)
                                        : AppColors.primaryOrange.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    c.status ?? 'OPEN',
                                    style: TextStyle(
                                      color: isLive
                                          ? AppColors.lightGreen
                                          : AppColors.primaryOrange,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (c.description != null &&
                                c.description!.isNotEmpty) ...[
                              AppSizes.xxs.ph,
                              Text(
                                c.description!,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 13,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                            AppSizes.xs.ph,
                            Row(
                              children: [
                                Chip(
                                  label: Text(
                                    c.type == 'PAID'
                                        ? "\$${c.price?.toStringAsFixed(2)}"
                                        : "FREE",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                    ),
                                  ),
                                  backgroundColor: AppColors.bgBlue,
                                ),
                                AppSizes.xxs.pw,
                                if (c.prize != null)
                                  Chip(
                                    label: Text(
                                      "Prize: ${c.prize}",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                      ),
                                    ),
                                    backgroundColor: AppColors.bgBlue,
                                  ),
                                const Spacer(),
                                AppButton(
                                  isExpanded: false,
                                  onPressed: () => _showChallengeDetailsSheet(context, c, isOwnerOrAdmin, group.id!),
                                  label: "View Challenge",
                                  labelStyle: AppTextStyles.caption1(
                                    color: Colors.black,
                                  ),
                                  bgColor: AppColors.primaryOrange,
                                  radius: 4,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    ),
  );
}
}

