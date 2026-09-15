import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
import 'package:larnity/src/core/ui/widgets/app_dropdown.dart';
import 'package:larnity/src/core/ui/widgets/app_dropdown_datepicker.dart';
import 'package:larnity/src/core/ui/widgets/app_dropdown_timepicker.dart';
import 'package:larnity/src/core/ui/widgets/dialog_header.dart';
import 'package:larnity/src/features/group/data/models/live_class_model.dart';
import 'package:larnity/src/features/group/presentation/provider/live_class_provider.dart';
import 'package:larnity/src/core/service/supabase/src/supabase_storage_service.dart';
import 'package:larnity/src/features/auth/presentation/provider/auth_provider.dart';

class AddClass extends ConsumerStatefulWidget {
  final String groupId;
  const AddClass({super.key, required this.groupId});

  @override
  ConsumerState<AddClass> createState() => _AddClassState();
}

class _AddClassState extends ConsumerState<AddClass> {
  final _titleController = TextEditingController();
  final _linkController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String _selectedLocationType = 'zoom';
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  File? _imageFile;
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _linkController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
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

  Future<void> _saveClass() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final link = _linkController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Title is required")),
      );
      return;
    }

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Date is required")),
      );
      return;
    }

    if (_selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Time is required")),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      // 1. Combine Date and Time
      final startAt = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );
      final endAt = startAt.add(const Duration(hours: 1)); // Default end time: 1 hour later

      // 2. Upload cover image if picked
      String? imageUrl;
      if (_imageFile != null) {
        try {
          final storageService = ref.read(storageServiceProvider);
          final userId = ref.read(authProvider).user?.id ?? "unknown";
          final storagePath = SupabaseStorageService.generatePath(
            userId: userId,
            fileName: _imageFile!.path.split('/').last,
            subfolder: 'classes',
          );

          imageUrl = await storageService.uploadFile(
            bucket: StorageBucket.courseMedia,
            path: storagePath,
            file: _imageFile!,
          );
        } catch (storageError) {
          // Proceed resiliently if bucket is missing or upload fails
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Warning: Storage bucket not found. Adding class without cover image."),
                duration: Duration(seconds: 4),
              ),
            );
          }
        }
      }

      // 3. Construct Model
      final liveClass = LiveClassModel(
        groupId: widget.groupId,
        title: title,
        description: description,
        image: imageUrl,
        startAt: startAt,
        endAt: endAt,
        meetingUrl: link,
        isLive: true,
      );

      // 4. Call Provider
      await ref.read(liveClassProvider(widget.groupId).notifier).createLiveClass(
        liveClass: liveClass,
        successCallBack: () {
          if (!mounted) return;
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Live Class added successfully")),
          );
        },
        failureCallBack: (error) {
          if (!mounted) return;
          setState(() => _isSaving = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to add live class: $error")),
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
            DialogHeader(
              title: AppStrings.addClass,
              description: AppStrings.addEventDesc,
            ),

            Container(
              padding: const EdgeInsets.all(AppSizes.xs),
              decoration: BoxDecoration(
                color: AppColors.iconColor,
                borderRadius: BorderRadius.circular(AppSizes.xxxs),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppSizes.xs.ph,
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppSizes.xxxs),
                        ),
                        child: const Center(
                          child: HugeIcon(
                            icon: HugeIconsStrokeRounded.calendar04,
                            color: AppColors.primaryOrange,
                          ),
                        ),
                      ),
                      AppSizes.xs.pw,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.eventDetails,
                              style: AppTextStyles.headline2(
                                color: AppColors.white,
                              ),
                            ),
                            Text(
                              AppStrings.eventDetailsDesc,
                              style: AppTextStyles.overLine(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  AppSizes.xs.ph,
                  Text(AppStrings.title, style: AppTextStyles.overLine()),
                  AppSizes.xxxs.ph,
                  TextFormField(
                    controller: _titleController,
                    style: const TextStyle(color: AppColors.white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.darkBgContainer,
                      hintText: AppStrings.enterTitle,
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
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppSizes.xs.ph,
                            Text(
                              AppStrings.date,
                              style: AppTextStyles.overLine(),
                            ),
                            AppSizes.xxxs.ph,
                            Row(
                              children: [
                                Expanded(
                                  child: DatePickerDropdown(
                                    overlayHeight: 300,
                                    selectedDate: _selectedDate,
                                    onDateSelected: (date) {
                                      setState(() {
                                        _selectedDate = date;
                                      });
                                    },
                                    button: Container(
                                      padding: const EdgeInsets.symmetric(vertical: AppSizes.xxs, horizontal: AppSizes.xxs),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: AppColors.skyBlue.withValues(alpha: 0.5)),
                                        borderRadius: BorderRadius.circular(
                                          AppSizes.xxxs,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            _selectedDate == null 
                                              ? "mm/dd/yyyy" 
                                              : "${_selectedDate!.month.toString().padLeft(2, '0')}/${_selectedDate!.day.toString().padLeft(2, '0')}/${_selectedDate!.year}",
                                            style: const TextStyle(color: AppColors.white),
                                          ),
                                          const HugeIcon(
                                            icon: HugeIconsStrokeRounded.calendar03,
                                            color: AppColors.white,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      AppSizes.xs.pw,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppSizes.xs.ph,
                            Text(
                              AppStrings.time,
                              style: AppTextStyles.overLine(),
                            ),
                            AppSizes.xxxs.ph,
                            Row(
                              children: [
                                Expanded(
                                  child: TimePickerDropdown(
                                    overlayAlignment: Alignment.centerRight,
                                    selectedTime: _selectedTime,
                                    onTimeSelected: (time) {
                                      setState(() {
                                        _selectedTime = time;
                                      });
                                    },
                                    button: Container(
                                      padding: const EdgeInsets.symmetric(vertical: AppSizes.xxs, horizontal: AppSizes.xxs),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: AppColors.skyBlue.withValues(alpha: 0.5)),
                                        borderRadius: BorderRadius.circular(
                                          AppSizes.xxxs,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            _selectedTime == null 
                                              ? "--:--:--" 
                                              : "${_selectedTime!.hourOfPeriod == 0 ? 12 : _selectedTime!.hourOfPeriod}:${_selectedTime!.minute.toString().padLeft(2, '0')} ${_selectedTime!.period == DayPeriod.am ? 'AM' : 'PM'}",
                                            style: const TextStyle(color: AppColors.white),
                                          ),
                                          const HugeIcon(
                                            icon: HugeIconsStrokeRounded.clock01,
                                            color: AppColors.white,
                                          ),
                                        ],
                                      ),
                                    ),
                                    selectedTimeDecoration: BoxDecoration(
                                      border: Border.all(
                                        color: AppColors.white,
                                      ),
                                      color: AppColors.skyBlue,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            AppSizes.xs.ph,
            Container(
              padding: const EdgeInsets.all(AppSizes.xs),
              decoration: BoxDecoration(
                color: AppColors.iconColor,
                borderRadius: BorderRadius.circular(AppSizes.xxxs),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppSizes.xxxs),
                        ),
                        child: const Center(
                          child: HugeIcon(
                            icon: HugeIconsStrokeRounded.location06,
                            color: AppColors.primaryOrange,
                          ),
                        ),
                      ),
                      AppSizes.xs.pw,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.locationAndLink,
                              style: AppTextStyles.headline2(
                                color: AppColors.white,
                              ),
                            ),
                            Text(
                              AppStrings.locationAndLinkDesc,
                              style: AppTextStyles.overLine(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  AppSizes.xs.ph,
                  Text(
                    AppStrings.locationType,
                    style: AppTextStyles.overLine(),
                  ),
                  AppSizes.xxxs.ph,
                  AppDropdown<String>(
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
                            _selectedLocationType.toUpperCase(),
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
                    selectedValue: _selectedLocationType,
                    selectedItemForegroundColor: AppColors.primaryOrange,
                    onItemSelected: (value) {
                      setState(() {
                        _selectedLocationType = value;
                      });
                    },
                    items: [
                      AppDropdownItem(value: "zoom", child: Text("Zoom", style: AppTextStyles.bodyText2(color: AppColors.white))),
                      AppDropdownItem(value: "meet", child: Text("Meet", style: AppTextStyles.bodyText2(color: AppColors.white))),
                      AppDropdownItem(value: "address", child: Text("Address", style: AppTextStyles.bodyText2(color: AppColors.white))),
                      AppDropdownItem(value: "link", child: Text("Link", style: AppTextStyles.bodyText2(color: AppColors.white))),
                    ],
                  ),
                  AppSizes.xs.ph,
                  Text(
                    _selectedLocationType == 'address' ? "Address" : AppStrings.eventLink,
                    style: AppTextStyles.overLine(),
                  ),
                  AppSizes.xxxs.ph,
                  TextFormField(
                    controller: _linkController,
                    style: const TextStyle(color: AppColors.white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.darkBgContainer,
                      hintText: _selectedLocationType == 'address' ? "Enter address" : AppStrings.enterLink,
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
                ],
              ),
            ),
            AppSizes.xs.ph,

            Container(
              padding: const EdgeInsets.all(AppSizes.xs),
              decoration: BoxDecoration(
                color: AppColors.iconColor,
                borderRadius: BorderRadius.circular(AppSizes.xxxs),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppSizes.xxxs),
                        ),
                        child: const Center(
                          child: HugeIcon(
                            icon: HugeIconsStrokeRounded.file02,
                            color: AppColors.primaryOrange,
                          ),
                        ),
                      ),
                      AppSizes.xs.pw,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.description,
                              style: AppTextStyles.headline2(
                                color: AppColors.white,
                              ),
                            ),
                            Text(
                              AppStrings.descriptionDesc,
                              style: AppTextStyles.overLine(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  AppSizes.xs.ph,
                  Text(AppStrings.description, style: AppTextStyles.overLine()),
                  AppSizes.xxxs.ph,
                  TextFormField(
                    controller: _descriptionController,
                    style: const TextStyle(color: AppColors.white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.darkBgContainer,
                      hintText: "Enter class description",
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
                    minLines: 2,
                    maxLines: 5,
                  ),
                ],
              ),
            ),
            AppSizes.xs.ph,

            Container(
              padding: const EdgeInsets.all(AppSizes.xs),
              decoration: BoxDecoration(
                color: AppColors.iconColor,
                borderRadius: BorderRadius.circular(AppSizes.xxxs),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppSizes.xxxs),
                        ),
                        child: const Center(
                          child: HugeIcon(
                            icon: HugeIconsStrokeRounded.image01,
                            color: AppColors.primaryOrange,
                          ),
                        ),
                      ),
                      AppSizes.xs.pw,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.eventCoverImage,
                              style: AppTextStyles.headline2(
                                color: AppColors.white,
                              ),
                            ),
                            Text(
                              AppStrings.eventCoverImageDesc,
                              style: AppTextStyles.overLine(),
                            ),
                          ],
                        ),
                      ),
                    ],
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
                                  AppStrings.clickToUpload,
                                  style: AppTextStyles.overLine(
                                    color: AppColors.creamWhite,
                                  ),
                                ),
                                Text(
                                  AppStrings.max400x400,
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
                  AppButton(
                    onPressed: _isSaving ? () {} : _saveClass,
                    label: _isSaving ? "Saving..." : AppStrings.addClass,
                    labelStyle: AppTextStyles.bodyText2(color: AppColors.black),
                    bgColor: AppColors.primaryOrange,
                    radius: AppSizes.xxxs,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
