import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:fpdart/fpdart.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj_meem/config/app_font.dart';
import 'package:heraj_meem/features/categories/presentation/view/categories_layout.dart';
import 'package:heraj_meem/features/products/presentation/view/widgets/product_tile.dart';
import 'package:heraj_meem/features/store/data/models/open_store_model.dart';
import 'package:heraj_meem/helper/extensions/adaptive_view.dart';
import 'package:heraj_meem/helper/riverpod.dart';
import 'package:heraj_meem/ui/shared_widgets/image_or_svg.dart';
import 'package:heraj_meem/ui/shared_widgets/shimmer_effect.dart';
import 'package:logger/logger.dart';
import '../../../../core/service/localization_service/localization_service.dart';
import '../../../../main.dart';
import '../../../../ui/shared_widgets/custom_slider.dart';
import '../../../categories/presentation/view/all_categories_screen.dart';
import '../../../categories/presentation/view/category_screen.dart';
import '../../../categories/data/models/main_category_model.dart';
import '../../../home/presentation/view/widgets/home_header_widget.dart';
import '../../../home/presentation/view/widgets/silder_item_widget.dart';
import '../../../products/presentation/view/product_details_screen.dart';
import 'store_category_screen.dart';
import '../managers/store_page_provider.dart';

class OpenStoreView extends ConsumerWidget {
  const OpenStoreView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scaffoldKey = GlobalKey<ScaffoldState>();
    final openStoreProvider = ref.watch(fetchStorePageProvider);
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.white,
      endDrawer: const Drawer(
        child: AllCategoriesScreen(
          isOpenStore: true,
          isFromDrawer: true,
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(fetchStorePageProvider);
        },
        child: Padding(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top,
          ),
          child: openStoreProvider.customWhen(
            ref: ref,
            refreshable: fetchStorePageProvider.future,
            loading: () => const _OpenStoreShimmer(),
            data: (store) {
              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: HomeHeaderWidget(
                      scaffoldKey: scaffoldKey,
                      isHome: false,
                    ),
                  ),
                  if (store.offers.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Offers'.tr,
                                  style: AppFont.font18W700Black,
                                ),
                                GestureDetector(
                                  onTap: () =>
                                      Get.to(() => const AllCategoriesScreen(
                                            isOpenStore: true,
                                          )),
                                  child: Row(
                                    children: [
                                      Text(
                                        'See More'.tr,
                                        style: AppFont.font14W600Primary,
                                      ),
                                      const Gap(4),
                                      Icon(
                                        Icons.arrow_forward_ios,
                                        size: 14,
                                        color: AppColor.primary,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Gap(8),
                          SizedBox(
                            height: 110,
                            child: ListView.separated(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              scrollDirection: Axis.horizontal,
                              itemCount: store.offers.length,
                              separatorBuilder: (context, index) =>
                                  const Gap(12),
                              itemBuilder: (context, index) {
                                final offer = store.offers[index];
                                return CategoryIconItem(
                                  category: CategoryModel.fromOffer(offer),
                                  isOpenStore: true,
                                  isNew: offer.isNew,
                                );
                              },
                            ),
                          ),
                          const Gap(16),
                        ],
                      ),
                    ),
                  SliverToBoxAdapter(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Gap(10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: CustomSlider(
                          store.sliders.map((e) => SliderItem(e)).toList(),
                          height: 160,
                          autoPlay: true,
                          onPageChanged: (index, _) {
                            ref.read(sliderIndexProvider.notifier).state =
                                index;
                          },
                        ),
                      ),
                      const Gap(10),
                    ],
                  )),
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Categories'.tr,
                                style: AppFont.font18W700Black,
                              ),
                              TextButton(
                                onPressed: () =>
                                    Get.to(() => const AllCategoriesScreen(
                                          isOpenStore: true,
                                        )),
                                child: Text(
                                  'See More'.tr,
                                  style: AppFont.font14W600Primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        MasonryGridView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverSimpleGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: context.adaptiveValue<int>(
                              mobile: 4,
                              tablet: 6,
                              desktop: 8,
                            ),
                          ),
                          itemCount: store.categories.length >
                                  context.adaptiveValue<int>(mobile: 8, tablet: 12, desktop: 16)
                              ? context.adaptiveValue<int>(mobile: 4, tablet: 6, desktop: 8)
                              : store.categories.length,
                          itemBuilder: (context, index) {
                            final category = store.categories[index];
                            return CategoryIconItem(
                              category: category,
                              isOpenStore: true,
                            );
                          },
                        ),
                        const Gap(16),
                      ],
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: StaggeredGrid.count(
                            crossAxisCount: 4,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            children: [
                              ...?store.banners?.top.mapWithIndex((e, index) {
                                return StaggeredGridTile.count(
                                  crossAxisCellCount: 2,
                                  mainAxisCellCount: 1,
                                  child: _BannerItemWidget(banner: e),
                                );
                              }),
                            ],
                          ),
                        ),
                        const Gap(16),
                      ],
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: StoreSections(
                      store: store,
                    ),
                  ),
                  if (store.banners!.bottom.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Gap(10),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: CustomSlider(
                              store.banners?.bottom
                                  .map((e) => BannerSliderItem(banner: e))
                                  .toList(),
                              height: 160,
                              autoPlay: true,
                              onPageChanged: (index, _) {
                                ref.read(sliderIndexProvider.notifier).state =
                                    index;
                              },
                            ),
                          ),
                          const Gap(10),
                        ],
                      ),
                    ),
                  SliverGap(MediaQuery.of(context).padding.bottom + 50),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class StoreSections extends StatelessWidget {
  final OpenStoreModel store;

  const StoreSections({
    super.key,
    required this.store,
  });

  @override
  Widget build(BuildContext context) {
    final langCode = getIt<LocaleService>().getLocale().locale.languageCode;

    return Column(
      children: [
        ...store.sections.mapWithIndex((section, index) {
          if (section.products.isEmpty) {
            return SizedBox();
          }
          return Column(
            children: [
              if (index == 2) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: StaggeredGrid.count(
                    crossAxisCount: 4,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    children: [
                      ...?store.banners?.middle.mapWithIndex((e, index) {
                        return StaggeredGridTile.count(
                          crossAxisCellCount: 2,
                          mainAxisCellCount: 1,
                          child: _BannerItemWidget(banner: e),
                        );
                      }),
                    ],
                  ),
                ),
                const Gap(16)
              ],
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      langCode == "ar"
                          ? section.category?.nameAr ?? ""
                          : langCode == "en"
                              ? section.category?.name ?? ""
                              : section.category?.nameTr ?? "",
                      style: AppFont.font18W700Black,
                    ),
                    TextButton(
                      onPressed: () {
                        if (section.category != null) {
                          Get.to(() => StoreCategoryScreen(section.category!));
                        }
                      },
                      child: Text(
                        'See More'.tr,
                        style: AppFont.font14W600Primary,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 360,
                child: MasonryGridView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  gridDelegate:
                      const SliverSimpleGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 1,
                  ),
                  mainAxisSpacing: 12,
                  itemCount: section.products.length,
                  itemBuilder: (context, index) {
                    final product = section.products[index];
                    return ProductTile(product: product);
                  },
                ),
              ),
              const Gap(16),
            ],
          );
        }),
      ],
    );
  }
}

class _OpenStoreShimmer extends StatelessWidget {
  const _OpenStoreShimmer();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        const SliverToBoxAdapter(
          child: HomeHeaderWidget(
            isHome: true,
          ),
        ),
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Gap(10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: ShimmerEffect(
                  enable: true,
                  child: Container(
                    height: 160,
                    decoration: BoxDecoration(
                      color: AppColor.grey1,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const Gap(10),
            ],
          ),
        ),
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ShimmerEffect(
                      enable: true,
                      child: Container(
                        width: 100,
                        height: 24,
                        decoration: BoxDecoration(
                          color: AppColor.grey1,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    ShimmerEffect(
                      enable: true,
                      child: Container(
                        width: 80,
                        height: 20,
                        decoration: BoxDecoration(
                          color: AppColor.grey1,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(12),
              MasonryGridView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate:
                    const SliverSimpleGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                ),
                itemCount: 8,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      ShimmerEffect(
                        enable: true,
                        child: Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            color: AppColor.grey1,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      const Gap(8),
                      ShimmerEffect(
                        enable: true,
                        child: Container(
                          width: 60,
                          height: 12,
                          decoration: BoxDecoration(
                            color: AppColor.grey1,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const Gap(16),
            ],
          ),
        ),
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StaggeredGrid.count(
                crossAxisCount: 4,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
                children: [
                  StaggeredGridTile.count(
                    crossAxisCellCount: 4,
                    mainAxisCellCount: 2,
                    child: ShimmerEffect(
                      enable: true,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColor.grey1,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  StaggeredGridTile.count(
                    crossAxisCellCount: 2,
                    mainAxisCellCount: 2,
                    child: ShimmerEffect(
                      enable: true,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColor.grey1,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  StaggeredGridTile.count(
                    crossAxisCellCount: 2,
                    mainAxisCellCount: 2,
                    child: ShimmerEffect(
                      enable: true,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColor.grey1,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const Gap(16),
            ],
          ),
        ),
        ...List.generate(3, (sectionIndex) {
          return SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ShimmerEffect(
                        enable: true,
                        child: Container(
                          width: 120,
                          height: 24,
                          decoration: BoxDecoration(
                            color: AppColor.grey1,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      ShimmerEffect(
                        enable: true,
                        child: Container(
                          width: 80,
                          height: 20,
                          decoration: BoxDecoration(
                            color: AppColor.grey1,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(12),
                SizedBox(
                  height: 270,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: 4,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: ShimmerEffect(
                          enable: true,
                          child: Container(
                            width: 160,
                            height: 270,
                            decoration: BoxDecoration(
                              color: AppColor.grey1,
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const Gap(16),
              ],
            ),
          );
        }),
        const SliverGap(24),
      ],
    );
  }
}

void _handleBannerNavigation(BannerItem banner) {
  if (banner.linkId == null || banner.linkId!.isEmpty) {
    return;
  }

  switch (banner.linkType.toLowerCase()) {
    case 'product':
      Get.to(() => ProductDetailsScreen(productId: banner.linkId!));
      break;
    case 'category':
      final category = CategoryModel(
        id: banner.linkId!,
        name: 'Offers',
        nameTr: "Kampanyalar",
        nameAr: "عروض",
        slug: '',
        level: 1,
        order: 0,
        isActive: true,
        createdAt: '',
        updatedAt: '',
        v: 0,
      );
      Get.to(() => CategoryScreen(category: category));
      break;
    case 'admincategory':
      final category = CategoryModel(
        id: banner.linkId!,
        name: 'Offers',
        nameTr: "Kampanyalar",
        nameAr: "عروض",
        slug: '',
        level: 1,
        order: banner.order,
        isActive: banner.isActive,
        createdAt: banner.createdAt,
        updatedAt: banner.updatedAt,
        v: banner.v,
      );
      Get.to(() => StoreCategoryScreen(category));
      break;
    default:
      break;
  }
}

class _BannerItemWidget extends StatelessWidget {
  final BannerItem banner;

  const _BannerItemWidget({required this.banner});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _handleBannerNavigation(banner),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: ImageOrSvg(
          banner.image ?? "",
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

// Widget for banner items in slider
class BannerSliderItem extends StatelessWidget {
  final BannerItem banner;

  const BannerSliderItem({required this.banner, super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _handleBannerNavigation(banner),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: MediaQuery.of(context).size.width,
          decoration: const BoxDecoration(
            color: Colors.white,
          ),
          child: ImageOrSvg(
            banner.image ?? "",
            fit: BoxFit.fill,
            isLocal: false,
          ),
        ),
      ),
    );
  }
}
