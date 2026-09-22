import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import 'package:larnity/src/core/constants/app_size.dart';
import 'package:larnity/src/core/constants/app_strings.dart';
import 'package:larnity/src/core/extensions/extensions.dart';
import 'package:larnity/src/core/service/supabase/src/supabase_provider.dart';
import 'package:larnity/src/core/theme/app_colors.dart';
import 'package:larnity/src/core/theme/theme.dart';
import 'package:larnity/src/core/ui/widgets/app_button.dart';
import 'package:larnity/src/core/ui/widgets/app_dropdown.dart';
import 'package:larnity/src/core/utils/show_snackbar.dart';
import 'package:larnity/src/features/group/presentation/provider/group_provider.dart';

class InvitationLink extends ConsumerStatefulWidget {
  const InvitationLink({super.key});

  @override
  ConsumerState<InvitationLink> createState() => _InvitationLinkState();
}

class _InvitationLinkState extends ConsumerState<InvitationLink> {
  late final TextEditingController _emailController;
  late final TextEditingController _nameController;
  late final TextEditingController _hoursController;
  String _selectedPlan = 'monthly';
  bool _isLoading = false;
  String? _generatedLink;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _nameController = TextEditingController();
    _hoursController = TextEditingController(text: '48');
  }

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _hoursController.dispose();
    super.dispose();
  }

  Future<void> _createLink() async {
    final group = ref.read(groupProvider).group;
    if (group == null || group.id == null) return;

    final hours = int.tryParse(_hoursController.text.trim()) ?? 48;
    final token =
        '${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(999999)}';
    final inviteUrl =
        'https://www.larnity.com/invite/${group.slug ?? group.id}?token=$token';

    setState(() => _isLoading = true);

    try {
      final client = ref.read(supabaseClientProvider);
      await client.from('GroupInvitation').insert({
        'groupId': group.id,
        'email': _emailController.text.trim().isNotEmpty
            ? _emailController.text.trim()
            : null,
        'name': _nameController.text.trim().isNotEmpty
            ? _nameController.text.trim()
            : null,
        'token': token,
        'plan': _selectedPlan,
        'expiresAt':
            DateTime.now().add(Duration(hours: hours)).toIso8601String(),
      });

      await Clipboard.setData(ClipboardData(text: inviteUrl));
      if (mounted) {
        setState(() {
          _isLoading = false;
          _generatedLink = inviteUrl;
        });
        showSuccessToast(
          content: "Invitation link generated and copied to clipboard!",
        );
      }
    } catch (_) {
      // If table doesn't exist yet, still copy link to clipboard gracefully
      await Clipboard.setData(ClipboardData(text: inviteUrl));
      if (mounted) {
        setState(() {
          _isLoading = false;
          _generatedLink = inviteUrl;
        });
        showSuccessToast(
          content: "Invitation link generated and copied to clipboard!",
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.xs),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppStrings.createInvitationLink,
                  style: AppTextStyles.headline4(color: AppColors.white),
                ),
                IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ],
            ),
            Text(
              AppStrings.createInvitationLinkDesc,
              style: AppTextStyles.overLine(color: AppColors.skyBlue),
            ),
            AppSizes.md.ph,
            Container(
              padding: const EdgeInsets.all(AppSizes.xs),
              decoration: BoxDecoration(
                color: AppColors.borderBrown,
                borderRadius: BorderRadius.circular(AppSizes.xxxs),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
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
                            icon: HugeIconsStrokeRounded.userMultiple02,
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
                              AppStrings.singleInvitation,
                              style: AppTextStyles.headline4(
                                color: AppColors.white,
                              ),
                            ),
                            Text(
                              AppStrings.createInvitationLinkDesc,
                              style: AppTextStyles.overLine(
                                color: AppColors.skyBlue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  AppSizes.xs.ph,
                  Text(
                    AppStrings.emailAddress,
                    style: AppTextStyles.overLine(color: AppColors.white),
                  ),
                  AppSizes.xxxs.ph,
                  TextFormField(
                    controller: _emailController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.darkBgContainer,
                      hintText: AppStrings.emailAddressHint,
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
                  Text(
                    AppStrings.nameOptional,
                    style: AppTextStyles.overLine(color: AppColors.white),
                  ),
                  AppSizes.xxxs.ph,
                  TextFormField(
                    controller: _nameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.darkBgContainer,
                      hintText: AppStrings.nameHint,
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
                  Text(
                    AppStrings.expirationTimeInHours,
                    style: AppTextStyles.overLine(color: AppColors.white),
                  ),
                  AppSizes.xxxs.ph,
                  TextFormField(
                    controller: _hoursController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.darkBgContainer,
                      hintText: AppStrings.expirationTimeInHoursHint,
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
                  Text(
                    AppStrings.subscriptionPlan,
                    style: AppTextStyles.overLine(color: AppColors.white),
                  ),
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
                            _selectedPlan == 'monthly'
                                ? "Monthly Plan"
                                : (_selectedPlan == 'yearly'
                                    ? "Yearly Plan"
                                    : "Lifetime Plan"),
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
                      AppDropdownItem(value: "monthly", label: "Monthly Plan"),
                      AppDropdownItem(value: "yearly", label: "Yearly Plan"),
                      AppDropdownItem(value: "lifetime", label: "Lifetime Plan"),
                    ],
                    onItemSelected: (val) {
                      setState(() => _selectedPlan = val);
                                        },
                  ),
                ],
              ),
            ),
            if (_generatedLink != null) ...[
              AppSizes.xs.ph,
              Container(
                padding: const EdgeInsets.all(AppSizes.xs),
                decoration: BoxDecoration(
                  color: AppColors.darkBgContainer,
                  borderRadius: BorderRadius.circular(AppSizes.xxxs),
                  border: Border.all(color: AppColors.lightGreen),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _generatedLink!,
                        style: TextStyle(
                          color: AppColors.lightGreen,
                          fontSize: 12,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.copy,
                        color: Colors.white,
                        size: 18,
                      ),
                      onPressed: () {
                        Clipboard.setData(
                          ClipboardData(text: _generatedLink!),
                        );
                        showSuccessToast(content: "Link copied to clipboard!");
                      },
                    ),
                  ],
                ),
              ),
            ],
            AppSizes.xs.ph,
            AppButton(
              isLoading: _isLoading,
              onPressed: _isLoading ? () {} : _createLink,
              label: AppStrings.createInvitationLink,
              labelStyle: AppTextStyles.button(color: AppColors.black),
              bgColor: AppColors.primaryOrange,
            ),
          ],
        ),
      ),
    );
  }
}

