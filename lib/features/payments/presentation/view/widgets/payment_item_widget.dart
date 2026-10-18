import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj_meem/config/app_color.dart';
import 'package:heraj_meem/config/app_font.dart';
import 'package:heraj_meem/ui/shared_widgets/price_widget.dart';
import 'package:intl/intl.dart';
import '../../../data/models/payment_model.dart';

class PaymentItemWidget extends StatelessWidget {
  final PaymentModel payment;

  const PaymentItemWidget({super.key, required this.payment});

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'success':
      case 'completed':
      case 'paid':
        return AppColor.green;
      case 'failed':
      case 'cancelled':
        return AppColor.danger;
      case 'pending':
        return Colors.orange;
      default:
        return AppColor.grey2;
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMM dd, yyyy • HH:mm').format(date);
    } catch (e) {
      return dateString;
    }
  }

  String _getTypeLabel(String type) {
    switch (type.toLowerCase()) {
      case 'customer_plan':
        return 'Customer Plan'.tr;
      case 'vendor_plan':
        return 'Vendor Plan'.tr;
      case 'order':
        return 'Order'.tr;
      default:
        return type;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(payment.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.grey1),
        boxShadow: [
          BoxShadow(
            color: AppColor.grey1.withAlpha(50),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      payment.planName,
                      style: AppFont.font16W700Black,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Gap(4),
                    Text(
                      _getTypeLabel(payment.type),
                      style: AppFont.font12w400Black.copyWith(
                        color: AppColor.grey2,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withAlpha(30),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  payment.status.toUpperCase(),
                  style: AppFont.font12w400Black.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const Gap(16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Amount'.tr,
                    style: AppFont.font12w400Black.copyWith(
                      color: AppColor.grey2,
                    ),
                  ),
                  const Gap(4),
                  PriceWidget(
                    price: payment.amount.toStringAsFixed(2),
                    style: AppFont.font18W700Black,
                    textColor: AppColor.primary,
                    currencySize: 20,
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Order ID'.tr,
                    style: AppFont.font12w400Black.copyWith(
                      color: AppColor.grey2,
                    ),
                  ),
                  const Gap(4),
                  Text(
                    payment.orderId,
                    style: AppFont.font12w400Black,
                  ),
                ],
              ),
            ],
          ),
          const Gap(12),
          Divider(height: 1, color: AppColor.grey1),
          const Gap(12),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 16, color: AppColor.grey2),
              const Gap(8),
              Expanded(
                child: Text(
                  _formatDate(payment.createdAt),
                  style: AppFont.font12w400Black.copyWith(
                    color: AppColor.grey2,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

