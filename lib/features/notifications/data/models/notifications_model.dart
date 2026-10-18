class NotificationPaginatedResponse {
  final List<NotificationModel> notifications;
  final NotificationPagination pagination;

  NotificationPaginatedResponse({
    required this.notifications,
    required this.pagination,
  });
}

class NotificationPagination {
  final int page;
  final int limit;
  final int total;
  final int pages;

  NotificationPagination({
    required this.page,
    required this.limit,
    required this.total,
    required this.pages,
  });

  factory NotificationPagination.fromJson(Map<String, dynamic> json) {
    return NotificationPagination(
      page: json['page'] is int ? json['page'] : (int.tryParse(json['page']?.toString() ?? '1') ?? 1),
      limit: json['limit'] is int ? json['limit'] : (int.tryParse(json['limit']?.toString() ?? '50') ?? 50),
      total: json['total'] is int ? json['total'] : (int.tryParse(json['total']?.toString() ?? '0') ?? 0),
      pages: json['pages'] is int ? json['pages'] : (int.tryParse(json['pages']?.toString() ?? '1') ?? 1),
    );
  }
}

class NotificationModel {
  final String id;
  final String userId;
  final String type;
  final String title;
  final String message;
  final String link;
  final String image;
  final bool isRead;
  final String relatedId;
  final Map<String, dynamic> data;
  final String createdAt;
  final String updatedAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    required this.link,
    required this.image,
    required this.isRead,
    required this.relatedId,
    required this.data,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      NotificationModel(
        id: json["_id"]?.toString() ?? json["id"]?.toString() ?? '',
        userId: json["userId"]?.toString() ?? '',
        type: json["type"]?.toString() ?? '',
        title: json["title"]?.toString() ?? '',
        message: json["message"]?.toString() ?? '',
        link: json["link"]?.toString() ?? '',
        image: json["image"]?.toString() ?? '',
        isRead: json["isRead"] is bool
            ? json["isRead"]
            : (json["isRead"]?.toString().toLowerCase() == 'true' || json["isRead"] == 1),
        relatedId: json["relatedId"]?.toString() ?? '',
        data: json["data"] is Map<String, dynamic>
            ? json["data"] as Map<String, dynamic>
            : (json["data"] != null ? {'value': json["data"]} : {}),
        createdAt: json["createdAt"]?.toString() ?? json["created_at"]?.toString() ?? DateTime.now().toIso8601String(),
        updatedAt: json["updatedAt"]?.toString() ?? json["updated_at"]?.toString() ?? DateTime.now().toIso8601String(),
      );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "userId": userId,
    "type": type,
    "title": title,
    "message": message,
    "link": link,
    "image": image,
    "isRead": isRead,
    "relatedId": relatedId,
    "data": data,
    "createdAt": createdAt,
    "updatedAt": updatedAt,
  };
}
