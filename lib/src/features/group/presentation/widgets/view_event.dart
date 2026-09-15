import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import 'package:intl/intl.dart';
import 'package:larnity/src/core/constants/app_size.dart';
import 'package:larnity/src/core/constants/app_strings.dart';
import 'package:larnity/src/core/extensions/extensions.dart';
import 'package:larnity/src/core/extensions/screen_size_extension.dart';
import 'package:larnity/src/core/theme/app_colors.dart';
import 'package:larnity/src/core/theme/theme.dart';
import 'package:larnity/src/core/ui/widgets/app_button.dart';
import 'package:larnity/src/core/ui/widgets/app_dropdown.dart';
import 'package:larnity/src/features/group/data/models/event_model.dart';
import 'package:larnity/src/features/group/data/models/live_class_model.dart';
import 'package:larnity/src/features/group/presentation/provider/event_provider.dart';
import 'package:larnity/src/features/group/presentation/provider/live_class_provider.dart';

class ViewEvent extends ConsumerWidget {
  final dynamic item; // Can be EventModel or LiveClassModel
  const ViewEvent({super.key, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (item == null) {
      return const Padding(
        padding: EdgeInsets.all(AppSizes.xs),
        child: Text("No item found", style: TextStyle(color: Colors.white)),
      );
    }

    final isEvent = item is EventModel;
    final title = isEvent ? (item as EventModel).title : (item as LiveClassModel).title;
    final description = isEvent ? (item as EventModel).description : (item as LiveClassModel).description;
    final image = isEvent ? (item as EventModel).image : (item as LiveClassModel).image;
    final startAt = isEvent ? (item as EventModel).startAt : (item as LiveClassModel).startAt;
    final endAt = isEvent ? (item as EventModel).endAt : (item as LiveClassModel).endAt;
    final groupId = isEvent ? (item as EventModel).groupId : (item as LiveClassModel).groupId;
    final id = isEvent ? (item as EventModel).id : (item as LiveClassModel).id;

    String? link;
    if (isEvent) {
      final ev = item as EventModel;
      link = ev.isOnline == true ? ev.meetingUrl : ev.location;
    } else {
      link = (item as LiveClassModel).meetingUrl;
    }

    final dateStr = startAt != null ? DateFormat('EEEE, MMMM dd, yyyy').format(startAt) : "N/A";
    final timeStr = startAt != null && endAt != null 
        ? "${DateFormat('hh:mm a').format(startAt)} - ${DateFormat('hh:mm a').format(endAt)}"
        : startAt != null ? DateFormat('hh:mm a').format(startAt) : "N/A";

    void handleDelete() {
      if (id == null) return;
      
      showDialog(
        context: context,
        builder: (dialogCtx) => AlertDialog(
          backgroundColor: AppColors.bgBlue,
          title: const Text("Delete Confirmation", style: TextStyle(color: Colors.white)),
          content: Text(
            "Are you sure you want to delete this ${isEvent ? 'event' : 'live class'}?",
            style: const TextStyle(color: AppColors.white),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogCtx).pop(); // Close confirmation
                Navigator.of(context).pop(); // Close ViewEvent

                if (isEvent) {
                  await ref.read(eventProvider(groupId).notifier).deleteEvent(
                    eventId: id,
                    successCallBack: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Event deleted successfully")),
                      );
                    },
                    failureCallBack: (err) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Failed to delete event: $err")),
                      );
                    },
                  );
                } else {
                  await ref.read(liveClassProvider(groupId).notifier).deleteLiveClass(
                    liveClassId: id,
                    successCallBack: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Live Class deleted successfully")),
                      );
                    },
                    failureCallBack: (err) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Failed to delete live class: $err")),
                      );
                    },
                  );
                }
              },
              child: const Text("Delete", style: TextStyle(color: AppColors.red)),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 0.2.sh,
          decoration: BoxDecoration(
            color: AppColors.primaryOrange,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(AppSizes.xs),
              topRight: Radius.circular(AppSizes.xs),
            ),
            image: image != null && image.isNotEmpty
                ? DecorationImage(
                    image: NetworkImage(image),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: image == null || image.isEmpty
              ? const Center(
                  child: HugeIcon(
                    icon: HugeIconsStrokeRounded.image02,
                    color: Colors.white,
                    size: 40,
                  ),
                )
              : null,
        ),
        Padding(
          padding: const EdgeInsets.all(AppSizes.xs),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title ?? "No Name",
                      style: AppTextStyles.headline1(color: AppColors.white),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  AppDropdown<String>(
                    button: const Icon(Icons.more_horiz, color: AppColors.white),
                    overlayWidth: 160,
                    overlayAlignment: Alignment.centerRight,
                    selectedValue: "",
                    selectedItemForegroundColor: AppColors.primaryOrange,
                    onItemSelected: (value) {
                      if (value == 'delete') {
                        handleDelete();
                      }
                    },
                    items: [
                      AppDropdownItem(
                        value: "delete",
                        child: Row(
                          children: [
                            const HugeIcon(
                              icon: HugeIconsStrokeRounded.delete01,
                              color: AppColors.red,
                            ),
                            AppSizes.xxxs.pw,
                            Text(
                              AppStrings.delete,
                              style: AppTextStyles.overLine(
                                color: AppColors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              AppSizes.xs.ph,
              if (description != null && description.isNotEmpty) ...[
                Text(
                  description,
                  style: AppTextStyles.bodyText2(color: AppColors.creamWhite),
                ),
                AppSizes.xs.ph,
              ],
              Row(
                children: [
                  const HugeIcon(
                    icon: HugeIconsStrokeRounded.calendar04,
                    color: AppColors.white,
                  ),
                  AppSizes.xs.pw,
                  Expanded(
                    child: Text(
                      dateStr,
                      style: AppTextStyles.overLine(color: AppColors.white),
                    ),
                  ),
                ],
              ),
              AppSizes.xs.ph,
              Row(
                children: [
                  const HugeIcon(
                    icon: HugeIconsStrokeRounded.clock01,
                    color: AppColors.white,
                  ),
                  AppSizes.xs.pw,
                  Expanded(
                    child: Text(
                      timeStr,
                      style: AppTextStyles.overLine(color: AppColors.white),
                    ),
                  ),
                ],
              ),
              if (link != null && link.isNotEmpty) ...[
                AppSizes.xs.ph,
                Row(
                  children: [
                    const HugeIcon(
                      icon: HugeIconsStrokeRounded.link05,
                      color: AppColors.white,
                    ),
                    AppSizes.xs.pw,
                    Expanded(
                      child: Text(
                        link,
                        style: AppTextStyles.overLine(color: AppColors.skyBlue),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
              AppSizes.xs.ph,
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AppButton(
                    isExpanded: false,
                    onPressed: () {
                      context.pop();
                    },
                    label: AppStrings.close,
                    labelStyle: AppTextStyles.button(color: AppColors.white),
                    bgColor: Colors.transparent,
                    borderColor: AppColors.skyBlue.withValues(alpha: 0.5),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
