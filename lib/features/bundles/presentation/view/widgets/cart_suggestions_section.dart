import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj/config/app_font.dart';
import 'package:heraj/features/bundles/presentation/managers/bundles_provider.dart';
import 'package:heraj/features/products/presentation/view/widgets/product_tile.dart';
import 'package:heraj/ui/shared_widgets/shimmer_effect.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class CartSuggestionsSection extends ConsumerWidget {
  final List<String> productIds;

  const CartSuggestionsSection({
    super.key,
    required this.productIds,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (productIds.isEmpty) {
      return const SizedBox.shrink();
    }

    final provider = ref.watch(fetchCartSuggestionsProvider(productIds));

    return provider.when(
      error: (err, stack) => const SizedBox.shrink(),
      loading: () {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "You May Also Like".tr,
                style: AppFont.font18W700Black,
              ),
            ),
            const Gap(16),
            MasonryGridView.count(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 4,
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 8,
              itemBuilder: (context, index) {
                return ShimmerEffect(
                  enable: true,
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
      data: (products) {
        if (products.isEmpty) {
          return const SizedBox.shrink();
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "You May Also Like".tr,
                style: AppFont.font18W700Black,
              ),
            ),
            const Gap(16),
            MasonryGridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
              ),
              itemBuilder: (context, index) {
                final product = products[index];
                return ProductTile(product: product);
              },
              itemCount: products.length,
            ),
          ],
        );
      },
    );
  }
}

