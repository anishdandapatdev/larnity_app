import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:larnity/src/core/constants/app_size.dart';
import 'package:larnity/src/core/constants/app_strings.dart';
import 'package:larnity/src/core/extensions/extensions.dart';
import 'package:larnity/src/core/theme/app_colors.dart';
import 'package:larnity/src/core/theme/theme.dart';
import 'package:larnity/src/core/ui/widgets/app_button.dart';
import 'package:larnity/src/core/utils/async_states.dart';
import 'package:larnity/src/features/group/data/models/member_model.dart';
import 'package:larnity/src/features/group/data/models/supporter_model.dart';
import 'package:larnity/src/features/group/presentation/provider/group_provider.dart';
import 'package:larnity/src/features/group/presentation/provider/member_provider.dart';
import 'package:larnity/src/features/group/presentation/provider/supporter_provider.dart';

class NewSupporter extends ConsumerStatefulWidget {
  final String? groupId;
  const NewSupporter({super.key, this.groupId});

  @override
  ConsumerState<NewSupporter> createState() => _NewSupporterState();
}

class _NewSupporterState extends ConsumerState<NewSupporter> {
  final _phoneController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _linkController = TextEditingController();
  String? _selectedUserId;
  MemberModel? _selectedMember;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final gId = widget.groupId ?? ref.read(groupProvider).group?.id;
      if (gId != null && gId.isNotEmpty) {
        ref.read(memberProvider(gId).notifier).fetchMembers();
      }
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _whatsappController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  void _onMemberSelected(MemberModel member) {
    setState(() {
      _selectedMember = member;
      _selectedUserId = member.userId;
      final phone = member.profile?['phoneNumber']?.toString() ?? '';
      if (phone.isNotEmpty && _phoneController.text.isEmpty) {
        _phoneController.text = phone.startsWith('+91')
            ? phone.substring(3)
            : phone.startsWith('91') && phone.length > 10
                ? phone.substring(2)
                : phone;
      }
      if (phone.isNotEmpty && _whatsappController.text.isEmpty) {
        _whatsappController.text = phone.startsWith('+91')
            ? phone.substring(3)
            : phone.startsWith('91') && phone.length > 10
                ? phone.substring(2)
                : phone;
      }
    });
  }

  void _submit() {
    final groupId = widget.groupId ?? ref.read(groupProvider).group?.id;
    final member = _selectedMember;
    if (groupId == null || groupId.isEmpty || member == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a member')));
      return;
    }

    final supporter = SupporterModel(
      groupId: groupId,
      userId: member.userId,
      phoneNumber: _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
      whatsappNumber: _whatsappController.text.trim().isEmpty
          ? null
          : '+91${_whatsappController.text.trim()}',
      link: _linkController.text.trim().isEmpty
          ? null
          : _linkController.text.trim(),
    );

    ref
        .read(supporterProvider(groupId).notifier)
        .addSupporter(
          supporter: supporter,
          successCallBack: () {
            context.pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Supporter added successfully!')),
            );
          },
          failureCallBack: (error) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(error)));
          },
        );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveGroupId =
        widget.groupId ?? ref.watch(groupProvider).group?.id ?? '';
    final memberState = ref.watch(memberProvider(effectiveGroupId));
    final supporterState = ref.watch(supporterProvider(effectiveGroupId));
    final isLoading = supporterState.createState == AsyncState.loading;
    final isMembersLoading = memberState.fetchState == AsyncState.loading &&
        (memberState.members == null || memberState.members!.isEmpty);
    final members = memberState.members ?? [];

    return Padding(
      padding: const EdgeInsets.all(AppSizes.xs),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () {
                    if (!isLoading) context.pop();
                  },
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  AppStrings.addNewSupporter,
                  style: AppTextStyles.headline4(),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    AppStrings.addNewSupporterDesc,
                    style: AppTextStyles.overLine(color: AppColors.skyBlue),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            AppSizes.lg.ph,

            AppSizes.xs.ph,
            Text(AppStrings.selectMember, style: AppTextStyles.overLine()),
            AppSizes.xxxs.ph,

            // Dropdown to select member
            if (isMembersLoading)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.xs,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.skyBlue.withValues(alpha: 0.5),
                  ),
                  borderRadius: BorderRadius.circular(AppSizes.xs),
                  color: AppColors.darkBgContainer,
                ),
                child: const Row(
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primaryOrange,
                      ),
                    ),
                    SizedBox(width: AppSizes.xs),
                    Text(
                      "Loading members...",
                      style: TextStyle(color: AppColors.skyBlue, fontSize: 14),
                    ),
                  ],
                ),
              )
            else if (members.isEmpty)
              InkWell(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "No members found in this group yet. Invite members to select them.",
                      ),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.xs,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.skyBlue.withValues(alpha: 0.5),
                    ),
                    borderRadius: BorderRadius.circular(AppSizes.xs),
                    color: AppColors.darkBgContainer,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "No members available",
                        style:
                            AppTextStyles.bodyText2(color: AppColors.skyBlue),
                      ),
                      const Icon(
                        Icons.info_outline,
                        color: AppColors.skyBlue,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.xs),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.skyBlue.withValues(alpha: 0.5),
                  ),
                  borderRadius: BorderRadius.circular(AppSizes.xs),
                  color: AppColors.darkBgContainer,
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    dropdownColor: AppColors.darkBgContainer,
                    hint: Text(
                      "Select a member",
                      style: AppTextStyles.bodyText2(color: AppColors.white),
                    ),
                    value: members.any((m) => m.userId == _selectedUserId)
                        ? _selectedUserId
                        : null,
                    icon: const Icon(
                      Icons.keyboard_arrow_down,
                      color: AppColors.white,
                    ),
                    onChanged: (String? newUserId) {
                      if (newUserId != null) {
                        final chosen = members
                            .where((m) => m.userId == newUserId)
                            .firstOrNull;
                        if (chosen != null) {
                          _onMemberSelected(chosen);
                        }
                      }
                    },
                    items: members.map((MemberModel member) {
                      final rawName = member.memberName.trim();
                      final displayName = rawName.isNotEmpty
                          ? rawName
                          : (member.memberEmail ??
                              'Member ${member.userId.length >= 6 ? member.userId.substring(0, 6) : member.userId}');
                      final isOwner = member.planType == 'OWNER' ||
                          member.role.toUpperCase() == 'OWNER';
                      final isAdmin = member.isAdmin;
                      final roleBadge = isOwner
                          ? ' (Owner)'
                          : (isAdmin ? ' (Admin)' : '');

                      return DropdownMenuItem<String>(
                        value: member.userId,
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 12,
                              backgroundColor: AppColors.primaryOrange,
                              backgroundImage: member.memberImage != null &&
                                      member.memberImage!.isNotEmpty
                                  ? NetworkImage(member.memberImage!)
                                  : null,
                              child: member.memberImage == null ||
                                      member.memberImage!.isEmpty
                                  ? const Icon(
                                      Icons.person,
                                      size: 14,
                                      color: AppColors.white,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                displayName,
                                style:
                                    const TextStyle(color: AppColors.white),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (roleBadge.isNotEmpty)
                              Text(
                                roleBadge,
                                style: const TextStyle(
                                  color: AppColors.skyBlue,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            AppSizes.xs.ph,

            Text("Phone Number", style: AppTextStyles.overLine()),
            AppSizes.xxxs.ph,
            TextFormField(
              controller: _phoneController,
              style: const TextStyle(color: AppColors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.darkBgContainer,
                hintText: "Enter phone number",
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
            Text(AppStrings.whatsappNumber, style: AppTextStyles.overLine()),
            AppSizes.xxxs.ph,
            TextFormField(
              controller: _whatsappController,
              style: const TextStyle(color: AppColors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.darkBgContainer,
                hintText: AppStrings.whatsappNumberHint,
                hintStyle: AppTextStyles.button(color: AppColors.skyBlue),
                prefixText: '+91 ',
                prefixStyle: const TextStyle(color: AppColors.white),
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
            Text(AppStrings.booking, style: AppTextStyles.overLine()),
            AppSizes.xxxs.ph,
            TextFormField(
              controller: _linkController,
              style: const TextStyle(color: AppColors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.darkBgContainer,
                hintText: AppStrings.enterAppointmentBooking,
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
            AppButton(
              onPressed: isLoading ? () {} : _submit,
              label: isLoading ? "Creating..." : AppStrings.create,
              labelStyle: AppTextStyles.button(color: AppColors.black),
              bgColor: isLoading ? AppColors.skyBlue : AppColors.primaryOrange,
            ),
          ],
        ),
      ),
    );
  }
}
