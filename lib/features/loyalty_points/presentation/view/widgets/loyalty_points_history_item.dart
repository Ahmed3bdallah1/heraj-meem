import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import '../../../../../config/app_font.dart';
import '../../../../../helper/responsive.dart';
import '../../../data/models/loyalty_points_model.dart';

/// Widget displaying a single loyalty points history item
class LoyaltyPointsHistoryItemWidget extends StatelessWidget {
  final LoyaltyPointsHistoryItem historyItem;

  const LoyaltyPointsHistoryItemWidget({
    super.key,
    required this.historyItem,
  });

  @override
  Widget build(BuildContext context) {
    responsiveInit(context);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColor.grey1),
      ),
      child: Row(
        children: [
          // Icon indicating earned or spent
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: historyItem.isEarned
                  ? AppColor.green.withOpacity(0.1)
                  : AppColor.danger.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              historyItem.isEarned ? Icons.add_circle_outline : Icons.remove_circle_outline,
              color: historyItem.isEarned ? AppColor.green : AppColor.danger,
              size: 24.sp,
            ),
          ),
          Gap(12.w),
          // Description and date
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  historyItem.description ?? historyItem.type.tr,
                  style: AppFont.font14W700Black,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Gap(4.h),
                Text(
                  _formatDate(historyItem.createdAt),
                  style: AppFont.font12W400Grey1,
                ),
              ],
            ),
          ),
          Gap(12.w),
          // Points amount
          Text(
            '${historyItem.isEarned ? '+' : ''}${historyItem.points}',
            style: AppFont.font16W700Primary.copyWith(
              color: historyItem.isEarned ? AppColor.green : AppColor.danger,
            ),
          ),
        ],
      ),
    );
  }

  /// Formats the date string to a readable format
  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        if (difference.inHours == 0) {
          return '${difference.inMinutes} ${'minutes ago'.tr}';
        }
        return '${difference.inHours} ${'hours ago'.tr}';
      } else if (difference.inDays == 1) {
        return 'Yesterday'.tr;
      } else if (difference.inDays < 7) {
        return '${difference.inDays} ${'days ago'.tr}';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return dateString;
    }
  }
}

