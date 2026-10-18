import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import '../../../../../config/app_font.dart';
import '../../../../../ui/shared_widgets/custom_filled_button.dart';
import '../../../../../ui/shared_widgets/custom_outlined_button.dart';
import '../../../../root/view/root_view.dart';

class AdPendingStep extends StatelessWidget {
  final Map<String, dynamic>? productData;
  final VoidCallback? onViewAd;

  const AdPendingStep({super.key,
    this.productData,
    this.onViewAd,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.hourglass_empty,
              size: 120,
              color: AppColor.primary,
            ),
            const Gap(32),
            Text(
              'Your new ad has been successfully uploaded'.tr,
              style: AppFont.font18W700Black,
              textAlign: TextAlign.center,
            ),
            const Gap(8),
            Text(
              'Please wait for approval'.tr,
              style: AppFont.font14W600Black.copyWith(color: AppColor.grey2),
              textAlign: TextAlign.center,
            ),
            const Gap(48),
            Row(
              children: [
                Expanded(
                  child: CustomFilledButton(
                    text: 'View My Ad'.tr,
                    onPressed: onViewAd,
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: CustomOutlinedButton(
                    text: 'Go To Home'.tr,
                    textColor: AppColor.primary,
                    onPressed: () {
                      Get.offAll(() => const RootView());
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}