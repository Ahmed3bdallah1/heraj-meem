import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:heraj_meem/features/products/presentation/view/sell_all_products_screen.dart';
import 'package:heraj_meem/features/products/presentation/view/widgets/product_tile.dart';
import 'package:heraj_meem/helper/extensions/adaptive_view.dart';
import 'package:heraj_meem/helper/riverpod.dart';
import 'package:heraj_meem/ui/shared_widgets/shimmer_effect.dart';
import '../../../../../config/app_font.dart';
import '../../managers/fetch_home_data_provider.dart';

class NewProductsWidget extends ConsumerWidget {
  const NewProductsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.watch(fetchHomeDataProvider);
    return provider.customWhen(
      ref: ref,
      refreshable: fetchHomeDataProvider.future,
      loading: () {
        return Column(
          spacing: 4,
          children: [
            Padding(
              padding: context.responsiveHorizontalPadding(mobile: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'New Products'.tr,
                    style: AppFont.font18W700Black,
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'See More'.tr,
                      style: AppFont.font14W600Primary,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: context.responsiveHorizontalPadding(),
              child: MasonryGridView.builder(
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                shrinkWrap: true,
                gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: context.adaptiveValue<int>(
                    mobile: 2,
                    tablet: 4,
                    desktop: 6,
                  ),
                ),
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
                itemCount: 4,
              ),
            ),
          ],
        );
      },
      data: (homeData) {
        final products = homeData.latestProducts;
        if (products.isEmpty) return const SizedBox.shrink();
        
        return Column(
          spacing: 4,
          children: [
            Padding(
              padding: context.responsiveHorizontalPadding(mobile: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'New Products'.tr,
                    style: AppFont.font18W700Black,
                  ),
                  TextButton(
                    onPressed: () {
                      Get.to(() => SectionProductsScreen(
                            title: 'New Products'.tr,
                            products: products,
                          ));
                    },
                    child: Text(
                      'See More'.tr,
                      style: AppFont.font14W600Primary,
                    ),
                  ),
                ],
              ),
            ),
            MasonryGridView.builder(
              padding: context.responsiveHorizontalPadding(mobile: 12),
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              shrinkWrap: true,
              gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: context.adaptiveValue<int>(
                  mobile: 2,
                  tablet: 3,
                  desktop: 4,
                ),
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
