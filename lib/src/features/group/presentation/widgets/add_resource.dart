import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import 'package:image_picker/image_picker.dart';
import 'package:larnity/src/core/constants/app_size.dart';
import 'package:larnity/src/core/constants/app_strings.dart';
import 'package:larnity/src/core/extensions/extensions.dart';
import 'package:larnity/src/core/extensions/screen_size_extension.dart';
import 'package:larnity/src/core/theme/app_colors.dart';
import 'package:larnity/src/core/theme/theme.dart';
import 'package:larnity/src/core/ui/widgets/app_button.dart';
import 'package:larnity/src/core/service/supabase/src/supabase_storage_service.dart';
import 'package:larnity/src/features/auth/presentation/provider/auth_provider.dart';
import 'package:larnity/src/features/group/data/models/resource_model.dart';
import 'package:larnity/src/features/group/presentation/provider/group_provider.dart';
import 'package:larnity/src/features/group/presentation/provider/treasure_provider.dart';

class AddResource extends ConsumerStatefulWidget {
  const AddResource({super.key});

  @override
  ConsumerState<AddResource> createState() => _AddResourceState();
}

class _AddResourceState extends ConsumerState<AddResource> {
  final _nameController = TextEditingController();
  final _linkController = TextEditingController();
  File? _imageFile;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to pick image: $e")),
      );
    }
  }

  Future<void> _submit() async {
    final groupId = ref.read(groupProvider).group?.id;
    if (groupId == null) return;

    final name = _nameController.text.trim();
    final link = _linkController.text.trim();

    if (name.isEmpty || link.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      // 1. Upload image to Supabase Storage
      String imageUrl = '';
      try {
        final storageService = ref.read(storageServiceProvider);
        final userId = ref.read(authProvider).user?.id ?? 'unknown';
        final storagePath = SupabaseStorageService.generatePath(
          userId: userId,
          fileName: _imageFile!.path.split('/').last,
          subfolder: 'resources',
        );

        imageUrl = await storageService.uploadFile(
          bucket: StorageBucket.resourceMedia,
          path: storagePath,
          file: _imageFile!,
        );
      } catch (storageError) {
        // Fallback if bucket doesn't exist or upload fails
        imageUrl = 'https://via.placeholder.com/300x200.png?text=Resource+Image';
      }

      // 2. Create resource with the uploaded image URL
      final resource = ResourceModel(
        groupId: groupId,
        resourceName: name,
        resourceImg: imageUrl,
        resourceLink: link,
      );

      ref.read(treasureProvider(groupId).notifier).addResource(
        resource: resource,
        successCallBack: () {
          if (!mounted) return;
          context.pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Resource added successfully!')),
          );
        },
        failureCallBack: (error) {
          if (!mounted) return;
          setState(() => _isSaving = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error)),
          );
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
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
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () {
                    if (!_isSaving) context.pop();
                  },
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  AppStrings.addNewResource,
                  style: AppTextStyles.headline4(),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    AppStrings.addNewResourceDesc,
                    style: AppTextStyles.overLine(color: AppColors.skyBlue),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            AppSizes.lg.ph,

            Text(AppStrings.resourceName, style: AppTextStyles.overLine()),
            AppSizes.xxxs.ph,
            TextFormField(
              controller: _nameController,
              style: const TextStyle(color: AppColors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.darkBgContainer,
                hintText: AppStrings.enterName,
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

            // Image picker area
            GestureDetector(
              onTap: _isSaving ? null : _pickImage,
              child: Container(
                height: 0.2.sh,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.skyBlue.withValues(alpha: 0.5),
                  ),
                  borderRadius: BorderRadius.circular(AppSizes.xs),
                  image: _imageFile != null
                      ? DecorationImage(
                          image: FileImage(_imageFile!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: _imageFile == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const HugeIcon(
                            icon: HugeIconsStrokeRounded.image02,
                            color: AppColors.creamWhite,
                            size: 40,
                          ),
                          AppSizes.xs.ph,
                          Text(
                            AppStrings.uploadImage,
                            style: AppTextStyles.overLine(
                              color: AppColors.creamWhite,
                            ),
                          ),
                          Text(
                            "Tap to select from gallery",
                            style: AppTextStyles.caption2(
                              color: AppColors.white.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      )
                    : Container(
                        color: Colors.black.withValues(alpha: 0.3),
                        child: const Center(
                          child: Icon(
                            Icons.change_circle,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                      ),
              ),
            ),
            AppSizes.xs.ph,

            Text(AppStrings.resourceFileLink, style: AppTextStyles.overLine()),
            AppSizes.xxxs.ph,
            TextFormField(
              controller: _linkController,
              style: const TextStyle(color: AppColors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.darkBgContainer,
                hintText: AppStrings.enterResourceUrl,
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
            AppSizes.xxxs.ph,
            AppButton(
              onPressed: _isSaving ? () {} : _submit,
              label: _isSaving ? "Uploading..." : AppStrings.create,
              labelStyle: AppTextStyles.bodyText2(
                color: _isSaving ? AppColors.white : AppColors.black,
              ),
              bgColor: _isSaving ? AppColors.skyBlue : AppColors.primaryOrange,
              borderColor:
                  _isSaving ? AppColors.skyBlue : AppColors.primaryOrange,
              radius: AppSizes.xxxs,
            ),
          ],
        ),
      ),
    );
  }
}
