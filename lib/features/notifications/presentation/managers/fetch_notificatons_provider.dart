import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../main.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/use_case/fetch_notifications_use_case.dart';
import '../../domain/use_case/get_unread_count_use_case.dart';
import 'notifications_filter.dart';

final fetchNotificationsProvider =
    FutureProvider.autoDispose<List<NotificationEntity>>((ref) async {
  final attribute = ref.watch(notificationsProvider);

  final notes = await getIt<FetchNotificationUseCase>().call(attribute);

  return notes.fold((l) {
    throw l;
  }, (r) {
    return r;
  });
});

final unreadNotificationCountProvider =
    FutureProvider.autoDispose<int>((ref) async {
  final count = await getIt<GetUnreadCountUseCase>().call();

  return count.fold((l) {
    throw l;
  }, (r) {
    return r;
  });
});
