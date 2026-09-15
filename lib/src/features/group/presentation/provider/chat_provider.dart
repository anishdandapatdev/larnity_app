import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:larnity/src/core/utils/async_states.dart';
import 'package:larnity/src/features/group/data/datasource/chat_datasource.dart';
import 'package:larnity/src/features/group/data/models/channel_model.dart';
import 'package:larnity/src/features/group/data/models/message_model.dart';

class ChatState {
  final AsyncState? fetchState;
  final AsyncState? sendState;
  final String? error;
  final List<ChannelModel>? channels;
  final ChannelModel? selectedChannel;
  final List<MessageModel>? messages;
  final bool hasMore;
  final int offset;

  ChatState({
    this.fetchState, this.sendState, this.error, this.channels,
    this.selectedChannel, this.messages, this.hasMore = true, this.offset = 0,
  });

  ChatState copyWith({
    AsyncState? fetchState, AsyncState? sendState, String? error,
    List<ChannelModel>? channels, ChannelModel? selectedChannel,
    List<MessageModel>? messages, bool? hasMore, int? offset,
  }) => ChatState(
    fetchState: fetchState ?? this.fetchState,
    sendState: sendState ?? this.sendState,
    error: error ?? this.error,
    channels: channels ?? this.channels,
    selectedChannel: selectedChannel ?? this.selectedChannel,
    messages: messages ?? this.messages,
    hasMore: hasMore ?? this.hasMore,
    offset: offset ?? this.offset,
  );
}

final chatProvider = NotifierProvider.autoDispose
    .family<ChatNotifier, ChatState, String>(ChatNotifier.new);

class ChatNotifier extends AutoDisposeFamilyNotifier<ChatState, String> {
  static const int _pageSize = 50;

  @override
  ChatState build(String arg) {
    Future.microtask(() => fetchChannels());
    return ChatState(fetchState: AsyncState.initial);
  }

  String get _groupId => arg;

  Future<void> fetchChannels() async {
    final ds = ref.read(chatDataSourceProvider);
    state = state.copyWith(fetchState: AsyncState.loading);
    final result = await ds.getChannels(groupId: _groupId);
    result.fold(
      (f) => state = state.copyWith(fetchState: AsyncState.failure, error: f.message),
      (channels) {
        state = state.copyWith(fetchState: AsyncState.success, channels: channels);
        // Auto-select first channel if available
        if (channels.isNotEmpty && state.selectedChannel == null) {
          selectChannel(channels.first);
        }
      },
    );
  }

  Future<void> selectChannel(ChannelModel channel) async {
    state = state.copyWith(
      selectedChannel: channel,
      messages: null,
      offset: 0,
      hasMore: true,
    );
    await fetchMessages();
  }

  Future<void> fetchMessages() async {
    final channelId = state.selectedChannel?.id;
    if (channelId == null) return;

    final ds = ref.read(chatDataSourceProvider);
    state = state.copyWith(fetchState: AsyncState.loading, offset: 0);

    final result = await ds.getMessages(
      channelId: channelId, limit: _pageSize, offset: 0,
    );

    result.fold(
      (f) => state = state.copyWith(fetchState: AsyncState.failure, error: f.message),
      (messages) {
        // Reverse so oldest messages come first in the list
        state = state.copyWith(
          fetchState: AsyncState.success,
          messages: messages.reversed.toList(),
          hasMore: messages.length >= _pageSize,
          offset: messages.length,
        );
      },
    );
  }

  Future<void> loadOlderMessages() async {
    if (!state.hasMore) return;
    final channelId = state.selectedChannel?.id;
    if (channelId == null) return;

    final ds = ref.read(chatDataSourceProvider);
    final result = await ds.getMessages(
      channelId: channelId, limit: _pageSize, offset: state.offset,
    );

    result.fold(
      (f) => state = state.copyWith(error: f.message),
      (olderMessages) {
        // Prepend older messages
        final allMessages = [...olderMessages.reversed, ...(state.messages ?? [])];
        state = state.copyWith(
          messages: allMessages,
          hasMore: olderMessages.length >= _pageSize,
          offset: state.offset + olderMessages.length,
        );
      },
    );
  }

  Future<void> sendMessage({
    required MessageModel message,
    void Function()? successCallBack,
    void Function(String error)? failureCallBack,
  }) async {
    final ds = ref.read(chatDataSourceProvider);
    state = state.copyWith(sendState: AsyncState.loading);

    final result = await ds.sendMessage(message: message);
    result.fold(
      (f) { state = state.copyWith(sendState: AsyncState.failure, error: f.message); failureCallBack?.call(f.message); },
      (sent) {
        state = state.copyWith(
          sendState: AsyncState.success,
          messages: [...(state.messages ?? []), sent],
        );
        successCallBack?.call();
      },
    );
  }

  Future<void> deleteMessage({
    required String messageId,
  }) async {
    final ds = ref.read(chatDataSourceProvider);
    final result = await ds.deleteMessage(messageId: messageId);
    result.fold(
      (_) {},
      (_) => state = state.copyWith(
        messages: state.messages?.where((m) => m.id != messageId).toList(),
      ),
    );
  }

  /// Add a message from realtime subscription.
  void addRealtimeMessage(MessageModel message) {
    if (message.channelId != state.selectedChannel?.id) return;
    // Avoid duplicates
    if (state.messages?.any((m) => m.id == message.id) == true) return;
    state = state.copyWith(messages: [...(state.messages ?? []), message]);
  }
}
