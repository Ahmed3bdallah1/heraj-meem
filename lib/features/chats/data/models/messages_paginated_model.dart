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
    final page = (json['page'] as num?)?.toInt() ?? 1;
    final limit = (json['limit'] as num?)?.toInt() ?? 50;
    final total = (json['total'] as num?)?.toInt() ?? 0;
    final totalPages = (json['totalPages'] as num?)?.toInt() ??
        (limit == 0 ? 1 : (total / limit).ceil().clamp(1, 1 << 30));
    return MessagesPagination(
      page: page,
      limit: limit,
      total: total,
      totalPages: totalPages,
      hasMore: json.containsKey('hasMore')
          ? json['hasMore'] == true
          : page < totalPages && total > 0,
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
    final data = json['data'];
    final Map<String, dynamic> payload = data is Map
        ? Map<String, dynamic>.from(data)
        : json;
    final rawMessages = data is List
        ? data
        : payload['items'] ??
            payload['messages'] ??
            (payload['data'] is List ? payload['data'] : null);
    final paginationRaw = payload['pagination'] ?? json['pagination'];
    return MessagesPaginatedModel(
      messages: rawMessages is List
          ? rawMessages
              .whereType<Map>()
              .map((item) =>
                  MessageModel.fromJson(Map<String, dynamic>.from(item)))
              .toList()
          : [],
      pagination: MessagesPagination.fromJson(
        paginationRaw is Map
            ? Map<String, dynamic>.from(paginationRaw)
            : payload,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': messages.map((m) => (m as MessageModel).toJson()).toList(),
      'pagination': pagination.toJson(),
    };
  }
}

