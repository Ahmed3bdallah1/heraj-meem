import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import '../../../../config/app_font.dart';
import '../../../../helper/responsive.dart';
import '../../../../helper/riverpod.dart';
import '../../../../ui/shared_widgets/scaffold_back_ground.dart';
import '../../../../ui/shared_widgets/not_found_widget.dart';
import '../managers/loyalty_points_provider.dart';
import 'widgets/loyalty_points_balance_card.dart';
import 'widgets/loyalty_points_history_item.dart';

/// Screen displaying loyalty points balance and transaction history
class LoyaltyPointsScreen extends ConsumerWidget {
  const LoyaltyPointsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    responsiveInit(context);
    return ScaffoldBackGround(
      title: 'Points'.tr,
      onRefresh: () async {
        ref.invalidate(loyaltyPointsProvider);
      },
      child: SafeArea(
        child: Consumer(
          builder: (context, ref, _) {
            final provider = ref.watch(loyaltyPointsProvider);
            return provider.customWhen(
              ref: ref,
              refreshable: loyaltyPointsProvider.future,
              skipLoadingOnRefresh: true,
              skipLoadingOnReload: true,
              data: (data) {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      LoyaltyPointsBalanceCard(balance: data.balance),
                      Gap(20.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        child: Text(
                          'Points History'.tr,
                          style: AppFont.font18W700Black,
                        ),
                      ),
                      Gap(12.h),
                      if (data.history.isEmpty)
                        NotFoundWidget(
                          title: 'No Points History'.tr,
                          message: 'Your loyalty points history will appear here.'.tr,
                          haveIcon: true,
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                          return LoyaltyPointsHistoryItemWidget(
                            historyItem: data.history[index],
                          );
                          },
                          separatorBuilder: (context, index) {
                            return Gap(8.h);
                          },
                          itemCount: data.history.length,
                        ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

