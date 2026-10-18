import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' as intl;
import 'package:flutter_firebase_chat/src/utils/local_service/local_data_manager.dart';
import '../../../data/models/user_model.dart';
import '../../../domain/entities/chat_entity.dart';
import '../chat_screen.dart';

enum NavigatorType { Get, Navigator }

class ChatTileContainer extends ConsumerWidget {
  final ChatEntity chat;
  final NavigatorType navigatorType;
  final UserData? receiverData;
  final Color? primaryColor;

  const ChatTileContainer({
    super.key,
    required this.chat,
    this.receiverData,
    this.navigatorType = NavigatorType.Get,
    this.primaryColor,
  });

  String formatTime(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(date.year, date.month, date.day);

    if (messageDate == today) {
      return intl.DateFormat('hh:mm a').format(date);
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else {
      return intl.DateFormat('MMM d').format(date);
    }
  }

  String? formatLastSeen(Timestamp lastSeen) {
    final now = DateTime.now();
    final lastSeenDate = lastSeen.toDate();
    final difference = now.difference(lastSeenDate);

    if (difference.inMinutes < 1) {
      return "1m";
    } else if (difference.inMinutes < 60) {
      return difference.inMinutes == 1 ? '1m' : '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return difference.inHours == 1 ? '1h' : '${difference.inHours}h';
    } else if (difference.inDays == 1) {
      return "1d";
    } else if (difference.inDays < 7) {
      return difference.inDays == 1 ? '1d' : '${difference.inDays}d';
    } else {
      return null;
    }
  }

  _navigateWithGet() {
    Get.to(
      () => ChatPage(
        receiverId: chat.receiverId,
        receiverName: chat.receiverName,
        receiver:
            receiverData ??
            UserData(
              id: chat.receiverId,
              status: "1",
              isVerified: "1",
              name: chat.receiverName,
              role: "user",
              profilePicture: chat.receiverImage,
              isOnline: chat.isReceiverOnline,
            ),
      ),
    );
  }

  _navigateWithNavigator(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatPage(
          receiverId: chat.receiverId,
          receiverName: chat.receiverName,
          receiver:
              receiverData ??
              UserData(
                id: chat.receiverId,
                status: "1",
                isVerified: "1",
                name: chat.receiverName,
                role: "user",
                profilePicture: chat.receiverImage,
                isOnline: chat.isReceiverOnline,
              ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orangeColor = primaryColor ?? const Color(0xffF39200);
    final isUnread = chat.unreadCount > 0;
    final currentUser = dataManager.getUser();
    final currentUserId = currentUser?.id.toString() ?? '';
    final otherUserId = currentUserId == chat.senderId
        ? chat.receiverId
        : chat.senderId;

    return GestureDetector(
      key: UniqueKey(),
      onTap: () {
        if (navigatorType == NavigatorType.Get) {
          _navigateWithGet();
        } else {
          _navigateWithNavigator(context);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(0),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(otherUserId)
                    .snapshots(),
                builder: (context, snapshot) {
                  bool isOnline = false;
                  Timestamp lastSeen = Timestamp.now();
                  if (snapshot.hasData && snapshot.data != null) {
                    final data = snapshot.data!.data() as Map<String, dynamic>?;
                    isOnline = data?['is_online'] as bool? ?? false;
                    lastSeen =
                        data?['last_seen'] as Timestamp? ?? Timestamp.now();
                  } else {
                    isOnline = chat.isReceiverOnline ?? false;
                  }

                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Image.network(
                          chat.receiverImage != ""
                              ? chat.receiverImage
                              : "https://dovercourt.org/610-6104451_image-placeholder-png-user-profile-placeholder-image-png/",
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
                        ),
                      ),
                      if (isOnline)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        )
                      else if(formatLastSeen(lastSeen) != null)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.white, width: 2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 6,vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.green.withAlpha(100),
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(formatLastSeen(lastSeen)!,style: TextStyle(
                                fontSize: 8
                              ),),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      chat.receiverName,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      chat.lastMessage,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: isUnread
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Time and Unread Badge
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    formatTime(chat.updatedAt.toDate()),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  if (isUnread) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: orangeColor,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 20,
                        minHeight: 20,
                      ),
                      child: Center(
                        child: Text(
                          chat.unreadCount > 99
                              ? '99+'
                              : chat.unreadCount.toString(),
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
