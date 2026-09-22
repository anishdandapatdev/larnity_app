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
import 'package:go_router/go_router.dart';
import 'package:larnity/src/core/router/router.dart';
import 'package:larnity/src/features/group/presentation/widgets/add_event.dart';
import 'package:larnity/src/features/group/presentation/widgets/view_event.dart';
import 'package:larnity/src/features/group/presentation/provider/group_provider.dart';
import 'package:larnity/src/features/group/presentation/provider/event_provider.dart';
import 'package:larnity/src/features/group/data/models/event_model.dart';
import 'package:larnity/src/core/utils/async_states.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class EventRoomScreen extends ConsumerWidget {
  const EventRoomScreen({super.key});

  _AppointmentDataSource _getCalendarDataSource(List<EventModel>? events) {
    List<Appointment> appointments = <Appointment>[];
    if (events != null) {
      for (var event in events) {
        appointments.add(
          Appointment(
            id: event.id,
            startTime: event.startAt ?? DateTime.now(),
            endTime: event.endAt ?? (event.startAt?.add(const Duration(hours: 1)) ?? DateTime.now()),
            subject: event.title ?? 'Untitled Event',
            color: AppColors.primaryOrange,
            notes: event.description,
            location: event.isOnline == true ? event.meetingUrl : event.location,
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
        appBar: AppBar(
          title: const Text("Event Room"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.goNamed(Routes.group);
              }
            },
          ),
        ),
        backgroundColor: AppColors.bgBlue,
        body: const Center(
          child: Text(
            "Please select a group first",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      );
    }

    final eventState = ref.watch(eventProvider(groupId));
    final isLoading = eventState.fetchState == AsyncState.loading;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Event Room"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.goNamed(Routes.group);
            }
          },
        ),
      ),
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
                        AppStrings.myEvents,
                        style: AppTextStyles.headline2(color: AppColors.white),
                      ),
                      AppButton(
                        isExpanded: false,
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => Dialog(
                              backgroundColor: AppColors.bgBlue,
                              child: AddEvent(groupId: groupId),
                            ),
                          );
                        },
                        prefix: const HugeIcon(
                          icon: HugeIconsStrokeRounded.addCircle,
                          color: AppColors.black,
                        ),
                        label: AppStrings.addEvent,
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
                        dataSource: _getCalendarDataSource(eventState.events),
                        allowDragAndDrop: false,
                        view: CalendarView.month,
                        appointmentBuilder: (context, calendarAppointmentDetails) {
                          final appointment = calendarAppointmentDetails.appointments.first as Appointment;
                          return GestureDetector(
                            onTap: () {
                              final matchedEvent = eventState.events?.firstWhere(
                                (e) => e.id == appointment.id,
                                orElse: () => eventState.events!.first,
                              );
                              showDialog(
                                context: context,
                                builder: (context) => Dialog(
                                  backgroundColor: AppColors.bgBlue,
                                  child: ViewEvent(item: matchedEvent),
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
                          // Tap on an empty slot allows adding an event directly
                          if (calendarTapDetails.appointments == null || calendarTapDetails.appointments!.isEmpty) {
                            showDialog(
                              context: context,
                              builder: (context) => Dialog(
                                backgroundColor: AppColors.bgBlue,
                                child: AddEvent(groupId: groupId),
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
