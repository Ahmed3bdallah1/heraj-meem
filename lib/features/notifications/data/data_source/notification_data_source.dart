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
    final res = await apiService.get(
      url: '${ApiPath.notifications}?page=$page&limit=$limit',
      returnDataOnly: true,
    );

    final List<dynamic> notificationsList;
    Map<String, dynamic> paginationData = {};
    if (res is List) {
      notificationsList = res;
    } else if (res is Map) {
      final data = Map<String, dynamic>.from(res);
      final nested = data['notifications'] ?? data['items'] ?? data['data'];
      notificationsList = nested is List ? nested : const [];
      final pagination = data['pagination'];
      if (pagination is Map) {
        paginationData = Map<String, dynamic>.from(pagination);
      }
    } else {
      notificationsList = const [];
    }
    
    final List<NotificationModel> notifications = notificationsList
        .whereType<Map>()
        .map((e) => NotificationModel.fromJson(Map<String, dynamic>.from(e)))
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
    if (res is int) return res;
    if (res is num) return res.toInt();
    if (res is Map) {
      final count = res['count'] ?? res['unread'] ?? res['unreadCount'];
      if (count is int) return count;
      return int.tryParse(count?.toString() ?? '') ?? 0;
    }
    return 0;
  }

  @override
  Future<bool> markAllAsRead() async {
    await apiService.patch(
      url: ApiPath.notificationsReadAll,
    );
    return true;
  }
}
