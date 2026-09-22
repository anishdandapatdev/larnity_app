import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:larnity/src/core/constants/app_size.dart';
import 'package:larnity/src/core/constants/app_strings.dart';
import 'package:larnity/src/core/extensions/extensions.dart';
import 'package:larnity/src/core/theme/app_colors.dart';
import 'package:larnity/src/core/theme/theme.dart';
import 'package:larnity/src/core/ui/widgets/app_button.dart';
import 'package:larnity/src/core/utils/show_snackbar.dart';
import 'package:larnity/src/features/group/data/models/member_model.dart';
import 'package:larnity/src/features/group/presentation/provider/member_provider.dart';

class AddManager extends ConsumerStatefulWidget {
  final String groupId;
  const AddManager({super.key, required this.groupId});

  @override
  ConsumerState<AddManager> createState() => _AddManagerState();
}

class _AddManagerState extends ConsumerState<AddManager> {
  MemberModel? _selectedMember;
  String _selectedRole = 'ADMIN';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final memberState = ref.watch(memberProvider(widget.groupId));
    final candidates = (memberState.members ?? [])
        .where((m) => m.role.toUpperCase() == 'MEMBER')
        .toList();

    return Padding(
      padding: const EdgeInsets.all(AppSizes.xs),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
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
            Text(
              AppStrings.sendManagerInvitation,
              style: AppTextStyles.headline4(),
            ),
            Text(
              "Select an existing member to promote them to Manager / Admin.",
              style: AppTextStyles.overLine(color: AppColors.skyBlue),
            ),
            AppSizes.lg.ph,
            Text(AppStrings.selectManager, style: AppTextStyles.overLine()),
            AppSizes.xxxs.ph,
            if (candidates.isEmpty)
              Container(
                padding: const EdgeInsets.all(AppSizes.xs),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.skyBlue.withValues(alpha: 0.3)),
                  borderRadius: BorderRadius.circular(AppSizes.xs),
                ),
                child: const Text(
                  "No regular members available to promote. Invite members first.",
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.xs),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.skyBlue.withValues(alpha: 0.5)),
                  borderRadius: BorderRadius.circular(AppSizes.xs),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<MemberModel>(
                    isExpanded: true,
                    dropdownColor: AppColors.darkBgContainer,
                    value: _selectedMember,
                    hint: const Text(
                      "Choose Member",
                      style: TextStyle(color: Colors.grey),
                    ),
                    items: candidates.map((m) {
                      final p = m.profile;
                      final name = '${p?['firstname'] ?? ''} ${p?['lastname'] ?? ''}'.trim();
                      return DropdownMenuItem(
                        value: m,
                        child: Text(
                          name.isNotEmpty ? name : 'Member ${m.userId.substring(0, 6)}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedMember = val),
                  ),
                ),
              ),
            AppSizes.sm.ph,
            Text("Select Role", style: AppTextStyles.overLine()),
            AppSizes.xxxs.ph,
            RadioGroup<String>(
              groupValue: _selectedRole,
              onChanged: (val) => setState(() => _selectedRole = val!),
              child: Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      contentPadding: EdgeInsets.zero,
                      title: const Text("Admin", style: TextStyle(color: Colors.white, fontSize: 13)),
                      value: 'ADMIN',
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      contentPadding: EdgeInsets.zero,
                      title: const Text("Moderator", style: TextStyle(color: Colors.white, fontSize: 13)),
                      value: 'MODERATOR',
                    ),
                  ),
                ],
              ),
            ),
            AppSizes.sm.ph,
            AppButton(
              onPressed: (_isLoading || _selectedMember == null)
                  ? () {}
                  : () {
                      setState(() => _isLoading = true);
                      ref.read(memberProvider(widget.groupId).notifier).updateMemberRole(
                            memberId: _selectedMember!.id!,
                            role: _selectedRole,
                            successCallBack: () {
                              if (mounted) {
                                setState(() => _isLoading = false);
                                showInfoToast(content: "Member promoted to $_selectedRole!");
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
                    },
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
                  : const Text(
                      "Assign Role",
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
