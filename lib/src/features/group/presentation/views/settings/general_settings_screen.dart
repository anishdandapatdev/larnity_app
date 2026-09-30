import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import 'package:image_picker/image_picker.dart';
import 'package:larnity/src/core/constants/app_size.dart';
import 'package:larnity/src/core/constants/app_strings.dart';
import 'package:larnity/src/core/extensions/extensions.dart';
import 'package:larnity/src/core/extensions/screen_size_extension.dart';
import 'package:larnity/src/core/router/router.dart';
import 'package:larnity/src/core/service/supabase/src/supabase_storage_service.dart';
import 'package:larnity/src/core/theme/app_colors.dart';
import 'package:larnity/src/core/theme/theme.dart';
import 'package:larnity/src/core/ui/widgets/app_button.dart';
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
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _slugController;
  late final TextEditingController _descController;

  File? _pickedThumbnail;
  File? _pickedIcon;

  bool _isLoading = false;
  GroupPrivacy _privacy = GroupPrivacy.PUBLIC;
  bool _isNameShown = true;
  String? _initializedGroupId;

  static final RegExp _slugRegex = RegExp(r'^[a-z0-9-]+$');

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

    // Properly initialize from group landing settings
    final landing = group.landingSettings;
    if (landing != null) {
      if (landing.containsKey('isGroupNameShow')) {
        _isNameShown = landing['isGroupNameShow'] == true;
      } else if (landing.containsKey('groupNameShown')) {
        _isNameShown = landing['groupNameShown'] == true;
      } else if (landing.containsKey('showGroupName')) {
        _isNameShown = landing['showGroupName'] == true;
      } else {
        _isNameShown = true;
      }
    } else {
      _isNameShown = true;
    }

    _pickedThumbnail = null;
    _pickedIcon = null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _slugController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _navigateBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.goNamed(Routes.group);
    }
  }

  Future<void> _pickThumbnail() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (picked != null) {
        setState(() {
          _pickedThumbnail = File(picked.path);
        });
      }
    } catch (e) {
      showErrorToast(content: "Failed to select thumbnail: $e");
    }
  }

  Future<void> _pickIcon() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (picked != null) {
        setState(() {
          _pickedIcon = File(picked.path);
        });
      }
    } catch (e) {
      showErrorToast(content: "Failed to select icon: $e");
    }
  }

  void _generateSlugFromName() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      showErrorToast(content: "Enter a group name first to generate a slug");
      return;
    }
    final slug = name
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
        .trim()
        .replaceAll(RegExp(r'\s+'), '-');

    setState(() {
      _slugController.text = slug;
    });
  }

  Future<void> _saveChanges(GroupModel currentGroup) async {
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final name = _nameController.text.trim();
    final rawSlug = _slugController.text.trim().toLowerCase();

    setState(() => _isLoading = true);

    try {
      String? thumbnailUrl = currentGroup.thumbnail;
      String? iconUrl = currentGroup.icon;
      final storage = ref.read(storageServiceProvider);

      // 1. Upload Thumbnail if changed
      if (_pickedThumbnail != null) {
        try {
          final fileExt = _pickedThumbnail!.path.split('.').last.toLowerCase();
          final path =
              'groups/${currentGroup.id}/thumbnail_${DateTime.now().millisecondsSinceEpoch}.$fileExt';
          thumbnailUrl = await storage.uploadFile(
            bucket: StorageBucket.groupImages,
            path: path,
            file: _pickedThumbnail!,
          );
        } catch (e) {
          if (mounted) setState(() => _isLoading = false);
          showErrorToast(content: "Failed to upload thumbnail: $e");
          return;
        }
      }

      // 2. Upload Icon if changed
      if (_pickedIcon != null) {
        try {
          final fileExt = _pickedIcon!.path.split('.').last.toLowerCase();
          final path =
              'groups/${currentGroup.id}/icon_${DateTime.now().millisecondsSinceEpoch}.$fileExt';
          iconUrl = await storage.uploadFile(
            bucket: StorageBucket.groupImages,
            path: path,
            file: _pickedIcon!,
          );
        } catch (e) {
          if (mounted) setState(() => _isLoading = false);
          showErrorToast(content: "Failed to upload icon: $e");
          return;
        }
      }

      // 3. Prepare updated landingSettings
      final updatedLandingSettings =
          Map<String, dynamic>.from(currentGroup.landingSettings ?? {});
      updatedLandingSettings['isGroupNameShow'] = _isNameShown;
      updatedLandingSettings['groupNameShown'] = _isNameShown;
      updatedLandingSettings['showGroupName'] = _isNameShown;

      // 4. Build updated group model
      final updatedGroup = currentGroup.copyWith(
        name: name,
        slug: rawSlug.isEmpty ? null : rawSlug,
        description: _descController.text.trim(),
        privacy: _privacy,
        thumbnail: thumbnailUrl,
        icon: iconUrl,
        landingSettings: updatedLandingSettings,
        updatedAt: DateTime.now().toUtc(),
      );

      // 5. Save to backend
      await ref.read(groupProvider.notifier).updateGroup(
            group: updatedGroup,
            successCallBack: () {
              if (mounted) {
                setState(() {
                  _isLoading = false;
                  _pickedThumbnail = null;
                  _pickedIcon = null;
                });
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
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        showErrorToast(content: "Failed to save: $e");
      }
    }
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
            onPressed: _navigateBack,
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
            onPressed: _navigateBack,
          ),
          title: Text(
            AppStrings.groupSettings,
            style: const TextStyle(color: Colors.white),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.lock_outline,
                  size: 64,
                  color: AppColors.primaryOrange,
                ),
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
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: _navigateBack,
        ),
        title: Text(
          AppStrings.groupSettings,
          style: AppTextStyles.headline3(color: AppColors.white),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSizes.xs.ph,
                Text(
                  AppStrings.groupSettingsDesc,
                  style: AppTextStyles.overLine(
                    color: AppColors.creamWhite.withValues(alpha: 0.8),
                  ),
                ),
                AppSizes.lg.ph,

                // Group Share Link Card
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.darkBgContainer,
                    border: Border.all(color: AppColors.borderBrown),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const HugeIcon(
                        icon: HugeIconsStrokeRounded.link01,
                        color: AppColors.primaryOrange,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          groupUrl,
                          style: AppTextStyles.subtitle2(
                            color: AppColors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: groupUrl));
                          showInfoToast(content: "Link copied to clipboard!");
                        },
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryOrange.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: AppColors.primaryOrange.withValues(alpha: 0.5),
                            ),
                          ),
                          child: Text(
                            "Copy Link",
                            style: AppTextStyles.caption2(
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                AppSizes.lg.ph,

                // Media Section: Thumbnail and Icon
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.darkBgContainer,
                    border: Border.all(color: AppColors.borderBrown),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Thumbnail Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppStrings.groupThumbnail,
                            style: AppTextStyles.headline5(
                              color: AppColors.white,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: _pickThumbnail,
                            icon: const Icon(
                              Icons.edit_outlined,
                              size: 16,
                              color: AppColors.primaryOrange,
                            ),
                            label: Text(
                              AppStrings.changeThumbnail,
                              style: AppTextStyles.caption2(
                                color: AppColors.primaryOrange,
                              ),
                            ),
                          ),
                        ],
                      ),

                      AppSizes.xs.ph,

                      // Thumbnail Preview Container
                      Container(
                        height: 0.22.sh,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.borderBrown),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: _pickedThumbnail != null
                            ? Image.file(
                                _pickedThumbnail!,
                                fit: BoxFit.cover,
                              )
                            : (group.thumbnail != null &&
                                    group.thumbnail!.isNotEmpty)
                                ? Image.network(
                                    group.thumbnail!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => const Center(
                                      child: Icon(
                                        Icons.broken_image,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  )
                                : const Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.image_outlined,
                                          size: 40,
                                          color: Colors.grey,
                                        ),
                                        SizedBox(height: 6),
                                        Text(
                                          "No thumbnail uploaded (16:9 recommended)",
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                      ),

                      AppSizes.lg.ph,
                      const Divider(color: AppColors.borderBrown),
                      AppSizes.sm.ph,

                      // Icon Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppStrings.groupIcon,
                            style: AppTextStyles.headline5(
                              color: AppColors.white,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: _pickIcon,
                            icon: const Icon(
                              Icons.edit_outlined,
                              size: 16,
                              color: AppColors.primaryOrange,
                            ),
                            label: Text(
                              AppStrings.changeIcon,
                              style: AppTextStyles.caption2(
                                color: AppColors.primaryOrange,
                              ),
                            ),
                          ),
                        ],
                      ),

                      AppSizes.xs.ph,

                      // Icon Preview Row
                      Row(
                        children: [
                          Container(
                            height: 76,
                            width: 76,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black.withValues(alpha: 0.4),
                              border: Border.all(
                                color: AppColors.primaryOrange,
                                width: 1.5,
                              ),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: _pickedIcon != null
                                ? Image.file(
                                    _pickedIcon!,
                                    fit: BoxFit.cover,
                                  )
                                : (group.icon != null &&
                                        group.icon!.isNotEmpty)
                                    ? Image.network(
                                        group.icon!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) =>
                                            const Center(
                                          child: Icon(
                                            Icons.groups,
                                            color: Colors.white,
                                            size: 36,
                                          ),
                                        ),
                                      )
                                    : const Center(
                                        child: Icon(
                                          Icons.groups,
                                          color: Colors.grey,
                                          size: 36,
                                        ),
                                      ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              "This icon represents your group across chats, cards, and member lists. Square format recommended.",
                              style: AppTextStyles.caption2(
                                color:
                                    AppColors.creamWhite.withValues(alpha: 0.7),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                AppSizes.lg.ph,

                // Group Privacy Selector
                Text(
                  AppStrings.groupPrivacy,
                  style: AppTextStyles.headline5(color: AppColors.white),
                ),
                AppSizes.xxs.ph,
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _privacy = GroupPrivacy.PUBLIC),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _privacy == GroupPrivacy.PUBLIC
                                ? AppColors.primaryOrange.withValues(alpha: 0.15)
                                : AppColors.darkBgContainer,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _privacy == GroupPrivacy.PUBLIC
                                  ? AppColors.primaryOrange
                                  : AppColors.borderBrown,
                              width: _privacy == GroupPrivacy.PUBLIC ? 1.5 : 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.public,
                                    size: 18,
                                    color: _privacy == GroupPrivacy.PUBLIC
                                        ? AppColors.primaryOrange
                                        : AppColors.creamWhite,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    "PUBLIC",
                                    style: AppTextStyles.bodyText2(
                                      color: _privacy == GroupPrivacy.PUBLIC
                                          ? AppColors.primaryOrange
                                          : AppColors.white,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Visible on Explore. Anyone can discover and join.",
                                style: AppTextStyles.caption2(
                                  color: AppColors.creamWhite.withValues(
                                    alpha: 0.7,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _privacy = GroupPrivacy.PRIVATE),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _privacy == GroupPrivacy.PRIVATE
                                ? AppColors.primaryOrange.withValues(alpha: 0.15)
                                : AppColors.darkBgContainer,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _privacy == GroupPrivacy.PRIVATE
                                  ? AppColors.primaryOrange
                                  : AppColors.borderBrown,
                              width: _privacy == GroupPrivacy.PRIVATE ? 1.5 : 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.lock_outline,
                                    size: 18,
                                    color: _privacy == GroupPrivacy.PRIVATE
                                        ? AppColors.primaryOrange
                                        : AppColors.creamWhite,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    "PRIVATE",
                                    style: AppTextStyles.bodyText2(
                                      color: _privacy == GroupPrivacy.PRIVATE
                                          ? AppColors.primaryOrange
                                          : AppColors.white,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Hidden from search. Accessible via invite or request.",
                                style: AppTextStyles.caption2(
                                  color: AppColors.creamWhite.withValues(
                                    alpha: 0.7,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                AppSizes.lg.ph,

                // Group Name Field
                Text(
                  AppStrings.groupName,
                  style: AppTextStyles.headline5(color: AppColors.white),
                ),
                AppSizes.xxxs.ph,
                TextFormField(
                  controller: _nameController,
                  style: const TextStyle(color: Colors.white),
                  validator: (val) {
                    final trimmed = val?.trim() ?? '';
                    if (trimmed.isEmpty) {
                      return 'Group name cannot be empty';
                    }
                    if (trimmed.length < 3) {
                      return 'Group name must be at least 3 characters';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.darkBgContainer,
                    hintText: "Enter group name",
                    hintStyle: AppTextStyles.button(color: AppColors.skyBlue),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.borderBrown),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.borderBrown),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: AppColors.primaryOrange,
                        width: 1.5,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.red),
                    ),
                  ),
                ),

                AppSizes.lg.ph,

                // Group Slug Field with Generator
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppStrings.groupSlug,
                      style: AppTextStyles.headline5(color: AppColors.white),
                    ),
                    TextButton(
                      onPressed: _generateSlugFromName,
                      child: Text(
                        "Generate from Name",
                        style: AppTextStyles.caption2(
                          color: AppColors.primaryOrange,
                        ),
                      ),
                    ),
                  ],
                ),
                AppSizes.xxxs.ph,
                TextFormField(
                  controller: _slugController,
                  style: const TextStyle(color: Colors.white),
                  validator: (val) {
                    final trimmed = val?.trim() ?? '';
                    if (trimmed.isNotEmpty && !_slugRegex.hasMatch(trimmed)) {
                      return 'Only lowercase letters, numbers, and hyphens allowed';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.darkBgContainer,
                    prefixText: "larnity.com/group/ ",
                    prefixStyle: const TextStyle(
                      color: AppColors.skyBlue,
                      fontSize: 14,
                    ),
                    hintText: "unique-slug",
                    hintStyle: AppTextStyles.button(color: AppColors.skyBlue),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.borderBrown),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.borderBrown),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: AppColors.primaryOrange,
                        width: 1.5,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.red),
                    ),
                  ),
                ),

                AppSizes.lg.ph,

                // Group Description Field
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
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.borderBrown),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.borderBrown),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: AppColors.primaryOrange,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),

                AppSizes.lg.ph,

                // Show Group Name Switch (Persisted to Landing Settings)
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.darkBgContainer,
                    border: Border.all(color: AppColors.borderBrown),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SwitchListTile(
                    activeTrackColor: AppColors.primaryOrange,
                    controlAffinity: ListTileControlAffinity.trailing,
                    value: _isNameShown,
                    onChanged: (val) => setState(() => _isNameShown = val),
                    title: Text(
                      AppStrings.groupNameShown,
                      style: AppTextStyles.subtitle2(color: Colors.white),
                    ),
                    subtitle: Text(
                      "Display the community name prominently on your group's landing page.",
                      style: AppTextStyles.caption2(
                        color: AppColors.creamWhite.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                ),

                AppSizes.xlg.ph,

                // Save Changes Button
                AppButton(
                  isLoading: _isLoading,
                  onPressed: _isLoading ? null : () => _saveChanges(group),
                  bgColor: AppColors.primaryOrange,
                  radius: 8,
                  label: AppStrings.saveChanges,
                  labelStyle: AppTextStyles.button(color: AppColors.black),
                ),

                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
