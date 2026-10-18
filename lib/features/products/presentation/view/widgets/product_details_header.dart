import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:heraj/config/app_color.dart';
import 'package:heraj/config/app_font.dart';
import 'package:heraj/features/cart/presentation/view/cart_items_screen.dart';
import 'package:heraj/ui/shared_widgets/container_button.dart';

class ProductDetailsHeader extends StatelessWidget {
  final dynamic product;

  const ProductDetailsHeader({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      padding: EdgeInsets.symmetric(horizontal: 16)
          .copyWith(top: MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: AppColor.primary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.bottom + 30, bottom: 0),
        child: Row(
          children: [
            // Back button
            ContainerButton(
              icon: Icons.arrow_back,
              color: Colors.transparent,
              iconColor: Colors.white,
              onTap: () => Get.back(),
            ),
            const Spacer(),
            Text(
              "Product Details".tr,
              style: AppFont.font18W700NearlyWhite,
            ),
            const Spacer(),
            ContainerButton(
              icon: Icons.shopping_bag_outlined,
              color: Colors.transparent,
              iconColor: Colors.white,
              onTap: () {
                Get.to(()=> CartItemsScreen2());
              },
            ),
          ],
        ),
      ),
    );
  }
}
