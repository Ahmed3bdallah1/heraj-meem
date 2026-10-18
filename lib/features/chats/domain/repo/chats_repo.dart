import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../entities/chat_entity.dart';
import '../../data/models/messages_paginated_model.dart';

abstract class ChatsRepo {
  Future<Either<Failure, List<ChatEntity>>> getChats();
  Future<Either<Failure, MessagesPaginatedModel>> getChatMessages(String chatId, {int page = 1, int limit = 50});
  Future<Either<Failure, void>> sendMessage(String chatId, String content, {List<String>? attachments, String? productId});
  Future<Either<Failure, void>> markChatAsRead(String chatId);
  Future<Either<Failure, ChatEntity>> createChat({
    required String userId,
    required String participantId,
    String? productId,
  });
}

