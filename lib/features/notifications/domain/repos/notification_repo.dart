import 'package:fpdart/fpdart.dart';
import '../../../../../core/errors/failure.dart';
import '../entities/notification_entity.dart';

abstract class NotificationRepo {
  Future<Either<Failure, List<NotificationEntity>>> getNotifications({
    int page = 1,
    int limit = 50,
  });
  Future<Either<Failure, bool>> seen(String id);
  Future<Either<Failure, int>> getUnreadCount();
  Future<Either<Failure, bool>> markAllAsRead();
}
