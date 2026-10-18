import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj/config/app_font.dart';
import 'package:heraj/features/products/data/models/product_model.dart';
import 'package:heraj/features/products/presentation/view/widgets/product_tile.dart';
import 'package:heraj/ui/shared_widgets/shimmer_effect.dart';
import '../../../../categories/presentation/managers/category_products_provider.dart';

class SimilarProductsSection extends ConsumerWidget {
  final String? categoryId;

  /// 'admin' => store-page/category; otherwise => products?category=
  final String? productType;

  /// Current product id to exclude from the list
  final String? productId;

  const SimilarProductsSection({
    super.key,
    this.categoryId,
    this.productType,
    this.productId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catId = categoryId?.trim();
    if (catId == null || catId.isEmpty) return const SizedBox.shrink();

    final isAdmin = productType?.toLowerCase() == 'admin';

    if (isAdmin) {
      final provider = ref.watch(similarProductsFromStoreCategoryProvider((
        categoryId: catId,
        excludeProductId: productId ?? '',
      )));
      return provider.when(
        error: (err, stack) => ErrorWidget(err),
        loading: () => _buildShimmer(),
        data: (products) => _buildList(context, products),
      );
    }

    final provider = ref.watch(fetchCategoryProductsProvider(catId));
    return provider.when(
      error: (err, stack) => ErrorWidget(err),
      loading: () => _buildShimmer(),
      data: (products) {
        final list = productId != null && productId!.isNotEmpty
            ? products.where((p) => p.id != productId).toList()
            : products;
        return _buildList(context, list);
      },
    );
  }

  Widget _buildShimmer() {
    return MasonryGridView.count(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: 6,
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
  }

  Widget _buildList(BuildContext context, List<ProductModel> products) {
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
                "Similar Products".tr,
                style: AppFont.font18W700Black,
              ),
              GestureDetector(
                onTap: () {},
                child: Row(
                  children: [
                    Text(
                      "More".tr,
                      style: AppFont.font14W600Primary,
                    ),
                    const Gap(4),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: AppColor.primary,
                    ),
                  ],
                ),
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
  }
}
