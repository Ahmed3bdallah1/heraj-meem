import 'package:fpdart/fpdart.dart';
import '../../../../../core/errors/failure.dart';
import '../../../../../core/use_cases/use_case.dart';
import '../entities/notification_entity.dart';
import '../repos/notification_repo.dart';

class FetchNotificationUseCase
    extends UseCaseParam<List<NotificationEntity>, Map<String, dynamic>> {
  final NotificationRepo notificationRepo;

  FetchNotificationUseCase({required this.notificationRepo});

  @override
  Future<Either<Failure, List<NotificationEntity>>> call(
      Map<String, dynamic>? param) async {
    final page = param?['page'] is int 
        ? param!['page'] as int 
        : (int.tryParse(param?['page']?.toString() ?? '1') ?? 1);
    final limit = param?['limit'] is int 
        ? param!['limit'] as int 
        : (int.tryParse(param?['limit']?.toString() ?? '50') ?? 50);
    
    final res = await notificationRepo.getNotifications(
      page: page,
      limit: limit,
    );
    return res;
  }
}
