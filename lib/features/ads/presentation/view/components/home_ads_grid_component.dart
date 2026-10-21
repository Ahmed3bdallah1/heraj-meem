import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:heraj_meem/config/app_font.dart';
import 'package:heraj_meem/features/ads/data/models/product_model.dart';
import 'package:heraj_meem/features/ads/presentation/view/widgets/home_ads_morph.dart';
import 'package:heraj_meem/features/ads/presentation/view/widgets/product_tile.dart';
import 'package:heraj_meem/features/home/presentation/managers/baho_feed_provider.dart';
import 'package:heraj_meem/helper/riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';

class HomeAdsGridComponent extends ConsumerStatefulWidget {
  const HomeAdsGridComponent({super.key});

  @override
  ConsumerState<HomeAdsGridComponent> createState() =>
      _HomeAdsGridComponentState();
}

class _HomeAdsGridComponentState extends ConsumerState<HomeAdsGridComponent> {
  late final PageController _pages;
  late final ValueNotifier<double> _page;

  @override
  void initState() {
    super.initState();
    _pages = PageController(initialPage: 1);
    _page = ValueNotifier(1);
    _pages.addListener(_onPage);
  }

  @override
  void dispose() {
    _pages
      ..removeListener(_onPage)
      ..dispose();
    _page.dispose();
    super.dispose();
  }

  void _onPage() {
    final page = _pages.page;
    if (page == null || page == _page.value) return;
    _page.value = page;
  }

  void _showGrid() {
    if (!_pages.hasClients) return;
    _pages.animateToPage(
      0,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  void _showList() {
    if (!_pages.hasClients) return;
    _pages.animateToPage(
      1,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ads = ref.watch(bahoAdsProvider);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
          child: Align(
            alignment: AlignmentDirectional.centerEnd,
            child: ValueListenableBuilder<double>(
              valueListenable: _page,
              builder: (context, page, _) {
                return HomeAdsViewSwitcher(
                  t: page.clamp(0, 1),
                  onGrid: _showGrid,
                  onList: _showList,
                );
              },
            ),
          ),
        ),
        ads.customWhen(
          ref: ref,
          refreshable: bahoAdsProvider.future,
          skipLoadingOnRefresh: true,
          loading: () => ValueListenableBuilder<double>(
            valueListenable: _page,
            builder: (context, page, _) {
              return page < 0.5
                  ? const _AdsGridSkeleton()
                  : const _AdsListSkeleton();
            },
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
            final showFooter =
                !ref.read(bahoAdsProvider.notifier).isLastPage();
            return HomeAdsPages(
              controller: _pages,
              items: items,
              showFooter: showFooter,
            );
          },
        ),
      ],
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

class _AdsListSkeleton extends StatelessWidget {
  const _AdsListSkeleton();

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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          children: [
            for (var index = 0; index < 3; index++) ...[
              if (index > 0) const SizedBox(height: 8),
              HomeAdListCard(product: _placeholderProduct()),
            ],
          ],
        ),
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
    createdAt: '2026-10-18T10:00:00.000Z',
    updatedAt: '',
    v: 0,
    price: 1200,
    sellerName: 'Heba Yasser',
    location: Location(neighborhood: 'الرياض'),
    rating: Rating(average: 4, count: 12),
  );
}
