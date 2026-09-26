import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:larnity/src/core/constants/app_size.dart';
import 'package:larnity/src/core/constants/app_strings.dart';
import 'package:larnity/src/core/extensions/extensions.dart';
import 'package:larnity/src/core/extensions/screen_size_extension.dart';
import 'package:larnity/src/core/service/supabase/src/supabase_storage_service.dart';
import 'package:larnity/src/core/theme/app_colors.dart';
import 'package:larnity/src/core/theme/theme.dart';
import 'package:larnity/src/core/ui/widgets/app_button.dart';
import 'package:larnity/src/core/ui/widgets/app_dropdown.dart';
import 'package:larnity/src/core/utils/show_snackbar.dart';
import 'package:larnity/src/features/group/data/models/group_model.dart';
import 'package:larnity/src/features/group/presentation/provider/group_provider.dart';

class GeneralSettingsScreen extends ConsumerStatefulWidget {
  const GeneralSettingsScreen({super.key});

  @override
  ConsumerState<GeneralSettingsScreen> createState() =>
      _GeneralSettingsScreenState();
}

class _GeneralSettingsScreenState extends ConsumerState<GeneralSettingsScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _slugController;
  late final TextEditingController _descController;
  File? _pickedThumbnail;
  bool _isLoading = false;
  GroupPrivacy _privacy = GroupPrivacy.PUBLIC;
  bool _isNameShown = true;
  String? _initializedGroupId;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _slugController = TextEditingController();
    _descController = TextEditingController();
  }

  void _syncWithGroup(GroupModel? group) {
    if (group == null || group.id == _initializedGroupId) return;
    _initializedGroupId = group.id;
    _nameController.text = group.name;
    _slugController.text = group.slug ?? '';
    _descController.text = group.description ?? '';
    _privacy = group.privacy ?? GroupPrivacy.PUBLIC;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _slugController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (picked != null) {
        setState(() {
          _pickedThumbnail = File(picked.path);
        });
      }
    } catch (e) {
      showErrorToast(content: "Failed to pick image: $e");
    }
  }

  Future<void> _saveChanges(GroupModel currentGroup) async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      showErrorToast(content: "Group name cannot be empty");
      return;
    }

    setState(() => _isLoading = true);

    String? thumbnailUrl = currentGroup.thumbnail;
    if (_pickedThumbnail != null) {
      try {
        final storage = ref.read(storageServiceProvider);
        final fileExt = _pickedThumbnail!.path.split('.').last.toLowerCase();
        final path =
            'groups/${currentGroup.id}/thumbnail_${DateTime.now().millisecondsSinceEpoch}.$fileExt';
        thumbnailUrl = await storage.uploadFile(
          bucket: StorageBucket.groupImages,
          path: path,
          file: _pickedThumbnail!,
        );
      } catch (e) {
        showErrorToast(content: "Failed to upload thumbnail: $e");
        setState(() => _isLoading = false);
        return;
      }
    }

    final updatedGroup = currentGroup.copyWith(
      name: name,
      slug: _slugController.text.trim().isEmpty ? null : _slugController.text.trim(),
      description: _descController.text.trim(),
      privacy: _privacy,
      thumbnail: thumbnailUrl,
      updatedAt: DateTime.now(),
    );

    ref.read(groupProvider.notifier).updateGroup(
          group: updatedGroup,
          successCallBack: () {
            if (mounted) {
              setState(() => _isLoading = false);
              showInfoToast(content: "Group settings saved successfully!");
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
    final groupState = ref.watch(groupProvider);
    final group = groupState.group;
    final isOwnerOrAdmin = ref.watch(isGroupAdminOrOwnerProvider);

    if (group == null) {
      return Scaffold(
        backgroundColor: AppColors.darkBg,
        appBar: AppBar(
          backgroundColor: AppColors.darkBg,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.white),
            onPressed: () => Navigator.of(context).pop(),
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

    if (!isOwnerOrAdmin) {
      return Scaffold(
        backgroundColor: AppColors.darkBg,
        appBar: AppBar(
          backgroundColor: AppColors.darkBg,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text("Group Settings", style: TextStyle(color: Colors.white)),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock_outline, size: 64, color: AppColors.primaryOrange),
                AppSizes.sm.ph,
                Text(
                  "Access Restricted",
                  style: AppTextStyles.headline2(color: AppColors.white),
                ),
                AppSizes.xs.ph,
                Text(
                  "Only group owners and admins can modify group settings.",
                  style: AppTextStyles.bodyText1(color: AppColors.skyBlue),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    _syncWithGroup(group);
    final groupUrl = "https://www.larnity.com/group/${group.slug ?? group.id}";

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: AppBar(
        backgroundColor: AppColors.darkBg,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          },
        ),
        title: Text(
          AppStrings.groupSettings,
          style: AppTextStyles.headline3(color: AppColors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.xs),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSizes.xs.ph,
              Text(AppStrings.groupSettingsDesc),
              AppSizes.lg.ph,
              // Group Share Link
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.xxs,
                  vertical: AppSizes.xxxs,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.skyBlue.withValues(alpha: 0.5),
                  ),
                  borderRadius: BorderRadius.circular(AppSizes.xxxs),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        groupUrl,
                        style: AppTextStyles.overLine(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    AppSizes.xs.pw,
                    AppButton(
                      height: 40,
                      isExpanded: false,
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: groupUrl));
                        showInfoToast(content: "Link copied to clipboard!");
                      },
                      label: "Copy Link",
                      labelStyle: AppTextStyles.bodyText2(
                        color: AppColors.white,
                      ),
                      borderColor: AppColors.skyBlue.withValues(alpha: 0.5),
                      bgColor: Colors.transparent,
                      radius: AppSizes.xxxs,
                    ),
                  ],
                ),
              ),
              AppSizes.xxxlg.ph,
              Text(
                AppStrings.groupThumbnail,
                style: AppTextStyles.headline4(color: AppColors.white),
              ),
              AppSizes.xxlg.ph,
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Container(
                      height: 0.22.sh,
                      decoration: BoxDecoration(
                        color: AppColors.darkBgContainer,
                        borderRadius: BorderRadius.circular(AppSizes.xxxs),
                        border: Border.all(
                          color: AppColors.skyBlue.withValues(alpha: 0.3),
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Builder(
                        builder: (_) {
                          if (_pickedThumbnail != null) {
                            return Image.file(_pickedThumbnail!, fit: BoxFit.cover);
                          } else if (group.thumbnail != null &&
                              group.thumbnail!.isNotEmpty) {
                            return Image.network(
                              group.thumbnail!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => const Center(
                                child: Icon(Icons.broken_image, color: Colors.grey),
                              ),
                            );
                          }
                          return const Center(
                            child: Icon(
                              Icons.image_outlined,
                              size: 48,
                              color: Colors.grey,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
              AppSizes.xxlg.ph,
              AppButton(
                onPressed: _pickImage,
                bgColor: AppColors.darkBgContainer,
                label: AppStrings.changeThumbnail,
                labelStyle: AppTextStyles.button(color: AppColors.white),
              ),
              AppSizes.xxxlg.ph,
              Text(
                AppStrings.groupPrivacy,
                style: AppTextStyles.headline5(color: AppColors.white),
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
                        _privacy.name,
                        style: AppTextStyles.bodyText2(color: AppColors.white),
                      ),
                      const Icon(Icons.keyboard_arrow_down, color: AppColors.white),
                    ],
                  ),
                ),
                onItemSelected: (val) {
                  if (val == "PUBLIC") {
                    setState(() => _privacy = GroupPrivacy.PUBLIC);
                  } else if (val == "PRIVATE") {
                    setState(() => _privacy = GroupPrivacy.PRIVATE);
                  }
                },
                items: const [
                  AppDropdownItem(
                    value: "PUBLIC",
                    label: "PUBLIC",
                  ),
                  AppDropdownItem(
                    value: "PRIVATE",
                    label: "PRIVATE",
                  ),
                ],
              ),
              AppSizes.xxlg.ph,
              Text(
                AppStrings.groupName,
                style: AppTextStyles.headline5(color: AppColors.white),
              ),
              AppSizes.xxxs.ph,
              TextFormField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.darkBgContainer,
                  hintText: "Enter group name",
                  hintStyle: AppTextStyles.button(color: AppColors.skyBlue),
                  border: const OutlineInputBorder(borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.xxxs),
                    borderSide: const BorderSide(color: AppColors.skyBlue),
                  ),
                ),
              ),
              AppSizes.lg.ph,
              Text(
                AppStrings.groupSlug,
                style: AppTextStyles.headline5(color: AppColors.white),
              ),
              AppSizes.xxxs.ph,
              TextFormField(
                controller: _slugController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.darkBgContainer,
                  hintText: "unique-group-slug",
                  hintStyle: AppTextStyles.button(color: AppColors.skyBlue),
                  border: const OutlineInputBorder(borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.xxxs),
                    borderSide: const BorderSide(color: AppColors.skyBlue),
                  ),
                ),
              ),
              AppSizes.xxlg.ph,
              Text(
                AppStrings.groupDesc,
                style: AppTextStyles.headline5(color: AppColors.white),
              ),
              AppSizes.xxxs.ph,
              TextFormField(
                controller: _descController,
                maxLines: 4,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.darkBgContainer,
                  hintText: "Describe your community...",
                  hintStyle: AppTextStyles.button(color: AppColors.skyBlue),
                  border: const OutlineInputBorder(borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.xxxs),
                    borderSide: const BorderSide(color: AppColors.skyBlue),
                  ),
                ),
              ),
              AppSizes.xxlg.ph,
              SwitchListTile(
                controlAffinity: ListTileControlAffinity.leading,
                value: _isNameShown,
                onChanged: (val) => setState(() => _isNameShown = val),
                title: Text(
                  AppStrings.groupNameShown,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              AppSizes.lg.ph,
              AppButton(
                onPressed: _isLoading ? () {} : () => _saveChanges(group),
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
                    : Text(
                        AppStrings.saveChanges,
                        style: AppTextStyles.button(color: AppColors.black),
                      ),
              ),
              AppSizes.xlg.ph,
            ],
          ),
        ),
      ),
    );
  }
}
