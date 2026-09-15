import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:larnity/src/core/constants/app_size.dart';
import 'package:larnity/src/core/constants/app_strings.dart';
import 'package:larnity/src/core/extensions/extensions.dart';
import 'package:larnity/src/core/extensions/screen_size_extension.dart';
import 'package:larnity/src/core/service/supabase/src/supabase_storage_service.dart';
import 'package:larnity/src/core/theme/app_colors.dart';
import 'package:larnity/src/core/theme/theme.dart';
import 'package:larnity/src/core/ui/widgets/app_button.dart';
import 'package:larnity/src/core/ui/widgets/app_dropdown_datepicker.dart';
import 'package:larnity/src/features/group/data/models/job_model.dart';
import 'package:larnity/src/features/group/presentation/provider/group_provider.dart';
import 'package:larnity/src/features/group/presentation/provider/job_provider.dart';

class AddJob extends ConsumerStatefulWidget {
  const AddJob({super.key});

  @override
  ConsumerState<AddJob> createState() => _AddJobState();
}

class _AddJobState extends ConsumerState<AddJob> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _googleSheetIdController = TextEditingController();
  
  File? _imageFile;
  DateTime? _selectedEndDate;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _submit() async {
    if (_titleController.text.isEmpty || _descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill out all required fields.')),
      );
      return;
    }

    final groupId = ref.read(groupProvider).group?.id;
    if (groupId == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      String imageUrl = '';
      if (_imageFile != null) {
        final storageService = ref.read(storageServiceProvider);
        final storagePath = SupabaseStorageService.generatePath(
          fileName: _imageFile!.path.split('/').last,
          subfolder: 'jobs',
        );
        imageUrl = await storageService.uploadFile(
          bucket: StorageBucket.jobMedia,
          path: storagePath,
          file: _imageFile!,
        );
      }

      final job = JobModel(
        createdAt: DateTime.now(),
        title: _titleController.text,
        description: _descriptionController.text,
        image: imageUrl,
        postingEndDate: _selectedEndDate,
        googleSheetId: _googleSheetIdController.text,
        groupId: groupId,
      );

      ref.read(jobProvider(groupId).notifier).createJob(
        job: job,
        successCallBack: () {
          if (!mounted) return;
          setState(() {
            _isLoading = false;
          });
          context.pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Job posted successfully!')),
          );
        },
        failureCallBack: (error) {
          if (!mounted) return;
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $error')),
          );
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _googleSheetIdController.dispose();
    super.dispose();
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
                    context.pop();
                  },
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(AppStrings.createNewJob, style: AppTextStyles.headline4()),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    AppStrings.createNewJobDesc,
                    style: AppTextStyles.overLine(color: AppColors.skyBlue),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            AppSizes.lg.ph,

            Text(AppStrings.jobTitle, style: AppTextStyles.overLine()),
            AppSizes.xxxs.ph,
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.darkBgContainer,
                hintText: AppStrings.jobTitle,
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
            Text(AppStrings.jobDescription, style: AppTextStyles.overLine()),
            AppSizes.xxxs.ph,
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.darkBgContainer,
                hintText: AppStrings.jobDescription,
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
              maxLines: 5,
              minLines: 2,
            ),
            AppSizes.xs.ph,
            Text(AppStrings.postingEndDate, style: AppTextStyles.overLine()),
            AppSizes.xxxs.ph,
            DatePickerDropdown(
              overlayHeight: 0.3.sh,
              onDateSelected: (date) {
                setState(() {
                  _selectedEndDate = date;
                });
              },
              button: Container(
                padding: const EdgeInsets.all(AppSizes.xxxs),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.skyBlue),
                  color: AppColors.darkBgContainer,
                  borderRadius: BorderRadius.circular(AppSizes.xxxs),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedEndDate != null
                          ? DateFormat('MM/dd/yyyy').format(_selectedEndDate!)
                          : "mm/dd/yyyy",
                    ),
                    HugeIcon(
                      icon: HugeIconsStrokeRounded.calendar03,
                      color: AppColors.white,
                    ),
                  ],
                ),
              ),
            ),
            AppSizes.xs.ph,
            Text(AppStrings.googleSheetId, style: AppTextStyles.overLine()),
            AppSizes.xxxs.ph,
            TextFormField(
              controller: _googleSheetIdController,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.darkBgContainer,
                hintText: AppStrings.googleSheetId,
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
              maxLines: 1,
            ),
            AppSizes.xs.ph,
            GestureDetector(
              onTap: _pickImage,
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
                    ? Center(
                        child: Text(
                          AppStrings.uploadImage,
                          style: AppTextStyles.caption2(
                            color: AppColors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      )
                    : null,
              ),
            ),
            AppSizes.xs.ph,
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : AppButton(
                    onPressed: _submit,
                    label: AppStrings.create,
                    labelStyle: AppTextStyles.bodyText2(color: AppColors.white),
                    bgColor: AppColors.primaryOrange,
                    radius: AppSizes.xxxs,
                  ),
          ],
        ),
      ),
    );
  }
}
