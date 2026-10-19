import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj_meem/config/app_font.dart';
import 'package:heraj_meem/features/ads/presentation/managers/all_products_provider.dart';
import 'package:heraj_meem/features/ads/presentation/view/widgets/sell_all_products/animated_product_card.dart';
import 'package:heraj_meem/features/search/presentation/managers/search_filter_notifier.dart';
import '../../../../ui/shared_widgets/loading_widget.dart';
import 'widgets/all_products_filter_drawer.dart';

class SearchAllProductsScreen extends ConsumerStatefulWidget {
  const SearchAllProductsScreen({super.key});

  @override
  ConsumerState<SearchAllProductsScreen> createState() =>
      _AllProductsScreenState();
}

class _AllProductsScreenState extends ConsumerState<SearchAllProductsScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  static const _paginationThreshold = 400.0;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final pos = _scrollController.position;
    if (!pos.hasPixels || !pos.hasContentDimensions) return;
    if (pos.pixels < pos.maxScrollExtent - _paginationThreshold) return;
    if (_isLoadingMore) return;
    final notifier = ref.read(allProductsNotifierProvider.notifier);
    if (notifier.isLastPage()) return;
    _isLoadingMore = true;
    notifier.fetchNextPage().whenComplete(() {
      if (mounted) _isLoadingMore = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final activeFiltersCount = ref.watch(searchFilterProvider.select((state) =>
        state.entries
            .where((e) =>
                e.key != 'limit' &&
                e.key != 'name' &&
                e.key != 'sort' &&
                e.value != null)
            .length));

    return Scaffold(
      key: _scaffoldKey,
      endDrawer: const AllProductsFilterDrawer(),
      body: CustomScrollView(
        controller: _scrollController,
        cacheExtent: 400,
        slivers: [
          // Custom Orange Header
          SliverToBoxAdapter(
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 16,
                bottom: 24,
                left: 16,
                right: 16,
              ),
              decoration: const BoxDecoration(
                color: AppColor.primary,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Breadcrumb
                  Row(
                    children: [
                      InkWell(
                        onTap: () => Get.back(),
                        child: Text(
                          'Home'.tr,
                          style: AppFont.font14W500Black.copyWith(
                            color: AppColor.white.withAlpha(225),
                          ),
                        ),
                      ),
                      Text(
                        ' / ',
                        style: AppFont.font14W500Black.copyWith(
                          color: AppColor.white.withAlpha(225),
                        ),
                      ),
                      Text(
                        'All Products'.tr,
                        style: AppFont.font14W500Black.copyWith(
                          color: AppColor.white,
                        ),
                      ),
                    ],
                  ),
                  const Gap(16),
                  // Title and Icon
                  Consumer(
                    builder: (context, ref, _) {
                      final productsAsync =
                          ref.watch(allProductsNotifierProvider);
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            color: AppColor.white,
                            size: 32,
                          ),
                          const Gap(12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'All Products'.tr,
                                style: AppFont.font24w600Black.copyWith(
                                  color: AppColor.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              productsAsync.maybeWhen(
                                data: (products) => Text(
                                  '${products.length} ${'products available'.tr}',
                                  style: AppFont.font14W500Black.copyWith(
                                    color: AppColor.white.withAlpha(225),
                                  ),
                                ),
                                orElse: () => const Gap(20),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // Filters and Sort Row
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Filters Button
                  OutlinedButton.icon(
                    onPressed: () {
                      _scaffoldKey.currentState?.openEndDrawer();
                    },
                    icon: Icon(
                      Icons.tune,
                      color: AppColor.primary,
                      size: 20,
                    ),
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Filters'.tr,
                          style: AppFont.font14W600Black.copyWith(
                            color: AppColor.primary,
                          ),
                        ),
                        if (activeFiltersCount > 0) ...[
                          const Gap(4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColor.primary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              activeFiltersCount.toString(),
                              style: AppFont.font10w400Black.copyWith(
                                color: AppColor.white,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColor.primary),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 46,
                    width: MediaQuery.of(context).size.width * 0.46,
                    child: Consumer(
                      builder: (context, ref, _) {
                        final selectedSort = ref.watch(
                          searchFilterProvider
                              .select((s) => s['sort'] as String?),
                        );
                        return DropdownButtonFormField<String>(
                          initialValue: selectedSort ?? 'newest',
                          decoration: InputDecoration(
                            suffixIconConstraints: const BoxConstraints(
                              minWidth: 24,
                              maxWidth: 30,
                            ),
                            prefixIconConstraints: const BoxConstraints(
                              minWidth: 24,
                              maxWidth: 30,
                            ),
                            prefixIcon: Icon(
                              Icons.sort,
                              color: AppColor.primary,
                              size: 15,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 8,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: AppColor.primary),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: AppColor.primary),
                            ),
                          ),
                          items: [
                            DropdownMenuItem(
                              value: 'newest',
                              child: Text(
                                'Newest First'.tr,
                                style: AppFont.font12W600Black,
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'oldest',
                              child: Text(
                                'Oldest First'.tr,
                                style: AppFont.font12W600Black,
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'price_low',
                              child: Text(
                                'Price: Low to High'.tr,
                                style: AppFont.font12W600Black,
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'price_high',
                              child: Text(
                                'Price: High to Low'.tr,
                                style: AppFont.font12W600Black,
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            ref
                                .read(searchFilterProvider.notifier)
                                .updateFilter('sort', value);
                            ref.invalidate(allProductsNotifierProvider);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Products Grid
          Consumer(
            builder: (context, ref, _) {
              final productsAsync = ref.watch(allProductsNotifierProvider);
              return productsAsync.when(
                loading: () => const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(child: LoadingWidget()),
                  ),
                ),
                error: (_, __) => SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text('Error loading products'.tr),
                    ),
                  ),
                ),
                data: (products) {
                  if (products.isEmpty) {
                    return SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 80,
                              color: Colors.grey[300],
                            ),
                            const Gap(24),
                            Text(
                              'No products found'.tr,
                              style: AppFont.font18W700Black,
                              textAlign: TextAlign.center,
                            ),
                            const Gap(8),
                            Text(
                              'Try adjusting your search or filters'.tr,
                              style: AppFont.font14W500Black.copyWith(
                                color: Colors.grey[600],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverMasonryGrid.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return AnimatedProductCard(
                          product: product,
                          index: index,
                        );
                      },
                      childCount: products.length,
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
