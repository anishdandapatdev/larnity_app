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
import 'package:larnity/src/core/service/supabase/src/supabase_storage_service.dart';
import 'package:larnity/src/core/theme/app_colors.dart';
import 'package:larnity/src/core/theme/theme.dart';
import 'package:larnity/src/core/ui/widgets/app_button.dart';
import 'package:larnity/src/core/utils/show_snackbar.dart';
import 'package:larnity/src/features/group/data/models/challenge_model.dart';
import 'package:larnity/src/features/group/presentation/provider/challenge_provider.dart';
import 'package:larnity/src/features/group/presentation/provider/group_provider.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class CreateChallenge extends ConsumerStatefulWidget {
  const CreateChallenge({super.key});

  @override
  ConsumerState<CreateChallenge> createState() => _CreateChallengeState();
}

class _CreateChallengeState extends ConsumerState<CreateChallenge> {
  late final TextEditingController _titleController;
  late final TextEditingController _descController;
  late final TextEditingController _maxParticipantsController;
  late final TextEditingController _firstPrizeController;
  late final TextEditingController _secondPrizeController;
  late final TextEditingController _thirdPrizeController;
  late final TextEditingController _priceController;

  bool _isPaid = false;
  DateTime? _startDate;
  DateTime? _endDate;
  File? _pickedImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descController = TextEditingController();
    _maxParticipantsController = TextEditingController(text: "100");
    _firstPrizeController = TextEditingController();
    _secondPrizeController = TextEditingController();
    _thirdPrizeController = TextEditingController();
    _priceController = TextEditingController(text: "0");
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _maxParticipantsController.dispose();
    _firstPrizeController.dispose();
    _secondPrizeController.dispose();
    _thirdPrizeController.dispose();
    _priceController.dispose();
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
        setState(() => _pickedImage = File(picked.path));
      }
    } catch (e) {
      showErrorToast(content: "Failed to pick image: $e");
    }
  }

  Future<void> _submitChallenge() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      showErrorToast(content: "Please enter a challenge title");
      return;
    }

    final group = ref.read(groupProvider).group;
    if (group == null || group.id == null) {
      showErrorToast(content: "No active group found");
      return;
    }

    setState(() => _isLoading = true);

    try {
      String? imageUrl;
      if (_pickedImage != null) {
        final storage = ref.read(storageServiceProvider);
        final path =
            'challenges/${group.id}/${DateTime.now().millisecondsSinceEpoch}.jpg';
        imageUrl = await storage.uploadFile(
          bucket: StorageBucket.groupImages,
          path: path,
          file: _pickedImage!,
        );
      }

      final prizeText = [
        if (_firstPrizeController.text.trim().isNotEmpty)
          "1st: ${_firstPrizeController.text.trim()}",
        if (_secondPrizeController.text.trim().isNotEmpty)
          "2nd: ${_secondPrizeController.text.trim()}",
        if (_thirdPrizeController.text.trim().isNotEmpty)
          "3rd: ${_thirdPrizeController.text.trim()}",
      ].join(", ");

      final maxPart = int.tryParse(_maxParticipantsController.text.trim());
      final price = double.tryParse(_priceController.text.trim()) ?? 0.0;

      final newChallenge = ChallengeModel(
        groupId: group.id!,
        title: title,
        description: _descController.text.trim().isNotEmpty
            ? _descController.text.trim()
            : null,
        startDate: _startDate ?? DateTime.now(),
        endDate: _endDate ?? DateTime.now().add(const Duration(days: 7)),
        maxParticipants: maxPart,
        prize: prizeText.isNotEmpty ? prizeText : null,
        type: _isPaid ? "PAID" : "FREE",
        price: _isPaid ? price : 0.0,
        image: imageUrl,
        status: "REGISTRATION_OPEN",
        isActive: true,
      );

      await ref.read(challengeProvider(group.id!).notifier).createChallenge(
            challenge: newChallenge,
            successCallBack: () {
              if (mounted) {
                setState(() => _isLoading = false);
                showSuccessToast(content: "Challenge created successfully!");
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
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        showErrorToast(content: "Failed to create challenge: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.createNewChallenge,
                style: AppTextStyles.headline4(color: AppColors.white),
              ),
              IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.close, color: Colors.white),
              ),
            ],
          ),
          Text(
            AppStrings.createNewChallengeDesc,
            style: AppTextStyles.overLine(color: AppColors.creamWhite),
          ),
          AppSizes.md.ph,
          Text(AppStrings.challengeTitle, style: AppTextStyles.overLine(color: AppColors.white)),
          AppSizes.xxxs.ph,
          TextFormField(
            controller: _titleController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.darkBgContainer,
              hintText: AppStrings.addYourChallengeTitle,
              hintStyle: AppTextStyles.button(color: AppColors.grey600),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.xxxs),
                borderSide: BorderSide(
                  color: AppColors.skyBlue.withValues(alpha: 0.4),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.xxxs),
                borderSide: const BorderSide(color: AppColors.skyBlue),
              ),
            ),
          ),
          AppSizes.xs.ph,
          Text(AppStrings.challengeDesc, style: AppTextStyles.overLine(color: AppColors.white)),
          AppSizes.xxxs.ph,
          TextFormField(
            controller: _descController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.darkBgContainer,
              hintText: AppStrings.addDesc,
              hintStyle: AppTextStyles.button(color: AppColors.grey600),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.xxxs),
                borderSide: BorderSide(
                  color: AppColors.skyBlue.withValues(alpha: 0.4),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.xxxs),
                borderSide: const BorderSide(color: AppColors.skyBlue),
              ),
            ),
            minLines: 2,
            maxLines: 4,
          ),
          AppSizes.xs.ph,
          Text(AppStrings.chooseDateRange, style: AppTextStyles.overLine(color: AppColors.white)),
          AppSizes.xxxs.ph,
          Container(
            height: 220,
            decoration: BoxDecoration(
              color: AppColors.darkBgContainer,
              borderRadius: BorderRadius.circular(AppSizes.xxxs),
              border: Border.all(color: AppColors.skyBlue.withValues(alpha: 0.3)),
            ),
            child: SfDateRangePicker(
              selectionMode: DateRangePickerSelectionMode.range,
              startRangeSelectionColor: AppColors.primaryOrange,
              endRangeSelectionColor: AppColors.primaryOrange,
              rangeSelectionColor: AppColors.primaryOrange.withValues(alpha: 0.3),
              monthViewSettings: const DateRangePickerMonthViewSettings(
                viewHeaderStyle: DateRangePickerViewHeaderStyle(
                  textStyle: TextStyle(color: Colors.white70),
                ),
              ),
              monthCellStyle: const DateRangePickerMonthCellStyle(
                textStyle: TextStyle(color: Colors.white),
              ),
              onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
                if (args.value is PickerDateRange) {
                  final range = args.value as PickerDateRange;
                  _startDate = range.startDate;
                  _endDate = range.endDate;
                }
              },
            ),
          ),
          AppSizes.xs.ph,
          Text(AppStrings.maxParticipants, style: AppTextStyles.overLine(color: AppColors.white)),
          AppSizes.xxxs.ph,
          TextFormField(
            controller: _maxParticipantsController,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.darkBgContainer,
              hintText: "100",
              hintStyle: AppTextStyles.button(color: AppColors.grey600),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.xxxs),
                borderSide: BorderSide(
                  color: AppColors.skyBlue.withValues(alpha: 0.4),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.xxxs),
                borderSide: const BorderSide(color: AppColors.skyBlue),
              ),
            ),
          ),
          AppSizes.xs.ph,
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.firstPrize,
                      style: AppTextStyles.overLine(color: AppColors.white),
                    ),
                    AppSizes.xxxs.ph,
                    TextFormField(
                      controller: _firstPrizeController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.darkBgContainer,
                        hintText: "e.g. \$500",
                        hintStyle: AppTextStyles.button(color: AppColors.grey600),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSizes.xxxs),
                          borderSide: BorderSide(
                            color: AppColors.skyBlue.withValues(alpha: 0.4),
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
              AppSizes.xxxs.pw,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.secondPrize,
                      style: AppTextStyles.overLine(color: AppColors.white),
                    ),
                    AppSizes.xxxs.ph,
                    TextFormField(
                      controller: _secondPrizeController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.darkBgContainer,
                        hintText: "e.g. \$250",
                        hintStyle: AppTextStyles.button(color: AppColors.grey600),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSizes.xxxs),
                          borderSide: BorderSide(
                            color: AppColors.skyBlue.withValues(alpha: 0.4),
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
              AppSizes.xxxs.pw,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.thirdPrize,
                      style: AppTextStyles.overLine(color: AppColors.white),
                    ),
                    AppSizes.xxxs.ph,
                    TextFormField(
                      controller: _thirdPrizeController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.darkBgContainer,
                        hintText: "e.g. \$100",
                        hintStyle: AppTextStyles.button(color: AppColors.grey600),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSizes.xxxs),
                          borderSide: BorderSide(
                            color: AppColors.skyBlue.withValues(alpha: 0.4),
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
            ],
          ),
          AppSizes.xs.ph,
          CheckboxListTile(
            value: _isPaid,
            onChanged: (val) => setState(() => _isPaid = val ?? false),
            activeColor: AppColors.primaryOrange,
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
            title: Text(
              AppStrings.paidChallenge,
              style: AppTextStyles.overLine(color: AppColors.white).copyWith(
                fontWeight: AppFontWeights.bold,
              ),
            ),
          ),
          if (_isPaid) ...[
            AppSizes.xxxs.ph,
            Text("Entry Fee (\$)", style: AppTextStyles.overLine(color: AppColors.white)),
            AppSizes.xxxs.ph,
            TextFormField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.darkBgContainer,
                hintText: "29.99",
                hintStyle: AppTextStyles.button(color: AppColors.grey600),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.xxxs),
                  borderSide: BorderSide(
                    color: AppColors.skyBlue.withValues(alpha: 0.4),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.xxxs),
                  borderSide: const BorderSide(color: AppColors.skyBlue),
                ),
              ),
            ),
          ],
          AppSizes.xs.ph,
          Text(AppStrings.challengeThumbnail, style: AppTextStyles.overLine(color: AppColors.white)),
          AppSizes.xxxs.ph,
          InkWell(
            onTap: _pickImage,
            child: Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.darkBgContainer,
                border: Border.all(
                  color: AppColors.skyBlue.withValues(alpha: 0.5),
                ),
                borderRadius: BorderRadius.circular(AppSizes.xs),
                image: _pickedImage != null
                    ? DecorationImage(
                        image: FileImage(_pickedImage!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: _pickedImage != null
                  ? null
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const HugeIcon(
                          icon: HugeIconsStrokeRounded.image02,
                          color: AppColors.creamWhite,
                          size: 32,
                        ),
                        AppSizes.xxs.ph,
                        Text(
                          AppStrings.clickToUpload,
                          style: AppTextStyles.overLine(color: AppColors.creamWhite),
                        ),
                        Text(
                          "${AppStrings.fileType} (Max 5MB)",
                          style: AppTextStyles.caption2(
                            color: AppColors.white.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          AppSizes.md.ph,
          AppButton(
            isLoading: _isLoading,
            onPressed: _isLoading ? () {} : _submitChallenge,
            label: AppStrings.create,
            labelStyle: AppTextStyles.bodyText2(color: AppColors.black),
            bgColor: AppColors.primaryOrange,
            radius: AppSizes.xxxs,
          ),
        ],
      ),
    );
  }
}

