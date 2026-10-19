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
    final res = await apiService.get<dynamic>(
      url: ApiPath.getChats,
      returnDataOnly: true,
    );
    final rawChats = _conversationList(res);
    return rawChats
        .whereType<Map>()
        .map((item) => ChatEntity.fromJson(Map<String, dynamic>.from(item)))
        .where((chat) => chat.id.isNotEmpty)
        .toList();
  }

  List<dynamic> _conversationList(dynamic res) {
    if (res is List) return res;
    if (res is! Map) return [];
    final raw = res['items'] ?? res['conversations'] ?? res['chats'];
    return raw is List ? raw : [];
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
        'body': content,
        if (attachments != null && attachments.isNotEmpty)
          'attachments': attachments,
        if (productId != null) 'adId': productId,
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
    final res = await apiService.post<dynamic>(
      url: ApiPath.createChat,
      requestBody: {
        'recipientId': participantId,
        if (productId != null) 'adId': productId,
      },
      returnDataOnly: true,
    );

    return ChatEntity.fromJson(_conversationMap(res));
  }

  Map<String, dynamic> _conversationMap(dynamic res) {
    if (res is! Map) return {};
    final nested = res['conversation'] ?? res['chat'];
    if (nested is Map) return Map<String, dynamic>.from(nested);
    return Map<String, dynamic>.from(res);
  }
}
