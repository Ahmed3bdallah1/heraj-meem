import 'participant_entity.dart';

class LastMessage {
  final String content;
  final String senderId;
  final DateTime createdAt;

  LastMessage({
    required this.content,
    required this.senderId,
    required this.createdAt,
  });

  factory LastMessage.fromJson(Map<String, dynamic> json) {
    return LastMessage(
      content: json['content']?.toString() ?? '',
      senderId: json['senderId']?.toString() ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }
}

class ChatEntity {
  final String id;
  final List<ParticipantEntity> participants;
  final LastMessage? lastMessage;
  final Map<String, int> unreadCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  ChatEntity({
    required this.id,
    required this.participants,
    this.lastMessage,
    required this.unreadCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ChatEntity.fromJson(Map<String, dynamic> json) {
    return ChatEntity(
      id: json['_id']?.toString() ?? '',
      participants: (json['participants'] as List<dynamic>?)
              ?.map((p) => ParticipantEntity.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [],
      lastMessage: json['lastMessage'] != null
          ? LastMessage.fromJson(json['lastMessage'] as Map<String, dynamic>)
          : null,
      unreadCount: (json['unreadCount'] as Map<String, dynamic>?)
              ?.map((key, value) => MapEntry(key, (value as num).toInt()))
              .cast<String, int>() ??
          {},
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  ParticipantEntity? getOtherParticipant(String currentUserId) {
    try {
      return participants.firstWhere(
        (p) => p.userId?.id != currentUserId,
        orElse: () => participants.first,
      );
    } catch (e) {
      return participants.isNotEmpty ? participants.first : null;
    }
  }

  // Get unread count for current user
  int getUnreadCountForUser(String userId) {
    return unreadCount[userId] ?? 0;
  }
}

