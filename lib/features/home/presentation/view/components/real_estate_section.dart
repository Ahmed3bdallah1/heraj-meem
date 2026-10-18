import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj/config/app_color.dart';
import 'package:heraj/config/app_font.dart';
import 'package:heraj/helper/riverpod.dart';
import 'package:heraj/ui/shared_widgets/custom_filled_button.dart';
import 'package:heraj/ui/shared_widgets/shimmer_effect.dart';
import '../../../../products/presentation/view/sell_all_products_screen.dart';
import '../../../../products/presentation/view/widgets/product_tile.dart';
import '../../managers/fetch_home_data_provider.dart';
import '../widgets/home_product_tile.dart';

class RealEstateSection extends ConsumerWidget {
  const RealEstateSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.watch(fetchHomeDataProvider);
    return provider.customWhen(
      ref: ref,
      refreshable: fetchHomeDataProvider.future,
      loading: () => const ShimmerSection(),
      data: (homeData) {
        final productList = homeData.realEstate;
        if (productList.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)
                  .copyWith(bottom: 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Real Estate'.tr,
                    style: AppFont.font18W700Black,
                  ),
                  TextButton(
                    onPressed: () {
                      Get.to(() => SectionProductsScreen(
                            title: 'Real Estate'.tr,
                            products: productList,
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
            SizedBox(
              height: 270,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                itemCount: productList.length,
                separatorBuilder: (_, __) => const Gap(10),
                itemBuilder: (context, index) {
                  final product = productList[index];
                  return ProductTile(product: product);
                },
              ),
            ),
            const Gap(20),
          ],
        );
      },
    );
  }
}

class HotDealsProductsSection extends ConsumerWidget {
  const HotDealsProductsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.watch(fetchHomeDataProvider);
    return provider.customWhen(
      ref: ref,
      refreshable: fetchHomeDataProvider.future,
      loading: () => const ShimmerSection(),
      data: (homeData) {
        final productList = homeData.hotDeals;
        if (productList.isEmpty) return const SizedBox.shrink();

        return Container(
          decoration: BoxDecoration(color: AppColor.primary2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12)
                        .copyWith(bottom: 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      spacing: 4,
                      children: [
                        Icon(
                          Icons.local_offer_outlined,
                          color: AppColor.danger,
                        ),
                        Text(
                          'Hot Deals'.tr,
                          style: AppFont.font18W700Black
                              .copyWith(color: AppColor.danger),
                        ),
                      ],
                    ),
                    CustomFilledButton(
                      text: 'See More'.tr,
                      color: AppColor.danger,
                      textSize: 12,
                      width: 70,
                      height: 15,
                      padding: 0,
                      verticalPadding: 0,
                      radius: 8,
                      onPressed: () {
                        Get.to(() => SectionProductsScreen(
                              title: 'Hot Deals'.tr,
                              products: productList,
                              primaryColor: AppColor.danger,
                            ));
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 350,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                  itemCount: productList.length,
                  separatorBuilder: (_, __) => const Gap(10),
                  itemBuilder: (context, index) {
                    final product = productList[index];
                    return ProductTile(product: product);
                  },
                ),
              ),
              const Gap(20),
            ],
          ),
        );
      },
    );
  }
}

class AdminProductsSection extends ConsumerWidget {
  const AdminProductsSection({super.key});

  ProductStatus _getProductStatus(int index) {
    final statuses = [
      ProductStatus.sellingFast,
      ProductStatus.bestSeller,
      ProductStatus.almostGone,
      ProductStatus.none,
    ];
    return statuses[index % statuses.length];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.watch(fetchHomeDataProvider);
    return provider.customWhen(
      ref: ref,
      refreshable: fetchHomeDataProvider.future,
      loading: () => const ShimmerSection(),
      data: (homeData) {
        final productList = homeData.adminProducts;
        if (productList.isEmpty) return const SizedBox.shrink();

        return Container(
          decoration: BoxDecoration(color: Colors.white),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.symmetric(
                        horizontal: 16, vertical: 12)
                    .copyWith(bottom: 0, end: 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      spacing: 8,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColor.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.store,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        Text(
                          'Official Store'.tr,
                          style: AppFont.font18W700Black.copyWith(
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () {
                        Get.to(() => SectionProductsScreen(
                              title: 'Official Store'.tr,
                              products: productList,
                            ));
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFFFF9800),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'See All'.tr,
                            style: AppFont.font14W600Primary.copyWith(
                              color: const Color(0xFFFF9800),
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios,
                            size: 14,
                            color: Color(0xFFFF9800),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 310,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: productList.length,
                  separatorBuilder: (_, __) => const Gap(12),
                  itemBuilder: (context, index) {
                    final product = productList[index];
                    return HomeProductTile(
                      product: product,
                      status: _getProductStatus(index),
                    );
                  },
                ),
              ),
              const Gap(20),
            ],
          ),
        );
      },
    );
  }
}

class ShimmerSection extends StatelessWidget {
  const ShimmerSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 3,
        itemBuilder: (context, index) {
          return Container(
            width: 180,
            margin: const EdgeInsets.only(right: 12),
            child: ShimmerEffect(
              enable: true,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColor.grey1,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
