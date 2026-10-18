import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../../../../../config/app_font.dart';
import '../../../../data/models/store_model.dart';
import 'store_stats_container.dart';

class StoreCardContent extends StatelessWidget {
  final StoreModel store;

  const StoreCardContent({
    super.key,
    required this.store,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 10,
        left: 16,
        right: 16,
        bottom: 12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            store.storeName,
            style: AppFont.font16W700Black,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const Gap(8),
          Row(
            children: [
              const Icon(
                Icons.star,
                size: 16,
                color: Colors.amber,
              ),
              const Gap(4),
              Text(
                store.stats.rating > 0 ? store.stats.rating.toStringAsFixed(1) : '0.0',
                style: AppFont.font14W600Black,
              ),
              const Gap(4),
              Text(
                '(${store.stats.totalReviews})',
                style: AppFont.font12w400Black.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const Gap(12),
          StoreStatsContainer(
            totalProducts: store.stats.totalProducts,
            totalOrders: store.stats.totalOrders,
          ),
        ],
      ),
    );
  }
}

