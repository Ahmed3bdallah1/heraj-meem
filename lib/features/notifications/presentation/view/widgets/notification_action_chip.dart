import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import '../../../../../../config/app_font.dart';
import '../../managers/notifications_filter.dart';

class NotificationsCustomActionChip extends ConsumerWidget {
  const NotificationsCustomActionChip({
    super.key,
    required this.value,
    this.alwaysActive = false,
  });

  final NotificationFilterType value;
  final bool alwaysActive;

  @override
  Widget build(BuildContext context, ref) {
    final isSelected =
        alwaysActive || ref.watch(notificationsProvider)['status'] == value.key;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: ActionChip(
          onPressed: () {
            ref.read(notificationsProvider.notifier).updateStatus(value);
          },
          label: Text(
            value.name.tr,
            style: AppFont.labelTextField.copyWith(
                color: !isSelected ? AppColor.black : AppColor.grey1,
                fontSize: 14),
          ),
          backgroundColor:
          (isSelected ? AppColor.primary : AppColor.grey1.withOpacity(.4))),
    );
  }
}