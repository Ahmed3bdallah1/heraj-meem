import '../../domain/entities/message_entity.dart';
import '../../domain/entities/user_info_entity.dart';
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
    final attachments = _attachments(json['attachments']);
    MessageType messageType = MessageType.text;
    final typeStr = json['type']?.toString() ??
        (attachments.isNotEmpty ? 'image' : 'text');
    switch (typeStr.toLowerCase()) {
      case 'product':
      case 'ad':
        messageType = MessageType.product;
        break;
      case 'image':
        messageType = MessageType.image;
        break;
      default:
        messageType = attachments.isNotEmpty
            ? MessageType.image
            : MessageType.text;
    }

    final productRaw = json['ad'] ??
        json['product'] ??
        (json['productId'] is Map ? json['productId'] : null);
    final createdAt = DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
        DateTime.now();

    return MessageModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      chatId: json['conversationId']?.toString() ??
          json['chatId']?.toString() ??
          '',
      senderId: UserInfoModel.fromJson(json['sender'] ?? json['senderId']),
      content: json['body']?.toString() ?? json['content']?.toString() ?? '',
      type: messageType,
      productId: productRaw is Map
          ? ProductInfoModel.fromJson(Map<String, dynamic>.from(productRaw))
          : null,
      attachments: attachments,
      isRead: json['isRead'] == true || json['readAt'] != null,
      createdAt: createdAt,
      updatedAt:
          DateTime.tryParse(json['updatedAt']?.toString() ?? '') ?? createdAt,
    );
  }

  static List<String> _attachments(dynamic raw) {
    if (raw is! List) return [];
    return raw
        .map((item) {
          if (item is Map) {
            return chatMediaUrl(
              item['url']?.toString() ?? item['path']?.toString(),
            );
          }
          return chatMediaUrl(item.toString());
        })
        .where((url) => url.isNotEmpty)
        .toList();
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

