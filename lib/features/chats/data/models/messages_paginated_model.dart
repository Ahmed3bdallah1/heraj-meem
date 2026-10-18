import '../../domain/entities/message_entity.dart';
import 'message_model.dart';

class MessagesPagination {
  final int page;
  final int limit;
  final int total;
  final int totalPages;
  final bool hasMore;

  MessagesPagination({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
    required this.hasMore,
  });

  factory MessagesPagination.fromJson(Map<String, dynamic> json) {
    return MessagesPagination(
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 50,
      total: json['total'] ?? 0,
      totalPages: json['totalPages'] ?? 1,
      hasMore: json['hasMore'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'limit': limit,
      'total': total,
      'totalPages': totalPages,
      'hasMore': hasMore,
    };
  }
}

class MessagesPaginatedModel {
  final List<MessageEntity> messages;
  final MessagesPagination pagination;

  MessagesPaginatedModel({
    required this.messages,
    required this.pagination,
  });

  factory MessagesPaginatedModel.fromJson(Map<String, dynamic> json) {
    return MessagesPaginatedModel(
      messages: (json['data'] as List<dynamic>?)
              ?.map((item) =>
                  MessageModel.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      pagination: MessagesPagination.fromJson(
          json['pagination'] as Map<String, dynamic>? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': messages.map((m) => (m as MessageModel).toJson()).toList(),
      'pagination': pagination.toJson(),
    };
  }
}

