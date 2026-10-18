import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:heraj_meem/config/app_font.dart';
import 'package:heraj_meem/features/products/presentation/managers/product_quota_helper.dart';

/// Example widget showing how to use the ProductQuotaHelper
///
/// This button checks the user's product quota before navigating.
/// If remaining quota is 0, it shows a dialog and navigates to plans screen.
/// Otherwise, it navigates to the add product screen.
class AddProductButton extends ConsumerWidget {
  final Widget addProductScreen;
  final Widget plansScreen;

  const AddProductButton({
    super.key,
    required this.addProductScreen,
    required this.plansScreen,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      onPressed: () {
        ProductQuotaHelper.checkQuotaAndNavigate(
          context: context,
          ref: ref,
          addProductScreen: addProductScreen,
          plansScreen: plansScreen,
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColor.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.add_circle_outline, size: 20),
          const SizedBox(width: 8),
          Text(
            'Add Product'.tr,
            style: AppFont.font16W600Black.copyWith(
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

/// Alternative: Floating Action Button version
class AddProductFAB extends ConsumerWidget {
  final Widget addProductScreen;
  final Widget plansScreen;

  const AddProductFAB({
    super.key,
    required this.addProductScreen,
    required this.plansScreen,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FloatingActionButton(
      onPressed: () {
        ProductQuotaHelper.checkQuotaAndNavigate(
          context: context,
          ref: ref,
          addProductScreen: addProductScreen,
          plansScreen: plansScreen,
        );
      },
      backgroundColor: AppColor.primary,
      child: const Icon(Icons.add),
      // label: Text('Add Product'.tr),
    );
  }
}

/// Alternative: Icon Button version for app bars
class AddProductIconButton extends ConsumerWidget {
  final Widget addProductScreen;
  final Widget plansScreen;

  const AddProductIconButton({
    super.key,
    required this.addProductScreen,
    required this.plansScreen,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      onPressed: () {
        ProductQuotaHelper.checkQuotaAndNavigate(
          context: context,
          ref: ref,
          addProductScreen: addProductScreen,
          plansScreen: plansScreen,
        );
      },
      icon: const Icon(Icons.add_circle_outline),
      tooltip: 'Add Product'.tr,
    );
  }
}
