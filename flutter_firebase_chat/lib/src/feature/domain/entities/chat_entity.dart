import 'package:cloud_firestore/cloud_firestore.dart';

class ChatEntity {
  final String senderId;
  final String receiverId;
  final String receiverName;
  final String receiverImage;
  final String lastMessage;
  final Timestamp createdAt;
  final Timestamp updatedAt;
  final int unreadCount;
  final bool? isReceiverOnline;

  ChatEntity({
    required this.senderId,
    required this.receiverId,
    required this.receiverName,
    required this.receiverImage,
    required this.lastMessage,
    required this.createdAt,
    required this.updatedAt,
    this.unreadCount = 0,
    this.isReceiverOnline,
  });

  factory ChatEntity.fromJson(Map<String, dynamic> json) {
    return ChatEntity(
      senderId: json['senderId'] ?? "",
      receiverId: json['receiverId'] ?? "",
      receiverName: json['receiverName'] ?? "",
      receiverImage: json['receiverImage'] ?? "",
      lastMessage: json['lastMessage'] ?? "",
      createdAt: json['createdAt'] is Timestamp
          ? json['createdAt']
          : Timestamp.now(),
      updatedAt: json['updatedAt'] is Timestamp
          ? json['updatedAt']
          : Timestamp.now(),
      unreadCount: json['unreadCount'] ?? 0,
      isReceiverOnline: json['isReceiverOnline'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "senderId": senderId,
      "receiverId": receiverId,
      "receiverName": receiverName,
      "receiverImage": receiverImage,
      "lastMessage": lastMessage,
      "createdAt": createdAt,
      "updatedAt": updatedAt,
      "unreadCount": unreadCount,
      "isReceiverOnline": isReceiverOnline,
    };
  }

  ChatEntity copyWith({
    String? senderId,
    String? receiverId,
    String? receiverImage,
    String? receiverName,
    String? lastMessage,
    Timestamp? createdAt,
    Timestamp? updatedAt,
    int? unreadCount,
    bool? isReceiverOnline,
  }) {
    return ChatEntity(
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      receiverName: receiverName ?? this.receiverName,
      receiverImage: receiverImage ?? this.receiverImage,
      lastMessage: lastMessage ?? this.lastMessage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      unreadCount: unreadCount ?? this.unreadCount,
      isReceiverOnline: isReceiverOnline ?? this.isReceiverOnline,
    );
  }
}
