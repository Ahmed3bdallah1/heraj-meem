import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heraj/helper/riverpod.dart';
import '../../../../cart/presentation/manager/fetch_cart_provider.dart';
import '../../../../cart/presentation/view/widgets/cart_item_widget.dart' as items;

class CartItemsView extends ConsumerWidget {
  const CartItemsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartAsync = ref.watch(fetchCartProvider);
    return cartAsync.customWhen(
      ref: ref,
      refreshable: fetchCartProvider.future,
      data: (cart) {
        return SizedBox(
          height: 120,
          child: ListView.builder(
            itemExtent: 300,
            cacheExtent: 100,
            itemCount: cart.items.length,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) =>
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: items.CartItemCard(
                    item: cart.items[index], isViewOnly: true,),
                )
          ),
        );
      },
    );
  }
}


