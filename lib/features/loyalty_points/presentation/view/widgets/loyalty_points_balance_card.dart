import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import '../../../../../config/app_font.dart';
import '../../../../../helper/responsive.dart';

class LoyaltyPointsBalanceCard extends StatelessWidget {
  final int balance;

  const LoyaltyPointsBalanceCard({
    super.key,
    required this.balance,
  });

  @override
  Widget build(BuildContext context) {
    responsiveInit(context);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: AppColor.primary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColor.primary.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Loyalty Points'.tr,
            style: AppFont.font16W600NearlyWhite.copyWith(fontStyle: FontStyle.italic),
          ),
          Gap(8.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                balance.toString(),
                style: AppFont.font48W500PrimaryBlue.copyWith(
                  color: AppColor.white,
                  fontSize: 50,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 8, left: 8),
                child: Text(
                  'Points'.tr,
                  style: AppFont.font16W600NearlyWhite.copyWith(
                    fontSize: 18,
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

