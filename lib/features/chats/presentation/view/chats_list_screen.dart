import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj_meem/config/app_color.dart';
import 'package:heraj_meem/config/app_font.dart';
import 'package:heraj_meem/core/service/local_data_manager.dart';
import 'package:heraj_meem/helper/riverpod.dart';
import 'package:heraj_meem/main.dart';
import 'package:heraj_meem/ui/shared_widgets/image_or_svg.dart';
import 'package:heraj_meem/ui/shared_widgets/not_found_widget.dart';
import '../../domain/entities/chat_entity.dart';
import '../../domain/entities/participant_entity.dart';
import '../managers/chats_provider.dart';
import '../managers/chats_search_provider.dart';
import 'chat_messages_screen.dart';

class ChatsListScreen extends ConsumerStatefulWidget {
  const ChatsListScreen({super.key});

  @override
  ConsumerState<ChatsListScreen> createState() => _ChatsListScreenState();
}

class _ChatsListScreenState extends ConsumerState<ChatsListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatsAsync = ref.watch(fetchChatsProvider);
    final searchQuery = ref.watch(chatsSearchQueryProvider);
    final currentUser = getIt<LocalDataManager>().getUser();

    return Scaffold(
      // backgroundColor: AppColor.primary2,
      body: SafeArea(
        child: Column(
          children: [
            _ChatEntrance(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: AppColor.primary.withAlpha(24),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocus,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _searchFocus.unfocus(),
                    onChanged: (value) {
                      ref.read(chatsSearchQueryProvider.notifier).state =
                          value.toLowerCase();
                    },
                    style: AppFont.font14W600Black,
                    decoration: InputDecoration(
                      hintText: "Search".tr,
                      hintStyle: AppFont.font14W500Grey2,
                      prefixIcon: Icon(Icons.search, color: AppColor.grey2),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(fetchChatsProvider);
                  await ref.read(fetchChatsProvider.future);
                },
                child: chatsAsync.customWhen(
                  ref: ref,
                  refreshable: fetchChatsProvider.future,
                  skipLoadingOnRefresh: true,
                  skipLoadingOnReload: true,
                  error: (e, st) {
                    return SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: MediaQuery.of(context).size.height - 200,
                        ),
                        child: NotFoundWidget(
                          title: "Error occurred".tr,
                          message: e.toString(),
                        ),
                      ),
                    );
                  },
                  data: (chats) {
                    final filteredChats = searchQuery.isEmpty
                        ? chats
                        : chats.where((chat) {
                            final currentUserId =
                                currentUser?.id.toString() ?? '';
                            final otherParticipant =
                                chat.getOtherParticipant(currentUserId);
                            final displayName =
                                otherParticipant?.userId?.displayName ?? '';
                            final lastMessage = chat.lastMessage?.content ?? '';

                            return displayName
                                    .toLowerCase()
                                    .contains(searchQuery) ||
                                lastMessage.toLowerCase().contains(searchQuery);
                          }).toList();

                    if (filteredChats.isEmpty) {
                      return SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: MediaQuery.of(context).size.height - 200,
                          ),
                          child: NotFoundWidget(
                            title: searchQuery.isEmpty
                                ? "No Chats found".tr
                                : "No results found".tr,
                            message: searchQuery.isEmpty
                                ? "You have no chats yet".tr
                                : "Try a different search term".tr,
                          ),
                        ),
                      );
                    }

                    return ListView.separated(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).padding.bottom + 100,
                      ),
                      itemBuilder: (context, index) {
                        final chat = filteredChats[index];
                        final currentUserId = currentUser?.id.toString() ?? '';
                        final otherParticipant =
                            chat.getOtherParticipant(currentUserId);
                        final unreadCount =
                            chat.getUnreadCountForUser(currentUserId);

                        return _ChatEntrance(
                          index: index,
                          child: ChatListItem(
                            chat: chat,
                            otherParticipant: otherParticipant,
                            unreadCount: unreadCount,
                          ),
                        );
                      },
                      separatorBuilder: (context, index) => const Gap(8),
                      itemCount: filteredChats.length,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatListItem extends StatelessWidget {
  final ChatEntity chat;
  final ParticipantEntity? otherParticipant;
  final int unreadCount;

  const ChatListItem({
    super.key,
    required this.chat,
    this.otherParticipant,
    required this.unreadCount,
  });

  String formatTime(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(date.year, date.month, date.day);

    if (messageDate == today) {
      final minutes = date.minute;
      final period = date.hour >= 12 ? 'PM'.tr : 'AM'.tr;
      final displayHour =
          date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
      return '${displayHour.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')} $period';
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday'.tr;
    } else {
      return '${date.day}/${date.month}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final userInfo = otherParticipant?.userId;
    final displayName = userInfo?.displayName ?? 'Unknown User'.tr;
    final displayImage = userInfo?.displayImage ?? '';
    final lastMessage = chat.lastMessage?.content ?? '';
    final lastMessageTime =
        formatTime(chat.lastMessage?.createdAt ?? chat.updatedAt);
    final isUnread = unreadCount > 0;

    return _ChatPress(
      onTap: () => Get.to(() => ChatMessagesScreen(chatId: chat.id)),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppColor.primary.withAlpha(18),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColor.primary.withAlpha(80)),
              ),
              child: ClipOval(
                child: displayImage.isNotEmpty
                    ? ImageOrSvg(
                        displayImage,
                        height: 56,
                        width: 56,
                        fit: BoxFit.cover,
                      )
                    : ColoredBox(
                        color: AppColor.primary.withAlpha(28),
                        child: const SizedBox(
                          height: 56,
                          width: 56,
                          child: Icon(Icons.person, color: AppColor.primary),
                        ),
                      ),
              ),
            ),
            const Gap(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: AppFont.font16W700Black,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Gap(4),
                  Text(
                    lastMessage,
                    style: AppFont.font14W500Grey2.copyWith(
                      fontWeight: isUnread ? FontWeight.w600 : FontWeight.w400,
                      color: isUnread ? AppColor.black : AppColor.grey2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  lastMessageTime,
                  style:
                      AppFont.font12w400Black.copyWith(color: AppColor.grey2),
                ),
                if (isUnread) ...[
                  const Gap(6),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 420),
                    curve: Curves.elasticOut,
                    builder: (context, value, child) {
                      return Transform.scale(scale: value, child: child);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: const BoxDecoration(
                        color: AppColor.primary,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 20,
                        minHeight: 20,
                      ),
                      child: Center(
                        child: Text(
                          unreadCount > 99 ? '99+' : unreadCount.toString(),
                          style: AppFont.font12w400Black.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatEntrance extends StatelessWidget {
  const _ChatEntrance({required this.child, this.index = 0});

  final Widget child;
  final int index;

  @override
  Widget build(BuildContext context) {
    final delay = index.clamp(0, 8) * 60;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 420 + delay),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(28 * (1 - value), 0),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

class _ChatPress extends StatefulWidget {
  const _ChatPress({required this.child, required this.onTap});

  final Widget child;
  final VoidCallback onTap;

  @override
  State<_ChatPress> createState() => _ChatPressState();
}

class _ChatPressState extends State<_ChatPress> {
  final ValueNotifier<double> _scale = ValueNotifier(1);

  @override
  void dispose() {
    _scale.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _scale.value = 0.97,
      onTapCancel: () => _scale.value = 1,
      onTapUp: (_) => _scale.value = 1,
      onTap: widget.onTap,
      child: ValueListenableBuilder<double>(
        valueListenable: _scale,
        builder: (context, scale, child) {
          return AnimatedScale(
            scale: scale,
            duration: const Duration(milliseconds: 140),
            curve: Curves.easeOut,
            child: child,
          );
        },
        child: widget.child,
      ),
    );
  }
}
