import '../../../../../config/api_path.dart';
import '../../../../../core/service/webservice/dio_helper.dart';
import '../models/notifications_model.dart';

abstract class NotificationDataSource {
  Future<NotificationPaginatedResponse> getNotification({
    int page = 1,
    int limit = 50,
  });
  Future<bool> seen(String id);
  Future<int> getUnreadCount();
  Future<bool> markAllAsRead();
}

class NotificationDataSourceImp extends NotificationDataSource {
  final ApiService apiService;

  NotificationDataSourceImp({required this.apiService});

  @override
  Future<NotificationPaginatedResponse> getNotification({
    int page = 1,
    int limit = 50,
  }) async {
    final res = await apiService.get<Map<String, dynamic>>(
      url: '${ApiPath.notifications}?page=$page&limit=$limit',
      returnDataOnly: true,
    );
    
    final data = res['data'] as Map<String, dynamic>? ?? res;
    final List<dynamic> notificationsList = data['notifications'] as List<dynamic>? ?? [];
    final paginationData = data['pagination'] as Map<String, dynamic>? ?? {};
    
    final List<NotificationModel> notifications = notificationsList
        .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
        .toList();
    
    final pagination = NotificationPagination.fromJson(paginationData);
    
    return NotificationPaginatedResponse(
      notifications: notifications,
      pagination: pagination,
    );
  }

  @override
  Future<bool> seen(String id) async {
    await apiService.patch(
      url: '${ApiPath.notifications}/$id/read',
    );
    return true;
  }

  @override
  Future<int> getUnreadCount() async {
    final res = await apiService.get(
      url: ApiPath.notificationsUnreadCount,
      returnDataOnly: true,
    );
    return res['count'] as int? ?? 0;
  }

  @override
  Future<bool> markAllAsRead() async {
    await apiService.patch(
      url: ApiPath.notificationsReadAll,
    );
    return true;
  }
}
