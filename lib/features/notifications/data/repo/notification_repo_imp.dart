import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../../core/errors/failure.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repos/notification_repo.dart';
import '../data_source/notification_data_source.dart';

class NotificationRepoImp extends NotificationRepo {
  final NotificationDataSource notificationDataSource;

  NotificationRepoImp({required this.notificationDataSource});

  @override
  Future<Either<Failure, List<NotificationEntity>>> getNotifications({
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final res = await notificationDataSource.getNotification(
        page: page,
        limit: limit,
      );
      return Right(res.notifications
          .map((model) => NotificationEntity.fromNotificationModel(model))
          .toList());
    } catch (e) {
      if (e is DioException) {
        return Left(ServerFailure.fromDioError(e));
      } else {
        return Left(GeneralError(e));
      }
    }
  }

  @override
  Future<Either<Failure, bool>> seen(String id) async {
    try {
      final res = await notificationDataSource.seen(id);
      return Right(res);
    } catch (e) {
      if (e is DioException) {
        return Left(ServerFailure.fromDioError(e));
      } else {
        return Left(GeneralError(e));
      }
    }
  }

  @override
  Future<Either<Failure, int>> getUnreadCount() async {
    try {
      final res = await notificationDataSource.getUnreadCount();
      return Right(res);
    } catch (e) {
      if (e is DioException) {
        return Left(ServerFailure.fromDioError(e));
      } else {
        return Left(GeneralError(e));
      }
    }
  }

  @override
  Future<Either<Failure, bool>> markAllAsRead() async {
    try {
      final res = await notificationDataSource.markAllAsRead();
      return Right(res);
    } catch (e) {
      if (e is DioException) {
        return Left(ServerFailure.fromDioError(e));
      } else {
        return Left(GeneralError(e));
      }
    }
  }
}
