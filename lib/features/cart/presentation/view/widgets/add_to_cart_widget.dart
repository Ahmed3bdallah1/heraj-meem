import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:tuple/tuple.dart';
import '../../../../../config/app_font.dart';
import '../../../../../ui/shared_widgets/container_button.dart';
import '../../../../../ui/shared_widgets/loading_widget.dart';
import '../../../../products/data/models/product_model.dart';
import '../../manager/cart_provider_notifier.dart';
import '../../manager/fetch_cart_provider.dart';

class AddToCartWidget extends StatelessWidget {
  final ProductModel product;

  const AddToCartWidget({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final productId = product.id.toString();
    final tuple = Tuple2(productId, null);

    return Consumer(builder: (context, ref, _) {
      final quantityNotifier = ref.read(quantityProvider(tuple).notifier);
      final quantity = ref.watch(quantityProvider(tuple))["quantity"];
      final cartItems = ref.watch(fetchCartProvider).valueOrNull;
      final loading =
          ref.watch(quantityProvider(tuple))["loading"] ?? false;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        final item = (cartItems?.items??[]).firstWhereOrNull((e) => e.productId == productId);

        if (item != null &&
            quantityNotifier.state['quantity'] != item.quantity) {
          quantityNotifier.syncWithCart(item.quantity ?? 0);
        } else if (item == null && quantityNotifier.state['quantity'] != 0) {
          quantityNotifier.syncWithCart(0);
        }
      });

      if (quantityNotifier.state['quantity'] == 0) {
        return ContainerButton(
          size: 44,
          isValidOrLoading: loading,
          onTap: () async {
            print("Product ID: ${product.name}"); 
            await quantityNotifier.incrementQuantity();
            ref.invalidate(fetchCartProvider);
          },
          radius: 12,
          icon: Icons.add,
          color: AppColor.primary,
          iconColor: Colors.white,
        );
      } else {
        return Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppColor.white,
                border: Border.all(color: AppColor.primary, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  ContainerButton(
                    size: 40,
                    isValidOrLoading: loading,
                    onTap: () async {
                      await quantityNotifier.incrementQuantity();
                      ref.invalidate(fetchCartProvider);
                    },
                    icon: Icons.add,
                    color: AppColor.primary,
                    iconColor: Colors.white,
                  ),
                  SizedBox(
                    height: 40,
                    width: 40,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: loading
                            ? const LoadingWidget(size: 20)
                            : Text(
                                quantity.toString(),
                                style: AppFont.font12W600Primary,
                              ),
                      ),
                    ),
                  ),
                  ContainerButton(
                    size: 40,
                    isValidOrLoading: loading,
                    onTap: () async {
                      await quantityNotifier.decrementQuantity();
                      // await Future.delayed(const Duration(milliseconds: 500));
                      ref.invalidate(fetchCartProvider);
                    },
                    icon: Icons.remove,
                    color: AppColor.primary,
                    iconColor: Colors.white,
                  ),
                ],
              ),
            ),
          ],
        );
      }
    });
  }
}
