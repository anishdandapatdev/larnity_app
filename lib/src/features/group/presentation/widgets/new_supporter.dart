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
  const NewSupporter({super.key});

  @override
  ConsumerState<NewSupporter> createState() => _NewSupporterState();
}

class _NewSupporterState extends ConsumerState<NewSupporter> {
  final _phoneController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _linkController = TextEditingController();
  MemberModel? _selectedMember;

  @override
  void dispose() {
    _phoneController.dispose();
    _whatsappController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  void _submit() {
    final groupId = ref.read(groupProvider).group?.id;
    if (groupId == null || _selectedMember == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a member')));
      return;
    }

    final supporter = SupporterModel(
      groupId: groupId,
      userId: _selectedMember!.userId,
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
    final groupId = ref.watch(groupProvider).group?.id ?? '';
    final memberState = ref.watch(memberProvider(groupId));
    final supporterState = ref.watch(supporterProvider(groupId));
    final isLoading = supporterState.createState == AsyncState.loading;

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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.xs),
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.skyBlue.withValues(alpha: 0.5),
                ),
                borderRadius: BorderRadius.circular(AppSizes.xs),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<MemberModel>(
                  isExpanded: true,
                  dropdownColor: AppColors.darkBg,
                  hint: Text(
                    "Select a member",
                    style: AppTextStyles.bodyText2(color: AppColors.white),
                  ),
                  value: _selectedMember,
                  icon: const Icon(
                    Icons.keyboard_arrow_down,
                    color: AppColors.white,
                  ),
                  onChanged: (MemberModel? newValue) {
                    setState(() {
                      _selectedMember = newValue;
                    });
                  },
                  items:
                      memberState.members?.map((MemberModel member) {
                        return DropdownMenuItem<MemberModel>(
                          value: member,
                          child: Text(
                            member.memberName,
                            style: const TextStyle(color: AppColors.white),
                          ),
                        );
                      }).toList() ??
                      [],
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
