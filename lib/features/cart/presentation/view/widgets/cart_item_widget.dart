import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj/features/products/presentation/view/product_details_screen.dart';
import 'package:tuple/tuple.dart';
import '../../../../../config/app_font.dart';
import '../../../../../main.dart';
import '../../../../../ui/shared_widgets/container_button.dart';
import '../../../../../ui/shared_widgets/image_or_svg.dart';
import '../../../../../ui/shared_widgets/price_widget.dart';
import '../../../data/models/cart_item_model.dart';
import '../../../domain/use_cases/cart_use_case.dart';
import '../../manager/fetch_cart_provider.dart';
import '../../manager/cart_provider_notifier.dart';

class CartItemCard extends ConsumerWidget {
  final bool isViewOnly;
  const CartItemCard({
    super.key,
    required this.item,
    this.isViewOnly = false
  });

  final CartItemModel item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
        onTap: () {
          Get.to(()=> ProductDetailsScreen(productId: item.product?.id??"1"));
        },
        child: Card(
          color: AppColor.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 1,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4,horizontal: 10),
            child: Consumer(builder: (context, ref, _) {
              final productId = item.product?.id.toString() ?? '';
              final tuple = Tuple2(productId,item.id);
              final qtyNotifier = ref.read(quantityProvider(tuple).notifier);
              final loading = ref.watch(quantityProvider(tuple))["loading"] ?? false;
              final currentQty =
                  ref.watch(quantityProvider(tuple))["quantity"] ?? 0;

              WidgetsBinding.instance.addPostFrameCallback((_) {
                final itemQty = item.quantity ?? 0;
                if (currentQty != itemQty) {
                  qtyNotifier.syncWithCart(itemQty);
                }
              });

              final double unitPrice = (() {
                final subtotal = item.subtotal ?? 0.0;
                final qty = (item.quantity ?? 1);
                if (qty == 0) return subtotal;
                return subtotal / qty;
              })();

              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: ImageOrSvg(
                      item.product?.thumbImage ?? "",
                      width: 80,
                      height: 80,
                      fit: BoxFit.fill,
                    ),
                  ),
                  const Gap(10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.product?.name ?? 'Unnamed Product'.tr,
                          style: AppFont.font15W700Black,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        HtmlWidget(
                          item.product?.description ?? 'Unnamed Description'.tr,
                          textStyle: AppFont.font12w500Grey2,
                        ),
                        const Gap(6),
                        PriceWidget(
                          price: unitPrice.toStringAsFixed(0),
                          style: AppFont.font14W600Green,
                          textColor: AppColor.green,
                        ),
                        const Gap(6),
                        if(!isViewOnly)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                ContainerButton(
                                  size: 32,
                                  isValidOrLoading: loading,
                                  onTap: () async {
                                    qtyNotifier.decrementQuantity();
                                    await Future.delayed(
                                        const Duration(milliseconds: 300));
                                    ref.invalidate(fetchCartProvider);
                                  },
                                  icon: Icons.remove,
                                  color: AppColor.primary,
                                  iconColor: Colors.white,
                                ),
                                SizedBox(
                                  width: 40,
                                  height: 32,
                                  child: Center(
                                    child: loading
                                        ? const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                                strokeWidth: 2),
                                          )
                                        : Text(
                                            (currentQty).toString(),
                                            style: AppFont.font12W600Primary,
                                          ),
                                  ),
                                ),
                                ContainerButton(
                                  size: 32,
                                  isValidOrLoading: loading,
                                  onTap: () async {
                                    qtyNotifier.incrementQuantity();
                                    await Future.delayed(
                                        const Duration(milliseconds: 300));
                                    ref.invalidate(fetchCartProvider);
                                  },
                                  icon: Icons.add,
                                  color: AppColor.primary,
                                  iconColor: Colors.white,
                                ),
                              ],
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                await getIt<DeleteFromCartItemsUseCase>()
                                    .call(item.id);
                                ref.invalidate(fetchCartProvider);
                              },
                              constraints: const BoxConstraints(),
                              padding: EdgeInsets.zero,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }),
          ),
        ));
  }
}
