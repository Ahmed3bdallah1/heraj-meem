import '../../data/models/notifications_model.dart';

class NotificationEntity {
  final String id;
  final String title;
  final String image;
  final String message;
  final bool isRead;
  final String relatedId;
  final String link;
  final String type;

  NotificationEntity({
    required this.id,
    required this.title,
    required this.image,
    required this.message,
    required this.isRead,
    required this.relatedId,
    required this.link,
    required this.type,
  });

  factory NotificationEntity.fromNotificationModel(NotificationModel model) {
    return NotificationEntity(
      id: model.id,
      title: model.title,
      image: model.image,
      message: model.message,
      isRead: model.isRead,
      relatedId: model.relatedId,
      link: model.link,
      type: model.type,
    );
  }
}
