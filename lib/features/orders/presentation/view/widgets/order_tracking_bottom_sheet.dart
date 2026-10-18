import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj_meem/config/app_font.dart';
import '../../../data/models/order_model.dart';

class OrderTrackingBottomSheet extends StatelessWidget {
  const OrderTrackingBottomSheet({super.key, required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    final status = (order.status ?? '').toLowerCase();
    final isConfirmed = status == 'pending' || status == 'processing' || status == 'out_for_delivery' || status == 'delivered';
    final isShipped = status == 'processing' || status == 'out_for_delivery' || status == 'delivered';
    final isOutForDelivery = status == 'out_for_delivery' || status == 'delivered';
    final isDelivered = status == 'delivered';

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
                const Spacer(),
                Text('Order Tracking'.tr, style: AppFont.font16W600Black),
                const Spacer(),
                const SizedBox(width: 40),
              ],
            ),
            const Gap(8),
            _stepTile(
              title: 'Order confirmed'.tr,
              subtitle: 'Your order has been confirmed'.tr,
              done: isConfirmed,
              time: _formatTime(order.createdAt),
            ),
            const Gap(8),
            _stepTile(
              title: 'Order shipped'.tr,
              subtitle: 'Your order has been shipped'.tr,
              done: isShipped,
              time: _formatTime(order.updatedAt),
            ),
            const Gap(8),
            _stepTile(
              title: 'Out for delivery'.tr,
              subtitle: 'Courier is on the way'.tr,
              done: isOutForDelivery,
            ),
            const Gap(8),
            _stepTile(
              title: 'Delivered'.tr,
              subtitle: 'Package delivered to address'.tr,
              done: isDelivered,
            ),
            const Gap(8),
          ],
        ),
      ),
    );
  }

  Widget _stepTile({required String title, required String subtitle, required bool done, String? time}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          done ? Icons.check_circle : Icons.radio_button_unchecked,
          color: done ? Colors.green : AppColor.grey2,
          size: 22,
        ),
        const Gap(10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text(title, style: AppFont.font14W700Black)),
                  if (time != null) Text(time, style: AppFont.font12w500Grey2),
                ],
              ),
              Text(subtitle, style: AppFont.font12w500Grey2),
            ],
          ),
        )
      ],
    );
  }

  String? _formatTime(String? iso) {
    if (iso == null || iso.isEmpty) return null;
    try {
      final dt = DateTime.tryParse(iso);
      if (dt == null) return null;
      final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
      final m = dt.minute.toString().padLeft(2, '0');
      final ampm = dt.hour >= 12 ? 'PM' : 'AM';
      return '$h:$m $ampm';
    } catch (_) {
      return null;
    }
  }
}


