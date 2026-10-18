import '../../../../config/api_path.dart';
import '../../../../core/service/webservice/dio_helper.dart';
import '../../domain/entities/chat_entity.dart';
import '../models/messages_paginated_model.dart';

abstract class ChatsDataSource {
  Future<List<ChatEntity>> getChats();
  Future<MessagesPaginatedModel> getChatMessages(String chatId,
      {int page = 1, int limit = 50});
  Future<void> sendMessage(String chatId, String content,
      {List<String>? attachments, String? productId});
  Future<void> markChatAsRead(String chatId);
  Future<ChatEntity> createChat({
    required String userId,
    required String participantId,
    String? productId,
  });
}

class ChatsDataSourceImpl implements ChatsDataSource {
  final ApiService apiService;

  ChatsDataSourceImpl({required this.apiService});

  @override
  Future<List<ChatEntity>> getChats() async {
    final res = await apiService.get<Map<String, dynamic>?>(
      url: ApiPath.getChats,
      returnDataOnly: true,
    );
    final rawChats = res?['chats'];
    if (rawChats == null || rawChats is! List) {
      return [];
    }
    final validChats = rawChats.where((e) {
      if (e == null || e is! Map<String, dynamic>) return false;
      final participants = (e['participants'] as List<dynamic>?);
      if (participants == null) return false;
      final hasNullUserId =
          participants.any((p) => p is Map && p['userId'] == null);
      return !hasNullUserId;
    });
    return List<ChatEntity>.from(
      validChats.map((e) => ChatEntity.fromJson(e as Map<String, dynamic>)),
    );
  }

  @override
  Future<MessagesPaginatedModel> getChatMessages(String chatId,
      {int page = 1, int limit = 50}) async {
    final res = await apiService.get<Map<String, dynamic>>(
      url: '${ApiPath.getChatMessages(chatId)}?page=$page&limit=$limit',
      returnDataOnly: false,
    );
    return MessagesPaginatedModel.fromJson(res);
  }

  @override
  Future<void> sendMessage(String chatId, String content,
      {List<String>? attachments, String? productId}) async {
    await apiService.post(
      url: ApiPath.sendMessage(chatId),
      requestBody: {
        'content': content,
        if (attachments != null && attachments.isNotEmpty)
          'attachments': attachments,
        if (productId != null) 'productId': productId,
      },
      returnDataOnly: false,
    );
  }

  @override
  Future<void> markChatAsRead(String chatId) async {
    await apiService.patch(
      url: ApiPath.markChatAsRead(chatId),
      returnDataOnly: false,
    );
  }

  @override
  Future<ChatEntity> createChat({
    required String userId,
    required String participantId,
    String? productId,
  }) async {
    final formData = <String, dynamic>{
      // 'userId': userId,
      'participantId': participantId,
      if (productId != null) 'productId': productId,
    };

    final res = await apiService.post<Map<String, dynamic>>(
      url: ApiPath.createChat,
      requestBody: formData,
      returnDataOnly: true,
    );

    // The response structure is { "chat": {...} }
    final chatData = res['chat'] as Map<String, dynamic>;
    return ChatEntity.fromJson(chatData);
  }
}
