import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import 'package:larnity/src/core/constants/app_size.dart';
import 'package:larnity/src/core/constants/app_strings.dart';
import 'package:larnity/src/core/extensions/extensions.dart';
import 'package:larnity/src/core/theme/app_colors.dart';
import 'package:larnity/src/core/theme/theme.dart';
import 'package:larnity/src/core/ui/widgets/app_button.dart';
import 'package:larnity/src/core/utils/show_snackbar.dart';
import 'package:larnity/src/features/group/presentation/provider/group_provider.dart';

class ManageReasons extends ConsumerStatefulWidget {
  const ManageReasons({super.key});

  @override
  ConsumerState<ManageReasons> createState() => _ManageReasonsState();
}

class _ManageReasonsState extends ConsumerState<ManageReasons> {
  final List<TextEditingController> _controllers = [];
  final List<bool> _isEditing = [];
  bool _isLoading = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
  }

  void _initFromGroup() {
    if (_isInitialized) return;
    final group = ref.read(groupProvider).group;
    if (group == null) return;

    final existingReasons = group.landingSettings?['leaveReasons'];
    List<String> list = [];
    if (existingReasons is List) {
      list = existingReasons.map((e) => e.toString()).toList();
    } else {
      list = [
        "Too busy",
        "Content not relevant",
        "Financial reasons",
        "Found another community",
        "Other",
      ];
    }

    for (final r in list) {
      _controllers.add(TextEditingController(text: r));
      _isEditing.add(false);
    }
    _isInitialized = true;
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _addReason() {
    setState(() {
      _controllers.add(TextEditingController());
      _isEditing.add(true);
    });
  }

  void _deleteReason(int index) {
    setState(() {
      _controllers[index].dispose();
      _controllers.removeAt(index);
      _isEditing.removeAt(index);
    });
  }

  void _toggleEdit(int index) {
    setState(() {
      _isEditing[index] = !_isEditing[index];
    });
  }

  Future<void> _saveChanges() async {
    final group = ref.read(groupProvider).group;
    if (group == null) return;

    final reasons = _controllers
        .map((c) => c.text.trim())
        .where((text) => text.isNotEmpty)
        .toList();

    setState(() => _isLoading = true);

    final currentSettings =
        Map<String, dynamic>.from(group.landingSettings ?? {});
    currentSettings['leaveReasons'] = reasons;

    final updated = group.copyWith(landingSettings: currentSettings);

    await ref.read(groupProvider.notifier).updateGroup(
          group: updated,
          successCallBack: () {
            if (mounted) {
              setState(() => _isLoading = false);
              showSuccessToast(content: "Leave reasons saved successfully");
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
  }

  @override
  Widget build(BuildContext context) {
    _initFromGroup();

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
                  AppStrings.manageReasons,
                  style: AppTextStyles.headline4(color: AppColors.white),
                ),
                IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ],
            ),
            Text(
              "Configure options presented to members when requesting to leave.",
              style: AppTextStyles.overLine(color: AppColors.skyBlue),
            ),
            AppSizes.md.ph,
            Column(
              children: List.generate(_controllers.length, (index) {
                final c = _controllers[index];
                final editing = _isEditing[index];
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: c,
                          readOnly: !editing,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: AppColors.darkBgContainer,
                            hintText: AppStrings.newReason,
                            hintStyle: AppTextStyles.button(
                              color: AppColors.grey600,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppSizes.xxxs,
                              ),
                              borderSide: BorderSide(
                                color: editing
                                    ? AppColors.primaryOrange
                                    : AppColors.skyBlue.withValues(alpha: 0.3),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppSizes.xxxs,
                              ),
                              borderSide:
                                  const BorderSide(color: AppColors.primaryOrange),
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: HugeIcon(
                          icon: editing
                              ? HugeIconsStrokeRounded.tick02
                              : HugeIconsStrokeRounded.pencilEdit02,
                          color: editing ? AppColors.lightGreen : AppColors.white,
                        ),
                        onPressed: () => _toggleEdit(index),
                      ),
                      IconButton(
                        icon: const HugeIcon(
                          icon: HugeIconsStrokeRounded.delete02,
                          color: Colors.red,
                        ),
                        onPressed: () => _deleteReason(index),
                      ),
                    ],
                  ),
                );
              }),
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
              isLoading: _isLoading,
              onPressed: _isLoading ? () {} : _saveChanges,
              label: AppStrings.saveChanges,
              labelStyle: AppTextStyles.button(color: AppColors.black),
              bgColor: AppColors.white,
              radius: AppSizes.xxxs,
            ),
          ],
        ),
      ),
    );
  }
}

