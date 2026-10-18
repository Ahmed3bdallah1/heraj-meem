import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj_meem/config/app_color.dart';
import 'package:heraj_meem/config/app_font.dart';
import 'package:heraj_meem/core/service/local_data_manager.dart';
import 'package:heraj_meem/helper/riverpod.dart';
import 'package:heraj_meem/main.dart';
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatsAsync = ref.watch(fetchChatsProvider);
    final searchQuery = ref.watch(chatsSearchQueryProvider);
    final currentUser = getIt<LocalDataManager>().getUser();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: Colors.white,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    ref.read(chatsSearchQueryProvider.notifier).state =
                        value.toLowerCase();
                  },
                  decoration: InputDecoration(
                    hintText: "Search".tr,
                    hintStyle: TextStyle(color: Colors.grey[500]),
                    prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
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
                      itemBuilder: (context, index) {
                        final chat = filteredChats[index];
                        final currentUserId = currentUser?.id.toString() ?? '';
                        final otherParticipant =
                            chat.getOtherParticipant(currentUserId);
                        final unreadCount =
                            chat.getUnreadCountForUser(currentUserId);

                        return ChatListItem(
                          chat: chat,
                          otherParticipant: otherParticipant,
                          unreadCount: unreadCount,
                        );
                      },
                      separatorBuilder: (context, index) => const Divider(
                        height: 1,
                        thickness: 1,
                        color: Color(0xFFE5E5E5),
                        indent: 88,
                      ),
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

    return GestureDetector(
      onTap: () {
        Get.to(() => ChatMessagesScreen(chatId: chat.id));
      },
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.zero,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: displayImage.isNotEmpty
                        ? Image.network(
                            displayImage,
                            height: 60,
                            width: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 60,
                                width: 60,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: const Icon(
                                  Icons.person,
                                  color: Colors.grey,
                                ),
                              );
                            },
                          )
                        : Container(
                            height: 60,
                            width: 60,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: const Icon(
                              Icons.person,
                              color: Colors.grey,
                            ),
                          ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Gap(4),
                    Text(
                      lastMessage,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight:
                            isUnread ? FontWeight.w600 : FontWeight.normal,
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
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  if (isUnread) ...[
                    const Gap(6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
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
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
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
      ),
    );
  }
}
