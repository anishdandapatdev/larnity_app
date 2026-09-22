import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import 'package:intl/intl.dart';
import 'package:larnity/src/core/constants/app_size.dart';
import 'package:larnity/src/core/constants/app_strings.dart';
import 'package:larnity/src/core/extensions/extensions.dart';
import 'package:larnity/src/core/service/supabase/src/supabase_provider.dart';
import 'package:larnity/src/core/theme/app_colors.dart';
import 'package:larnity/src/core/theme/theme.dart';
import 'package:larnity/src/core/utils/async_states.dart';
import 'package:larnity/src/core/utils/show_snackbar.dart';
import 'package:larnity/src/features/group/data/models/message_model.dart';
import 'package:larnity/src/features/group/presentation/provider/chat_provider.dart';
import 'package:larnity/src/features/group/presentation/provider/group_provider.dart';
import 'package:larnity/src/features/group/presentation/provider/member_provider.dart';

class ChattingScreen extends ConsumerStatefulWidget {
  const ChattingScreen({super.key});

  @override
  ConsumerState<ChattingScreen> createState() => _ChattingScreenState();
}

class _ChattingScreenState extends ConsumerState<ChattingScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isSending = false;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage(String groupId, String channelId) async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final client = ref.read(supabaseClientProvider);
    final user = client.auth.currentUser;
    if (user == null) {
      showErrorToast(content: "You must be logged in to send messages");
      return;
    }

    setState(() => _isSending = true);
    _messageController.clear();

    final message = MessageModel(
      channelId: channelId,
      userId: user.id,
      content: text,
      type: 'text',
      createdAt: DateTime.now(),
    );

    await ref.read(chatProvider(groupId).notifier).sendMessage(
          message: message,
          successCallBack: () {
            if (mounted) {
              setState(() => _isSending = false);
              _scrollToBottom();
            }
          },
          failureCallBack: (err) {
            if (mounted) {
              setState(() => _isSending = false);
              showErrorToast(content: "Failed to send: $err");
            }
          },
        );
  }

  @override
  Widget build(BuildContext context) {
    final group = ref.watch(groupProvider).group;
    if (group == null || group.id == null) {
      return const Scaffold(
        backgroundColor: AppColors.darkBg,
        body: Center(
          child: Text(
            "No group selected",
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    final chatState = ref.watch(chatProvider(group.id!));
    final memberState = ref.watch(memberProvider(group.id!));
    final channels = chatState.channels ?? [];
    final selectedChannel = chatState.selectedChannel;
    final messages = chatState.messages ?? [];
    final currentUserId =
        ref.read(supabaseClientProvider).auth.currentUser?.id;

    // Trigger scroll when messages change
    if (messages.isNotEmpty) {
      _scrollToBottom();
    }

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: AppBar(
        backgroundColor: AppColors.darkBg,
        elevation: 1,
        title: Text(
          selectedChannel != null
              ? "# ${selectedChannel.name ?? 'channel'}"
              : AppStrings.messages,
          style: AppTextStyles.headline4(color: Colors.white),
        ),
        actions: [
          Builder(
            builder: (ctx) => IconButton(
              icon: const HugeIcon(
                icon: HugeIconsStrokeRounded.userMultiple02,
                color: Colors.white,
              ),
              onPressed: () => Scaffold.of(ctx).openEndDrawer(),
            ),
          ),
        ],
      ),
      endDrawer: Drawer(
        backgroundColor: AppColors.darkBgContainer,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.xs),
            child: ListView(
              children: [
                Text(
                  "Channels",
                  style: AppTextStyles.headline4(color: Colors.white),
                ),
                Text(
                  "Switch discussion rooms",
                  style: AppTextStyles.overLine(color: AppColors.skyBlue),
                ),
                AppSizes.xs.ph,
                ...channels.map((chan) {
                  final isCurrent = chan.id == selectedChannel?.id;
                  return ListTile(
                    dense: true,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    tileColor: isCurrent
                        ? AppColors.primaryOrange.withValues(alpha: 0.15)
                        : null,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    leading: Icon(
                      Icons.tag,
                      color: isCurrent
                          ? AppColors.primaryOrange
                          : Colors.grey,
                      size: 18,
                    ),
                    title: Text(
                      chan.name ?? 'Channel',
                      style: TextStyle(
                        color: isCurrent ? AppColors.primaryOrange : Colors.white,
                        fontWeight:
                            isCurrent ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    onTap: () {
                      ref
                          .read(chatProvider(group.id!).notifier)
                          .selectChannel(chan);
                      Navigator.of(context).pop();
                    },
                  );
                }),
                AppSizes.sm.ph,
                Divider(color: AppColors.skyBlue.withValues(alpha: 0.3)),
                AppSizes.xs.ph,
                Text(
                  AppStrings.groupMembers,
                  style: AppTextStyles.headline4(color: Colors.white),
                ),
                Text(
                  "${memberState.members?.length ?? 0} members",
                  style: AppTextStyles.overLine(color: AppColors.skyBlue),
                ),
                AppSizes.xs.ph,
                ...(memberState.members ?? []).map((m) {
                  final name = m.memberName;
                  final role = m.role;
                  return ListTile(
                    dense: true,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    leading: CircleAvatar(
                      radius: 14,
                      backgroundColor: AppColors.bgBlue,
                      backgroundImage: m.memberImage != null
                          ? NetworkImage(m.memberImage!)
                          : null,
                      child: m.memberImage == null
                          ? Text(
                              name.isNotEmpty ? name[0].toUpperCase() : '?',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            )
                          : null,
                    ),
                    title: Text(
                      name,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                    ),
                    trailing: Text(
                      role,
                      style: TextStyle(
                        color: role == 'ADMIN'
                            ? AppColors.primaryOrange
                            : (role == 'MODERATOR'
                                ? AppColors.lightGreen
                                : Colors.grey),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
      body: selectedChannel == null
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.xs),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppStrings.noChatSelected,
                      style: AppTextStyles.headline2(color: Colors.white),
                    ),
                    AppSizes.md.ph,
                    Text(
                      AppStrings.noChatSelectedDesc,
                      style: AppTextStyles.overLine(color: AppColors.grey500),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: chatState.fetchState == AsyncState.loading &&
                          messages.isEmpty
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primaryOrange,
                          ),
                        )
                      : messages.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const HugeIcon(
                                    icon: HugeIconsStrokeRounded.bubbleChat,
                                    color: AppColors.skyBlue,
                                    size: 48,
                                  ),
                                  AppSizes.sm.ph,
                                  Text(
                                    "Welcome to #${selectedChannel.name}!",
                                    style: AppTextStyles.headline3(
                                      color: Colors.white,
                                    ),
                                  ),
                                  AppSizes.xxs.ph,
                                  Text(
                                    AppStrings.messageAppearHere,
                                    style: AppTextStyles.overLine(
                                      color: AppColors.skyBlue,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.all(AppSizes.xs),
                              itemCount: messages.length,
                              itemBuilder: (context, index) {
                                final msg = messages[index];
                                final isMe = msg.userId == currentUserId;
                                final timeStr = msg.createdAt != null
                                    ? DateFormat('hh:mm a')
                                        .format(msg.createdAt!)
                                    : '';

                                return Align(
                                  alignment: isMe
                                      ? Alignment.centerRight
                                      : Alignment.centerLeft,
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 4,
                                    ),
                                    constraints: BoxConstraints(
                                      maxWidth:
                                          MediaQuery.of(context).size.width *
                                              0.75,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isMe
                                          ? AppColors.primaryOrange
                                          : AppColors.darkBgContainer,
                                      borderRadius: BorderRadius.only(
                                        topLeft: const Radius.circular(12),
                                        topRight: const Radius.circular(12),
                                        bottomLeft: Radius.circular(isMe ? 12 : 2),
                                        bottomRight:
                                            Radius.circular(isMe ? 2 : 12),
                                      ),
                                      border: isMe
                                          ? null
                                          : Border.all(
                                              color: AppColors.skyBlue
                                                  .withValues(alpha: 0.2),
                                            ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: isMe
                                          ? CrossAxisAlignment.end
                                          : CrossAxisAlignment.start,
                                      children: [
                                        if (!isMe)
                                          Text(
                                            msg.senderName,
                                            style: const TextStyle(
                                              color: AppColors.skyBlue,
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        Text(
                                          msg.content ?? '',
                                          style: TextStyle(
                                            color: isMe
                                                ? Colors.black
                                                : Colors.white,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          timeStr,
                                          style: TextStyle(
                                            color: isMe
                                                ? Colors.black54
                                                : Colors.grey,
                                            fontSize: 9,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.xs,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.darkBgContainer,
                    border: Border(
                      top: BorderSide(
                        color: AppColors.skyBlue.withValues(alpha: 0.2),
                      ),
                    ),
                  ),
                  child: SafeArea(
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _messageController,
                            style: const TextStyle(color: Colors.white),
                            onFieldSubmitted: (_) => _sendMessage(
                              group.id!,
                              selectedChannel.id!,
                            ),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: AppColors.bgBlue,
                              hintText:
                                  "Message #${selectedChannel.name ?? 'channel'}...",
                              hintStyle: AppTextStyles.button(
                                color: AppColors.grey600,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        AppSizes.xxs.pw,
                        IconButton(
                          icon: _isSending
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.primaryOrange,
                                  ),
                                )
                              : const Icon(
                                  Icons.send_rounded,
                                  color: AppColors.primaryOrange,
                                ),
                          onPressed: _isSending
                              ? null
                              : () => _sendMessage(
                                    group.id!,
                                    selectedChannel.id!,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

