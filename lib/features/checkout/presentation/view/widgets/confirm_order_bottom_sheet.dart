import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj/config/app_font.dart';
import 'package:heraj/ui/shared_widgets/price_widget.dart';
import 'package:heraj/core/service/loading_provider.dart';
import 'package:heraj/features/checkout/data/models/coupon_applied_model.dart';
import 'package:heraj/features/orders/presentation/manager/create_order_provider.dart';
import 'package:heraj/features/root/view/root_view.dart';
import 'package:heraj/ui/shared_widgets/custom_filled_button.dart';
import 'package:heraj/ui/ui.dart';
import '../../managers/coupon_provider.dart';
import '../../managers/shipping_provider.dart';
import '../../../../cart/presentation/manager/fetch_cart_provider.dart';
import 'order_images_widget.dart';

class ConfirmOrderBottomSheet extends ConsumerWidget {
  const ConfirmOrderBottomSheet({
    super.key,
    required this.itemsCount,
    required this.subtotal,
    required this.discount,
    required this.shipping,
    required this.tax,
    required this.total,
    this.addressId,
    this.coupon,
    required this.paymentTypeName,
  });

  final int itemsCount;
  final double subtotal;
  final double discount;
  final double shipping;
  final double tax;
  final double total;
  final String? addressId;
  final CouponModel? coupon;
  final String paymentTypeName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text('${"Products".tr} ($itemsCount)',
                    style: AppFont.font16W600Black),
                const Spacer(),
              ],
            ),
            const Gap(12),
            _row(
                'Subtotal'.tr,
                PriceWidget(
                    price: subtotal.toStringAsFixed(2),
                    style: AppFont.font14W600Black)),
            if (discount > 0)
              _row(
                  'Discount'.tr,
                  PriceWidget(
                      price: discount.toStringAsFixed(2),
                      style: AppFont.font14W600Black)),
            _row(
                'Shipping'.tr,
                PriceWidget(
                    price: shipping.toStringAsFixed(2),
                    style: AppFont.font14W600Black)),
            _row(
                'Tax (20% VAT)'.tr,
                PriceWidget(
                    price: tax.toStringAsFixed(2),
                    style: AppFont.font14W600Black)),
            const Divider(height: 24),
            Row(
              children: [
                Text('Total'.tr, style: AppFont.font16W600Black),
                const Spacer(),
                PriceWidget(
                    price: total.toStringAsFixed(2),
                    style: AppFont.font16W600Black),
              ],
            ),
            const Gap(16),
            if (addressId != null)
              Text('${"Address:".tr} #$addressId',
                  style: AppFont.font12w500Grey2),
            if (coupon != null)
              Text('${"Coupon:".tr} #${coupon?.code ?? ""}',
                  style: AppFont.font12w500Grey2),
            Text('${"Payment:".tr} $paymentTypeName',
                style: AppFont.font12w500Grey2),
            const Gap(12),
            Consumer(
              builder: (context, ref, child) {
                final isLoading = ref.watch(isLoadingProvider("createOrder"));
                return CustomFilledButton(
                  text: 'Confirm order'.tr,
                  textSize: 14,
                  isLoading: isLoading,
                  onPressed: () async {
                    if (addressId == null) {
                      UIHelper.showGlobalSnackBar(
                        text: "Please select an address".tr,
                        color: AppColor.danger2,
                      );
                      return;
                    }

                    final selectedShipping = ref.read(selectedShippingCompanyProvider);
                    if (selectedShipping == null) {
                      UIHelper.showGlobalSnackBar(
                        text: "Please select a shipping company".tr,
                        color: AppColor.danger2,
                      );
                      return;
                    }

                    try {
                      ref
                          .read(isLoadingProvider("createOrder").notifier)
                          .state = true;
                      String paymentMethod = 'card';
                      if (paymentTypeName.toLowerCase() == 'cash') {
                        paymentMethod = 'cash';
                      } else if (paymentTypeName.toLowerCase() == 'visa') {
                        paymentMethod = 'card';
                      }

                      // Get selected shipping company
                      final selectedShipping = ref.read(selectedShippingCompanyProvider);
                      
                      final checkoutData = <String, dynamic>{
                        'addressId': addressId,
                        'paymentMethod': paymentMethod,
                      };
                      
                      // Add shipping object if available
                      if (selectedShipping != null) {
                        checkoutData['shipping'] = {
                          'companyId': selectedShipping.companyId,
                          'companyName': selectedShipping.companyName,
                          if (selectedShipping.companyNameTr != null)
                            'companyNameTr': selectedShipping.companyNameTr,
                          if (selectedShipping.companyNameAr != null)
                            'companyNameAr': selectedShipping.companyNameAr,
                          'price': selectedShipping.price,
                        };
                      }

                      final result =
                          await ref.read(checkoutProvider(checkoutData).future);

                      result.fold(
                        (failure) {
                          UIHelper.showGlobalSnackBar(
                            text: failure.message.tr,
                            color: AppColor.danger2,
                          );
                        },
                        (response) async {
                          ref.invalidate(fetchCartProvider);
                          ref.read(couponStateProvider.notifier).state = null;
                          ref.read(couponCodeProvider.notifier).state = null;
                          ref.read(orderImagesProvider.notifier).state = [];
                          await UIHelper.showAlert(
                            "Order placed successfully".tr,
                            type: DialogType.success,
                          );
                          Get.offAll(() => RootView());
                        },
                      );
                    } finally {
                      ref
                          .read(isLoadingProvider("createOrder").notifier)
                          .state = false;
                    }
                  },
                );
              },
            ),
            const Gap(10),
          ],
        ),
      ),
    );
  }

  Widget _row(String title, Widget value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Text(title, style: AppFont.font14W600Black),
          const Spacer(),
          value,
        ],
      ),
    );
  }
}
