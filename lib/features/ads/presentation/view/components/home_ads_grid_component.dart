import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:heraj_meem/config/app_font.dart';
import 'package:heraj_meem/features/ads/data/models/product_model.dart';
import 'package:heraj_meem/features/ads/presentation/view/widgets/product_tile.dart';
import 'package:heraj_meem/features/home/presentation/managers/baho_feed_provider.dart';
import 'package:heraj_meem/features/home/presentation/view/widgets/home_entrance.dart';
import 'package:skeletonizer/skeletonizer.dart';

class HomeAdsGridComponent extends ConsumerWidget {
  const HomeAdsGridComponent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ads = ref.watch(bahoAdsProvider);
    return ads.when(
      loading: () => const _AdsGridSkeleton(),
      error: (error, _) => Padding(
        padding: const EdgeInsets.all(16),
        child: Text(error.toString()),
      ),
      data: (items) {
        if (items.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Text(
                'No products found'.tr,
                style: AppFont.font14W600Black,
              ),
            ),
          );
        }
        return MasonryGridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 24),
          crossAxisCount: 2,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          itemCount: items.length,
          itemBuilder: (context, index) => HomeEntrance(
            index: index,
            slide: 12,
            beginScale: 0.96,
            child: ProductTile(product: items[index]),
          ),
        );
      },
    );
  }
}

class _AdsGridSkeleton extends StatelessWidget {
  const _AdsGridSkeleton();

  @override
  Widget build(BuildContext context) {
    final base = Color.lerp(AppColor.primary, Colors.white, 0.72)!;
    final highlight = Color.lerp(AppColor.primary, Colors.white, 0.9)!;
    return Skeletonizer(
      enabled: true,
      ignorePointers: true,
      containersColor: AppColor.primary.withAlpha(22),
      effect: ShimmerEffect(
        baseColor: base,
        highlightColor: highlight,
        duration: const Duration(milliseconds: 1200),
      ),
      child: MasonryGridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 24),
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        itemCount: 4,
        itemBuilder: (_, __) => ProductTile(product: _placeholderProduct()),
      ),
    );
  }
}

ProductModel _placeholderProduct() {
  return ProductModel(
    id: 'skeleton',
    name: 'Ad title',
    sku: '',
    afterPrice: '1200',
    titleAr: 'عنوان الإعلان',
    isFeatured: false,
    isFavorite: false,
    productType: 'customer',
    images: const [],
    badges: const [],
    status: 'ACTIVE',
    stock: 1,
    variants: const [],
    variantCombinations: const [],
    isFeaturedDeal: false,
    views: 0,
    specifications: const [],
    priceHistory: const [],
    createdAt: '',
    updatedAt: '',
    v: 0,
    price: 1200,
    location: Location(neighborhood: 'الرياض'),
    rating: Rating(average: 4, count: 12),
  );
}
