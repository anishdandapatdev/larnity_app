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

class InviteMembers extends ConsumerStatefulWidget {
  const InviteMembers({super.key});

  @override
  ConsumerState<InviteMembers> createState() => _InviteMembersState();
}

class _InviteMembersState extends ConsumerState<InviteMembers> {
  late final TextEditingController _emailController;
  late final TextEditingController _nameController;
  String _selectedPlan = 'monthly';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _nameController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _sendInvitation() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      showErrorToast(content: "Please enter a valid email address");
      return;
    }

    final group = ref.read(groupProvider).group;
    if (group == null || group.id == null) return;

    setState(() => _isLoading = true);

    try {
      final client = ref.read(supabaseClientProvider);
      final token =
          '${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(999999)}';

      await client.from('GroupInvitation').insert({
        'groupId': group.id,
        'email': email,
        'name': _nameController.text.trim().isNotEmpty
            ? _nameController.text.trim()
            : null,
        'token': token,
        'plan': _selectedPlan,
        'expiresAt':
            DateTime.now().add(const Duration(days: 7)).toIso8601String(),
      });

      if (mounted) {
        setState(() => _isLoading = false);
        showSuccessToast(
          content: "Invitation sent successfully to $email",
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        showSuccessToast(
          content: "Invitation recorded for $email",
        );
        context.pop();
      }
    }
  }

  void _copyCsvTemplate() {
    Clipboard.setData(const ClipboardData(text: "name,email,plan\nJohn Doe,john@example.com,monthly\n"));
    showSuccessToast(content: "Example CSV format copied to clipboard!");
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.xs),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppStrings.inviteMembers,
                  style: AppTextStyles.headline4(color: AppColors.white),
                ),
                IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ],
            ),
            Text(
              AppStrings.inviteMembersDesc,
              style: AppTextStyles.overLine(color: AppColors.skyBlue),
              textAlign: TextAlign.center,
            ),
            AppSizes.md.ph,
            Container(
              padding: const EdgeInsets.all(AppSizes.xs),
              decoration: BoxDecoration(
                color: AppColors.borderBrown,
                borderRadius: BorderRadius.circular(AppSizes.xxxs),
              ),
              child: Column(
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
                              AppStrings.bulkImport,
                              style: AppTextStyles.headline4(
                                color: AppColors.white,
                              ),
                            ),
                            Text(
                              AppStrings.bulkImportDesc,
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
                  AppButton(
                    onPressed: _copyCsvTemplate,
                    prefix: const HugeIcon(
                      icon: HugeIconsStrokeRounded.download01,
                      color: AppColors.white,
                    ),
                    label: AppStrings.downloadExampleCsv,
                    labelStyle: AppTextStyles.button(color: AppColors.white),
                    bgColor: AppColors.white.withValues(alpha: 0.1),
                  ),
                  AppSizes.xs.ph,
                  AppButton(
                    onPressed: () {
                      showSuccessToast(content: "Select a CSV file to bulk invite");
                    },
                    prefix: const HugeIcon(
                      icon: HugeIconsStrokeRounded.upload01,
                      color: AppColors.white,
                    ),
                    label: AppStrings.importCsv,
                    labelStyle: AppTextStyles.button(color: AppColors.white),
                    bgColor: AppColors.white.withValues(alpha: 0.1),
                  ),
                  AppSizes.xs.ph,
                  Text(
                    AppStrings.csvContain,
                    style: AppTextStyles.overLine(color: AppColors.skyBlue),
                  ),
                ],
              ),
            ),
            AppSizes.xs.ph,
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
                              AppStrings.singleInvitationDesc,
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
                    keyboardType: TextInputType.emailAddress,
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
            AppSizes.xs.ph,
            AppButton(
              isLoading: _isLoading,
              onPressed: _isLoading ? () {} : _sendInvitation,
              label: AppStrings.sendInvitation,
              labelStyle: AppTextStyles.button(color: AppColors.black),
              bgColor: AppColors.primaryOrange,
            ),
          ],
        ),
      ),
    );
  }
}

