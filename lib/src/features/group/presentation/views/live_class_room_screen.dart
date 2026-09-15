import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import 'package:larnity/src/core/constants/app_size.dart';
import 'package:larnity/src/core/constants/app_strings.dart';
import 'package:larnity/src/core/extensions/extensions.dart';
import 'package:larnity/src/core/extensions/screen_size_extension.dart';
import 'package:larnity/src/core/theme/app_colors.dart';
import 'package:larnity/src/core/theme/theme.dart';
import 'package:larnity/src/core/ui/widgets/app_button.dart';
import 'package:larnity/src/features/group/presentation/widgets/add_class.dart';
import 'package:larnity/src/features/group/presentation/widgets/view_event.dart';
import 'package:larnity/src/features/group/presentation/provider/group_provider.dart';
import 'package:larnity/src/features/group/presentation/provider/live_class_provider.dart';
import 'package:larnity/src/features/group/data/models/live_class_model.dart';
import 'package:larnity/src/core/utils/async_states.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class LiveClassRoomScreen extends ConsumerWidget {
  const LiveClassRoomScreen({super.key});

  _AppointmentDataSource _getCalendarDataSource(List<LiveClassModel>? liveClasses) {
    List<Appointment> appointments = <Appointment>[];
    if (liveClasses != null) {
      for (var liveClass in liveClasses) {
        appointments.add(
          Appointment(
            id: liveClass.id,
            startTime: liveClass.startAt ?? DateTime.now(),
            endTime: liveClass.endAt ?? (liveClass.startAt?.add(const Duration(hours: 1)) ?? DateTime.now()),
            subject: liveClass.title ?? 'Untitled Class',
            color: AppColors.primaryOrange,
            notes: liveClass.description,
            location: liveClass.meetingUrl,
          ),
        );
      }
    }
    return _AppointmentDataSource(appointments);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupState = ref.watch(groupProvider);
    final groupId = groupState.group?.id;

    if (groupId == null || groupId.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text("Live Class Room")),
        backgroundColor: AppColors.bgBlue,
        body: const Center(
          child: Text(
            "Please select a group first",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      );
    }

    final liveClassState = ref.watch(liveClassProvider(groupId));
    final isLoading = liveClassState.fetchState == AsyncState.loading;

    return Scaffold(
      appBar: AppBar(title: const Text("Live Class Room")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            AppSizes.xs.ph,
            Container(
              height: 1.sh,
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.xs),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppStrings.liveClass,
                        style: AppTextStyles.headline2(color: AppColors.white),
                      ),
                      AppButton(
                        isExpanded: false,
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => Dialog(
                              backgroundColor: AppColors.bgBlue,
                              child: AddClass(groupId: groupId),
                            ),
                          );
                        },
                        prefix: const HugeIcon(
                          icon: HugeIconsStrokeRounded.addCircle,
                          color: AppColors.black,
                        ),
                        label: AppStrings.addClass,
                        labelStyle: AppTextStyles.bodyText2(
                          color: AppColors.black,
                        ),
                        bgColor: AppColors.primaryOrange,
                        radius: AppSizes.xxxs,
                      ),
                    ],
                  ),
                  AppSizes.xs.ph,
                  if (isLoading)
                    const Expanded(
                      child: Center(
                        child: CircularProgressIndicator(color: AppColors.primaryOrange),
                      ),
                    )
                  else
                    SizedBox(
                      height: 0.9.sh,
                      child: SfCalendar(
                        dataSource: _getCalendarDataSource(liveClassState.liveClasses),
                        allowDragAndDrop: false,
                        view: CalendarView.month,
                        appointmentBuilder: (context, calendarAppointmentDetails) {
                          final appointment = calendarAppointmentDetails.appointments.first as Appointment;
                          return GestureDetector(
                            onTap: () {
                              final matchedClass = liveClassState.liveClasses?.firstWhere(
                                (c) => c.id == appointment.id,
                                orElse: () => liveClassState.liveClasses!.first,
                              );
                              showDialog(
                                context: context,
                                builder: (context) => Dialog(
                                  backgroundColor: AppColors.bgBlue,
                                  child: ViewEvent(item: matchedClass),
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColors.skyBlue),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    height: 12,
                                    width: 12,
                                    decoration: const BoxDecoration(
                                      color: AppColors.primaryOrange,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  AppSizes.xxxs.pw,
                                  Expanded(
                                    child: Text(
                                      appointment.subject,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: const TextStyle(color: AppColors.white, fontSize: 11),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        onTap: (calendarTapDetails) {
                          if (calendarTapDetails.appointments == null || calendarTapDetails.appointments!.isEmpty) {
                            showDialog(
                              context: context,
                              builder: (context) => Dialog(
                                backgroundColor: AppColors.bgBlue,
                                child: AddClass(groupId: groupId),
                              ),
                            );
                          }
                        },
                        monthViewSettings: const MonthViewSettings(
                          appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
                        ),
                        timeSlotViewSettings: const TimeSlotViewSettings(
                          minimumAppointmentDuration: Duration(minutes: 60),
                        ),
                        scheduleViewSettings: const ScheduleViewSettings(
                          appointmentItemHeight: 20,
                        ),
                      ),
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

class _AppointmentDataSource extends CalendarDataSource {
  _AppointmentDataSource(List<Appointment> source) {
    appointments = source;
  }
}
