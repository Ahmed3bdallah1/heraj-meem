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
    final sender = json['sender'] ?? json['senderId'];
    final senderId = sender is Map
        ? (sender['id'] ?? sender['_id'])?.toString() ?? ''
        : sender?.toString() ?? '';
    return LastMessage(
      content: json['body']?.toString() ?? json['content']?.toString() ?? '',
      senderId: senderId,
      createdAt: _date(json['createdAt']),
    );
  }
}

DateTime _date(dynamic value) {
  if (value == null) return DateTime.now();
  return DateTime.tryParse(value.toString()) ?? DateTime.now();
}

class ChatEntity {
  final String id;
  final List<ParticipantEntity> participants;
  final LastMessage? lastMessage;
  final Map<String, int> unreadCount;
  final int? unread;
  final DateTime createdAt;
  final DateTime updatedAt;

  ChatEntity({
    required this.id,
    required this.participants,
    this.lastMessage,
    required this.unreadCount,
    this.unread,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ChatEntity.fromJson(Map<String, dynamic> json) {
    final rawUnread = json['unreadCount'] ?? json['unread'];
    Map<String, int> unreadCount = {};
    int? unread;
    if (rawUnread is Map) {
      unreadCount = rawUnread.map(
        (key, value) => MapEntry(key.toString(), (value as num?)?.toInt() ?? 0),
      );
    } else if (rawUnread is num) {
      unread = rawUnread.toInt();
    }

    final lastRaw = json['lastMessage'] ?? json['latestMessage'];
    return ChatEntity(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      participants: _participants(json),
      lastMessage: lastRaw is Map
          ? LastMessage.fromJson(Map<String, dynamic>.from(lastRaw))
          : lastRaw is String
              ? LastMessage(
                  content: lastRaw,
                  senderId: '',
                  createdAt: _date(json['updatedAt']),
                )
              : null,
      unreadCount: unreadCount,
      unread: unread,
      createdAt: _date(json['createdAt']),
      updatedAt: _date(json['updatedAt']),
    );
  }

  static List<ParticipantEntity> _participants(Map<String, dynamic> json) {
    final raw = json['participants'] ?? json['members'];
    if (raw is List && raw.isNotEmpty) {
      return raw
          .whereType<Map>()
          .map((item) =>
              ParticipantEntity.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }
    final found = <ParticipantEntity>[];
    for (final key in [
      'otherUser',
      'recipient',
      'participant',
      'buyer',
      'seller',
      'user',
    ]) {
      final value = json[key];
      if (value is Map) {
        found.add(ParticipantEntity.fromJson(Map<String, dynamic>.from(value)));
      }
    }
    return found;
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
    if (unread != null) return unread!;
    return unreadCount[userId] ?? 0;
  }
}

