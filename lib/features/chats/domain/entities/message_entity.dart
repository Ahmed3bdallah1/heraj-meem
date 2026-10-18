import 'user_info_entity.dart';
import 'product_info_entity.dart';

enum MessageType {
  text,
  product,
  image,
}

class MessageEntity {
  final String id;
  final String chatId;
  final UserInfoEntity senderId;
  final String content;
  final MessageType type;
  final ProductInfoEntity? productId;
  final List<String> attachments;
  final bool isRead;
  final DateTime createdAt;
  final DateTime updatedAt;

  MessageEntity({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.content,
    required this.type,
    this.productId,
    required this.attachments,
    required this.isRead,
    required this.createdAt,
    required this.updatedAt,
  });
}

