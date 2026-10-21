import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj_meem/config/app_color.dart';
import 'package:heraj_meem/config/app_font.dart';
import 'package:heraj_meem/features/ads/data/models/product_model.dart';
import 'package:heraj_meem/features/categories/data/models/main_category_model.dart';
import 'package:heraj_meem/core/service/localization_service/localization_service.dart';
import 'package:heraj_meem/features/store/data/models/open_store_model.dart';
import 'package:heraj_meem/helper/riverpod.dart';
import 'package:heraj_meem/main.dart';
import 'package:heraj_meem/ui/shared_widgets/image_or_svg.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../ads/presentation/view/widgets/product_tile.dart';
import '../managers/category_products_provider.dart';

class CategoryScreen extends ConsumerStatefulWidget {
  final CategoryModel category;

  const CategoryScreen({super.key, required this.category});

  @override
  ConsumerState<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends ConsumerState<CategoryScreen>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late AnimationController _backgroundAnimationController;

  @override
  void initState() {
    super.initState();
    _backgroundAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (ref.read(fetchCategoryProductsProvider(widget.category.id).notifier).isLastPage()) return;
      ref.read(fetchCategoryProductsProvider(widget.category.id).notifier).fetchNextPage();
    }
  }

  @override
  void dispose() {
    _backgroundAnimationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final langCode = getIt<LocaleService>().getLocale().locale.languageCode;
    final categoryDetailsProvider = ref.watch(fetchCategoryDetailsProvider(widget.category.id));

    return Scaffold(
      backgroundColor: Colors.white,
      body: categoryDetailsProvider.customWhen(
          ref: ref,
          refreshable: fetchCategoryDetailsProvider(widget.category.id).future,
          loading: () => const _CategoryScreenSkeleton(),
          data: (categoryDetails) {
            return CustomScrollView(
              controller: _scrollController,
              slivers: [
                // Breadcrumb AppBar
                _BreadcrumbAppBar(
                  breadcrumb: categoryDetails.breadcrumb,
                  langCode: langCode,
                ),

                // Category Header Card
                SliverToBoxAdapter(
                  child: _CategoryHeaderCard(
                    category: categoryDetails.category,
                    langCode: langCode,
                  ),
                ),

                // Explore Subcategories
                if (categoryDetails.children.isNotEmpty)
                  SliverToBoxAdapter(
                    child: _SubcategoriesSection(
                      subcategories: categoryDetails.children,
                      langCode: langCode,
                    ),
                  ),

                Consumer(builder: (context, ref, _) {
                  final provider = ref
                      .watch(fetchCategoryProductsProvider(widget.category.id));
                  return provider.when(
                    loading: () =>
                    const SliverToBoxAdapter(child: SizedBox.shrink()),
                    error: (_, __) =>
                    const SliverToBoxAdapter(child: SizedBox.shrink()),
                    data: (products) => SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          '${products.length} ${'products found'.tr}',
                          style: AppFont.font14W600Black.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ),
                  );
                }),

                const SliverToBoxAdapter(child: Gap(16)),

                Consumer(builder: (context, ref, _) {
                  final provider = ref
                      .watch(fetchCategoryProductsProvider(widget.category.id));
                  return provider.when(
                    loading: () => const _LoadingProductsGrid(),
                    error: (error, __) => SliverFillRemaining(
                      child: Center(
                        child: Text(
                          'Error loading products'.tr,
                          style: AppFont.font16W600Black,
                        ),
                      ),
                    ),
                    data: (products) {
                      if (products.isEmpty) {
                        return const _EmptyProductsState();
                      }
                      return SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        sliver: SliverMasonryGrid.count(
                          crossAxisCount: 2,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                          itemBuilder: (context, index) {
                            return AnimatedProductCard(
                              product: products[index],
                              index: index,
                            );
                          },
                          childCount: products.length,
                        ),
                      );
                    },
                  );
                }),
                const SliverToBoxAdapter(child: Gap(80)),
              ],
            );
          }),
    );
  }
}

class _BreadcrumbAppBar extends StatelessWidget {
  final List breadcrumb;
  final String langCode;
  final bool showLeading;

  const _BreadcrumbAppBar({
    required this.breadcrumb,
    required this.langCode,
    this.showLeading = true,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      floating: false,
      backgroundColor: Colors.white,
      elevation: 0,
      leading: showLeading
          ? IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: AppColor.primary,
              ),
              onPressed: () => Get.back(),
            )
          : const SizedBox.shrink(),
      title: Row(
        children: [
          InkWell(
            onTap: () => Get.back(),
            child: Text(
              'Home'.tr,
              style: AppFont.font14W600Black.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ),
          if (breadcrumb.isNotEmpty) ...[
            const Gap(6),
            Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey[600]),
            const Gap(6),
            Expanded(
              child: Text(
                langCode == "ar"
                    ? breadcrumb.first.nameAr
                    : langCode == "en"
                    ? breadcrumb.first.name
                    : breadcrumb.first.nameTr,
                style: AppFont.font14W600Black.copyWith(
                  color: Colors.grey[800],
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CategoryHeaderCard extends StatelessWidget {
  final CategoryModel category;
  final String langCode;

  const _CategoryHeaderCard({
    required this.category,
    required this.langCode,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColor.primary,
              AppColor.primary.withAlpha(204),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColor.primary.withAlpha(76),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: category.image != null
                    ? ImageOrSvg(
                  category.image!,
                  fit: BoxFit.cover,
                )
                    : Center(
                  child: Text(
                    category.icon ?? '📦',
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
              ),
            ),
            const Gap(16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    langCode == "ar"
                        ? category.nameAr
                        : langCode == "en"
                        ? category.name
                        : category.nameTr,
                    style: AppFont.font18W700Black.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const Gap(4),
                  Text(
                    'Shop from the best products'.tr,
                    style: AppFont.font12W400Grey1.copyWith(
                      color: Colors.white.withAlpha(229),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubcategoriesSection extends StatelessWidget {
  final List<CategoryModel> subcategories;
  final String langCode;

  const _SubcategoriesSection({
    required this.subcategories,
    required this.langCode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(Icons.apps, size: 20, color: AppColor.primary),
              const Gap(8),
              Text(
                'Explore Subcategories'.tr,
                style: AppFont.font16W700Black,
              ),
            ],
          ),
        ),
        const Gap(12),
        SizedBox(
          height: 100,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: subcategories.length,
            separatorBuilder: (context, index) => const Gap(12),
            itemBuilder: (context, index) {
              final subcategory = subcategories[index];
              return _SubcategoryCard(
                subcategory: subcategory,
                langCode: langCode,
              );
            },
          ),
        ),
        const Gap(16),
      ],
    );
  }
}

class _SubcategoryCard extends StatelessWidget {
  final CategoryModel subcategory;
  final String langCode;

  const _SubcategoryCard({
    required this.subcategory,
    required this.langCode,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.to(() => CategoryScreen(category: subcategory),
            preventDuplicates: false);
      },
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(12),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (subcategory.image != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: ImageOrSvg(
                  subcategory.image!,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                ),
              )
            else
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColor.primary.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    subcategory.icon ?? '📦',
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
            const Gap(8),
            Text(
              langCode == "ar"
                  ? subcategory.nameAr
                  : langCode == "en"
                  ? subcategory.name
                  : subcategory.nameTr,
              style: AppFont.font12W600Black,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class AnimatedProductCard extends StatelessWidget {
  final dynamic product;
  final int index;

  const AnimatedProductCard({
    super.key,
    required this.product,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: ValueKey(product.id),
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (index * 100).clamp(0, 500)),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        final clampedValue = value.clamp(0.0, 1.0);
        return Transform.scale(
          scale: clampedValue,
          child: Opacity(
            opacity: clampedValue,
            child: RepaintBoundary(
              child: ProductTile(product: product),
            ),
          ),
        );
      },
    );
  }
}

class _CategoryScreenSkeleton extends StatelessWidget {
  const _CategoryScreenSkeleton();

  @override
  Widget build(BuildContext context) {
    final langCode = Get.locale?.languageCode ?? 'ar';
    return Stack(
      children: [
        _CategorySkeletonBody(
          child: CustomScrollView(
            slivers: [
              _BreadcrumbAppBar(
                breadcrumb: [_placeholderCrumb],
                langCode: langCode,
                showLeading: false,
              ),
              SliverToBoxAdapter(
                child: _CategoryHeaderCard(
                  category: _placeholderCategory(),
                  langCode: langCode,
                ),
              ),
              SliverToBoxAdapter(
                child: _SubcategoriesSection(
                  subcategories: List.generate(
                    4,
                    (index) => _placeholderCategory(id: 'child-$index'),
                  ),
                  langCode: langCode,
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    '12 ${'products found'.tr}',
                    style: AppFont.font14W600Black.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: Gap(16)),
              const SliverToBoxAdapter(child: _ProductTilesSkeleton()),
              const SliverToBoxAdapter(child: Gap(80)),
            ],
          ),
        ),
        PositionedDirectional(
          top: MediaQuery.paddingOf(context).top,
          start: 4,
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColor.primary),
            onPressed: Get.back,
          ),
        ),
      ],
    );
  }
}

class _CategorySkeletonBody extends StatelessWidget {
  const _CategorySkeletonBody({required this.child});

  final Widget child;

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
      child: child,
    );
  }
}

class _ProductTilesSkeleton extends StatelessWidget {
  const _ProductTilesSkeleton();

  @override
  Widget build(BuildContext context) {
    return MasonryGridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      crossAxisCount: 2,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      itemCount: 4,
      itemBuilder: (_, index) => ProductTile(product: _placeholderProduct(index)),
    );
  }
}

class _LoadingProductsGrid extends StatelessWidget {
  const _LoadingProductsGrid();

  @override
  Widget build(BuildContext context) {
    return const SliverToBoxAdapter(
      child: _CategorySkeletonBody(child: _ProductTilesSkeleton()),
    );
  }
}

CategoryModel _placeholderCategory({String id = 'skeleton'}) {
  return CategoryModel(
    id: id,
    name: 'Category name',
    nameTr: 'Category name',
    nameAr: 'اسم التصنيف',
    slug: id,
    level: 0,
    order: 0,
    isActive: true,
    createdAt: '',
    updatedAt: '',
    v: 0,
  );
}

final _placeholderCrumb = BreadcrumbItem(
  id: 'skeleton',
  name: 'Category',
  nameAr: 'التصنيف',
  nameTr: 'Category',
  slug: 'skeleton',
);

ProductModel _placeholderProduct(int index) {
  return ProductModel(
    id: 'skeleton-$index',
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

class _EmptyProductsState extends StatelessWidget {
  const _EmptyProductsState();

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 80,
              color: Colors.grey[300],
            ),
            const Gap(24),
            Text(
              'No products found'.tr,
              style: AppFont.font18W700Black,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
