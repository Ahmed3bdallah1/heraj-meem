import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../../config/app_color.dart';
import 'store_stat_item.dart';

class StoreStatsContainer extends StatelessWidget {
  final int totalProducts;
  final int totalOrders;

  const StoreStatsContainer({
    super.key,
    required this.totalProducts,
    required this.totalOrders,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColor.primary.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          StoreStatItem(
            value: totalProducts.toString(),
            label: 'Products'.tr,
          ),
          Container(
            width: 1,
            height: 30,
            color: AppColor.primary.withAlpha(75),
          ),
          StoreStatItem(
            value: totalOrders.toString(),
            label: 'Orders'.tr,
          ),
        ],
      ),
    );
  }
}

