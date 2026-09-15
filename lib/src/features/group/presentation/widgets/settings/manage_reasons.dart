import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import 'package:larnity/src/core/constants/app_size.dart';
import 'package:larnity/src/core/constants/app_strings.dart';
import 'package:larnity/src/core/extensions/extensions.dart';
import 'package:larnity/src/core/theme/app_colors.dart';
import 'package:larnity/src/core/theme/theme.dart';
import 'package:larnity/src/core/ui/widgets/app_button.dart';

class ManageReasons extends StatefulWidget {
  const ManageReasons({super.key});

  @override
  State<ManageReasons> createState() => _ManageReasonsState();
}

class _ManageReasonsState extends State<ManageReasons> {
  final List<TextEditingController> _controllers = [];
  final List<bool> _isEditing = [];

  void _addReason() {
    setState(() {
      _controllers.add(TextEditingController());
      _isEditing.add(false);
    });
  }

  void _deleteReason(int index) {
    setState(() {
      _controllers.removeAt(index);
      _isEditing.removeAt(index);
    });
  }

  void _toggleEdit(int index) {
    setState(() {
      _isEditing[index] = !_isEditing[index];
    });
  }

  // void _editReason(TextEditingController ctrl) {
  //   // Here you can handle edit logic, e.g. open dialog for editing
  //   // For now, we just focus on the text field itself.
  //   ctrl.selection = TextSelection.fromPosition(
  //     TextPosition(offset: ctrl.text.length),
  //   );
  // }

  // void _saveChanges() {
  //   List<String> reasons = _controllers.map((c) => c.text).toList();
  //   print("Saved Reasons: $reasons");
  // }

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
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () {
                    context.pop();
                  },
                  icon: Icon(Icons.close),
                ),
              ],
            ),
            Text(AppStrings.inviteMembers, style: AppTextStyles.headline4()),
            Text(
              AppStrings.inviteMembersDesc,
              style: AppTextStyles.overLine(color: AppColors.skyBlue),
            ),
            AppSizes.lg.ph,
            Column(
              children: _controllers
                  .map(
                    (c) => Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: c,
                              readOnly: !_isEditing[_controllers.indexOf(c)],
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: AppColors.darkBgContainer,
                                hintText: AppStrings.newReason,
                                hintStyle: AppTextStyles.button(
                                  color: AppColors.skyBlue,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppSizes.xxxs,
                                  ),
                                  borderSide: BorderSide(
                                    color: AppColors.skyBlue.withValues(
                                      alpha: 0.5,
                                    ),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppSizes.xxxs,
                                  ),
                                  borderSide: BorderSide(
                                    color: AppColors.skyBlue,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: HugeIcon(
                              icon: _isEditing[_controllers.indexOf(c)]
                                  ? HugeIconsStrokeRounded.tick02
                                  : HugeIconsStrokeRounded.pencilEdit02,
                              color: AppColors.white,
                            ),
                            onPressed: () =>
                                _toggleEdit(_controllers.indexOf(c)),
                          ),
                          IconButton(
                            icon: HugeIcon(
                              icon: HugeIconsStrokeRounded.delete02,
                              color: Colors.red,
                            ),
                            onPressed: () =>
                                _deleteReason(_controllers.indexOf(c)),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
            AppSizes.xs.ph,
            AppButton(
              onPressed: _addReason,
              label: AppStrings.addNewReason,
              labelStyle: AppTextStyles.button(color: AppColors.white),
              bgColor: Colors.transparent,
              borderColor: AppColors.skyBlue.withValues(alpha: 0.5),
            ),
            AppSizes.xs.ph,
            AppButton(
              onPressed: () {},
              label: AppStrings.saveChanges,
              labelStyle: AppTextStyles.button(color: AppColors.white),
              bgColor: Colors.transparent,
              borderColor: AppColors.skyBlue.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}
