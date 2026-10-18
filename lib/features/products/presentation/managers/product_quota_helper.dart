import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj/features/products/presentation/managers/products_managers.dart';
import 'package:heraj/ui/shared_widgets/loading_widget.dart';

class ProductQuotaHelper {
  static Future<void> checkQuotaAndNavigate({
    required BuildContext context,
    required WidgetRef ref,
    required Widget addProductScreen,
    required Widget plansScreen,
  }) async {
    try {
      Get.dialog(
        const Center(
          child: LoadingWidget(),
        ),
        barrierDismissible: false,
      );

      final quota = await ref.read(fetchProductQuotaProvider.future);

      Get.back();

      if (quota.remaining > 0) {
        Get.to(() => addProductScreen);
      } else {
        _showQuotaLimitDialog(
          context: context,
          quota: quota,
          plansScreen: plansScreen,
        );
      }
    } catch (e) {
      // Close loading if still showing
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      Get.snackbar(
        'Error'.tr,
        'Could not check product quota'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );

      Get.to(() => addProductScreen);
    }
  }

  static void _showQuotaLimitDialog({
    required BuildContext context,
    required quota,
    required Widget plansScreen,
  }) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: Colors.orange,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Product Limit Reached'.tr,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You have reached your product upload limit.'.tr,
              style: const TextStyle(fontSize: 14),
            ),
            const Gap(16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  _QuotaRow(
                    label: 'Maximum Products'.tr,
                    value: '${quota.max}',
                  ),
                  const Gap(8),
                  _QuotaRow(
                    label: 'Used'.tr,
                    value: '${quota.used}',
                  ),
                  const Gap(8),
                  _QuotaRow(
                    label: 'Remaining'.tr,
                    value: '${quota.remaining}',
                    isHighlight: true,
                  ),
                ],
              ),
            ),
            const Gap(16),
            Text(
              'Upgrade your plan to add more products!'.tr,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel'.tr,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.to(() => plansScreen);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Upgrade Plan'.tr,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuotaRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isHighlight;

  const _QuotaRow({
    required this.label,
    required this.value,
    this.isHighlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isHighlight ? FontWeight.w600 : FontWeight.normal,
            color: isHighlight ? Colors.orange : Colors.black87,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isHighlight ? Colors.orange : Colors.black87,
          ),
        ),
      ],
    );
  }
}
