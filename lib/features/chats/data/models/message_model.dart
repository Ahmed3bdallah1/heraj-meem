import '../../domain/entities/message_entity.dart';
import 'product_info_model.dart';
import 'user_info_model.dart';

class MessageModel extends MessageEntity {
  MessageModel({
    required super.id,
    required super.chatId,
    required super.senderId,
    required super.content,
    required super.type,
    super.productId,
    required super.attachments,
    required super.isRead,
    required super.createdAt,
    required super.updatedAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    MessageType messageType = MessageType.text;
    final typeStr = json['type']?.toString() ?? 'text';
    switch (typeStr.toLowerCase()) {
      case 'product':
        messageType = MessageType.product;
        break;
      case 'image':
        messageType = MessageType.image;
        break;
      default:
        messageType = MessageType.text;
    }

    return MessageModel(
      id: json['_id']?.toString() ?? '',
      chatId: json['chatId']?.toString() ?? '',
      senderId: UserInfoModel.fromJson(
          json['senderId'] as Map<String, dynamic>? ?? {}),
      content: json['content']?.toString() ?? '',
      type: messageType,
      productId: json['productId'] != null
          ? ProductInfoModel.fromJson(
              json['productId'] as Map<String, dynamic>)
          : null,
      attachments: (json['attachments'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      isRead: json['isRead'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'chatId': chatId,
      'senderId': (senderId as UserInfoModel).toJson(),
      'content': content,
      'type': type.name,
      if (productId != null)
        'productId': (productId as ProductInfoModel).toJson(),
      'attachments': attachments,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

