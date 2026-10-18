import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj_meem/config/app_font.dart';
import 'package:heraj_meem/features/bundles/presentation/managers/bundles_provider.dart';
import 'package:heraj_meem/features/products/presentation/view/widgets/product_tile.dart';
import 'package:heraj_meem/ui/shared_widgets/shimmer_effect.dart';

class BundleProductsSection extends ConsumerWidget {
  final String productId;

  const BundleProductsSection({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.watch(fetchProductBundlesProvider(productId));

    return provider.when(
      error: (err, stack) => const SizedBox.shrink(),
      loading: () {
        return MasonryGridView.count(
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
        );
      },
      data: (products) {
        if (products.isEmpty) {
          return const SizedBox.shrink();
        }
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Bundle Products".tr,
                    style: AppFont.font18W700Black,
                  ),
                ],
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

