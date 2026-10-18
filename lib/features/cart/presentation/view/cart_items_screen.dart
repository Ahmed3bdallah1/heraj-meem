import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj/features/cart/data/models/cart_item_model.dart';
import 'package:heraj/features/checkout/presentation/view/checkout_screen.dart';
import 'package:heraj/features/bundles/presentation/view/widgets/cart_suggestions_section.dart';
import 'package:heraj/helper/riverpod.dart';
import 'package:heraj/ui/shared_widgets/custom_filled_button.dart';
import '../../../../config/app_font.dart';
import '../../../../config/app_color.dart';
import '../../../../ui/shared_widgets/price_widget.dart';
import '../../data/models/cart_model.dart';
import '../manager/fetch_cart_provider.dart';
import 'widgets/cart_item_widget.dart';

class CartItemsScreen2 extends ConsumerWidget {
  final bool isRoot;

  const CartItemsScreen2({super.key, this.isRoot = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartAsync = ref.watch(fetchCartProvider);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          "Cart".tr,
          style: AppFont.font20W700Black,
        ),
      ),
      body: cartAsync.customWhen(
        ref: ref,
        refreshable: fetchCartProvider.future,
        skipLoadingOnReload: true,
        skipLoadingOnRefresh: true,
        data: (cart) {
          final items = cart.items;

          if (cart.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Gap(24),
                  Text("Your cart is empty".tr, style: AppFont.font16W600Black),
                  const Gap(8),
                  Text("Add products to continue".tr,
                      style: AppFont.font12w400Black),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("My Products".tr, style: AppFont.font14W700Black),
                const Gap(12),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) =>
                      CartItemCard(item: items[index]),
                  separatorBuilder: (_, __) => const Gap(8),
                  itemCount: items.length,
                ),
                const Gap(24),
                _CartSummarySection(cart: cart),
                const Gap(16),
                CustomFilledButton(
                  text: "Check out".tr,
                  padding: 16,
                  onPressed: () {
                    Get.to(() => const CheckoutScreen());
                  },
                ),
                const Gap(16),
                CartSuggestionsSection(
                  productIds: items
                      .map((item) => item.product?.id ?? '')
                      .where((id) => id.isNotEmpty)
                      .toList(),
                ),
                Gap(MediaQuery.of(context).padding.bottom + (isRoot ? 100 : 0)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CartSummarySection extends StatelessWidget {
  const _CartSummarySection({required this.cart});

  final CartModel cart;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColor.primary.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Products".tr, style: AppFont.font12w400Black),
              Text("${cart.items.length} ${"products".tr}",
                  style: AppFont.font12w400Black),
            ],
          ),
          const Gap(8),
          const Divider(height: 8),
          const Gap(8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("total".tr, style: AppFont.font12w400Black),
              PriceWidget(
                price: cart.totalPrice.toStringAsFixed(2),
                style: AppFont.font16W600Black,
              ),
            ],
          ),
          const Gap(8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColor.primary.withAlpha(13),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColor.primary.withAlpha(38),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 16,
                  color: AppColor.primary,
                ),
                const Gap(8),
                Expanded(
                  child: Text(
                    "Tax and delivery fees will be calculated in the checkout.".tr,
                    style: AppFont.font12w400Black.copyWith(
                      color: AppColor.grey2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
