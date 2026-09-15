import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:larnity/src/core/utils/async_states.dart';
import 'package:larnity/src/features/group/data/datasource/event_datasource.dart';
import 'package:larnity/src/features/group/data/models/event_model.dart';

class EventState {
  final AsyncState? fetchState;
  final AsyncState? createState;
  final String? error;
  final List<EventModel>? events;
  final EventModel? selectedEvent;

  EventState({this.fetchState, this.createState, this.error, this.events, this.selectedEvent});

  EventState copyWith({
    AsyncState? fetchState, AsyncState? createState, String? error,
    List<EventModel>? events, EventModel? selectedEvent,
  }) => EventState(
    fetchState: fetchState ?? this.fetchState,
    createState: createState ?? this.createState,
    error: error ?? this.error,
    events: events ?? this.events,
    selectedEvent: selectedEvent ?? this.selectedEvent,
  );
}

final eventProvider = NotifierProvider.autoDispose
    .family<EventNotifier, EventState, String>(EventNotifier.new);

class EventNotifier extends AutoDisposeFamilyNotifier<EventState, String> {
  @override
  EventState build(String arg) {
    Future.microtask(() => fetchEvents());
    return EventState(fetchState: AsyncState.initial);
  }

  String get _groupId => arg;

  Future<void> fetchEvents() async {
    final ds = ref.read(eventDataSourceProvider);
    state = state.copyWith(fetchState: AsyncState.loading);
    final result = await ds.getEvents(groupId: _groupId);
    result.fold(
      (f) => state = state.copyWith(fetchState: AsyncState.failure, error: f.message),
      (events) => state = state.copyWith(fetchState: AsyncState.success, events: events),
    );
  }

  Future<void> fetchUpcomingEvents() async {
    final ds = ref.read(eventDataSourceProvider);
    state = state.copyWith(fetchState: AsyncState.loading);
    final result = await ds.getUpcomingEvents(groupId: _groupId);
    result.fold(
      (f) => state = state.copyWith(fetchState: AsyncState.failure, error: f.message),
      (events) => state = state.copyWith(fetchState: AsyncState.success, events: events),
    );
  }

  Future<void> createEvent({
    required EventModel event,
    void Function()? successCallBack,
    void Function(String error)? failureCallBack,
  }) async {
    final ds = ref.read(eventDataSourceProvider);
    state = state.copyWith(createState: AsyncState.loading);
    final result = await ds.createEvent(event: event);
    result.fold(
      (f) { state = state.copyWith(createState: AsyncState.failure, error: f.message); failureCallBack?.call(f.message); },
      (created) { state = state.copyWith(createState: AsyncState.success, events: [created, ...(state.events ?? [])]); successCallBack?.call(); },
    );
  }

  Future<void> deleteEvent({
    required String eventId,
    void Function()? successCallBack,
    void Function(String error)? failureCallBack,
  }) async {
    final ds = ref.read(eventDataSourceProvider);
    final result = await ds.deleteEvent(eventId: eventId);
    result.fold(
      (f) => failureCallBack?.call(f.message),
      (_) { state = state.copyWith(events: state.events?.where((e) => e.id != eventId).toList()); successCallBack?.call(); },
    );
  }
}
