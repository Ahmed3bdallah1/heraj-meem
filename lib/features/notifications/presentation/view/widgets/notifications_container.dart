import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import '../../../../../../config/app_font.dart';
import '../../../../../../core/service/loading_provider.dart';
import '../../../../../../main.dart';
import '../../../../../../ui/ui.dart';
import '../../../../ads/presentation/view/ad_details_screen.dart';
import '../../../domain/entities/notification_entity.dart';
import '../../../domain/use_case/fetch_seen_use_case.dart';
import '../../managers/fetch_notificatons_provider.dart';

class NotificationContainer extends ConsumerWidget {
  final NotificationEntity notificationEntity;

  const NotificationContainer({super.key, required this.notificationEntity});

  static IconData _iconForType(String type) {
    switch (type.toLowerCase()) {
      case 'order':
        return Icons.receipt_long_rounded;
      case 'product':
        return Icons.inventory_2_outlined;
      case 'chat':
        return Icons.chat_bubble_outline_rounded;
      case 'cart':
        return Icons.shopping_cart_outlined;
      default:
        return Icons.notifications_active_rounded;
    }
  }

  void _navigateFromNotification(NotificationEntity entity) {
    final link = entity.link.toLowerCase();
    final type = entity.type.toLowerCase();
    final relatedId = entity.relatedId;
    if (relatedId.isEmpty) return;
    if (type == 'order' || link.contains('order')) {
      Get.toNamed('/orders', arguments: {'openOrderId': relatedId});
    } else if (type == 'product' || link.contains('product')) {
      Get.to(() => AdDetailsScreen(productId: relatedId));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () async {
        if (!notificationEntity.isRead) {
          try {
            ref
                .read(
                    isLoadingProvider("Seen${notificationEntity.id}").notifier)
                .state = true;
            final history = await getIt<SeenNotificationUseCase>()
                .call(notificationEntity.id);
            history.fold((l) {
              ref
                  .read(isLoadingProvider("Seen${notificationEntity.id}")
                      .notifier)
                  .state = false;
              UIHelper.showAlert(l.message, type: DialogType.error);
            }, (r) {
              ref.invalidate(fetchNotificationsProvider);
              ref.invalidate(unreadNotificationCountProvider);
            });
          } finally {
            ref
                .read(
                    isLoadingProvider("Seen${notificationEntity.id}").notifier)
                .state = false;
          }
        }
        _navigateFromNotification(notificationEntity);
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(35),
            border: Border.all(color: AppColor.grey1)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      color: AppColor.primary.withOpacity(.2),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: AppColor.primary.withOpacity(0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      _iconForType(notificationEntity.type),
                      size: 26,
                      color: AppColor.primary,
                    ),
                  ),
                  const Gap(10),
                  Flexible(
                    child: Text(
                      notificationEntity.title,
                      style: AppFont.font15W500Black,
                    ),
                  ),
                ],
              ),
              const Gap(15),
              Text(
                notificationEntity.message,
                style: AppFont.font12w400Black,
              ),
              const Gap(10),
            ],
          ),
        ),
      ),
    );
  }
}
