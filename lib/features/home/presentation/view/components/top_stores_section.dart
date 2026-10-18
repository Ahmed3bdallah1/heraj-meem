import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj/config/app_font.dart';
import 'package:heraj/helper/riverpod.dart';
import 'package:heraj/ui/shared_widgets/image_or_svg.dart';
import '../../../../store/data/models/store_model.dart';
import '../../../../store/presentation/view/all_top_stores_screen.dart';
import '../../../../store/presentation/view/store_details_screen.dart';
import '../../managers/fetch_home_data_provider.dart';
import 'real_estate_section.dart';

class TopStoresSection extends ConsumerWidget {
  const TopStoresSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.watch(fetchHomeDataProvider);
    return provider.customWhen(
      ref: ref,
      refreshable: fetchHomeDataProvider.future,
      loading: () => const ShimmerSection(),
      data: (homeData) {
        final stores = homeData.topStores;
        if (stores.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Best Companies'.tr,
                        style: AppFont.font18W700Black,
                      ),
                      const Gap(2),
                      Text(
                        'Shop from the best companies'.tr,
                        style: AppFont.font12w500Grey2,
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      Get.to(() => const AllTopStoresScreen());
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'View All'.tr,
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
            Container(
              constraints: const BoxConstraints(
                maxHeight: 550,
                minHeight: 500,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: MasonryGridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 10,
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: stores.length,
                  itemBuilder: (context, index) {
                    final store = stores[index];
                    return _StoreCard(store: store);
                  },
                ),
              ),
            ),
            const Gap(20),
          ],
        );
      },
    );
  }
}

class _StoreCard extends StatelessWidget {
  final StoreModel store;

  const _StoreCard({required this.store});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Get.to(() => StoreDetailsScreen(vendorId: store.id));
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 300,
          minWidth: 200,
          minHeight: 210,
          maxHeight: 250,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                SizedBox(
                  height: 170,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 30),
                    child: ClipRRect(
                      borderRadius: BorderRadiusDirectional.only(
                        topStart: Radius.circular(12),
                        topEnd: Radius.circular(12),
                        bottomStart: Radius.circular(12),
                      ),
                      child: store.banner != null && store.banner!.isNotEmpty
                          ? ImageOrSvg(
                              store.banner!,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              width: double.infinity,
                              height: double.infinity,
                              color: AppColor.primary2,
                              child: Icon(
                                Icons.store,
                                color: AppColor.grey2,
                                size: 40,
                              ),
                            ),
                    ),
                  ),
                ),
                PositionedDirectional(
                  bottom: 0,
                  start: 10,
                  child: Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white,
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(25),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadiusGeometry.circular(12),
                        child: store.logo != null && store.logo!.isNotEmpty
                            ? ImageOrSvg(
                                store.logo!,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                isLocal: false,
                              )
                            : Container(
                                color: AppColor.grey1,
                                child: Icon(
                                  Icons.store,
                                  color: AppColor.grey2,
                                  size: 24,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
                if (store.hasPremiumBadge)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColor.primary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.verified,
                            size: 12,
                            color: Colors.white,
                          ),
                          const Gap(2),
                          Text(
                            'Verified'.tr,
                            style: AppFont.font10w400Black.copyWith(
                              color: Colors.white,
                              fontSize: 8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(
                  top: 0, left: 12, right: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    store.storeName,
                    style: AppFont.font14W700Black,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                  const Gap(6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        store.stats.rating.toStringAsFixed(1),
                        style: AppFont.font12W600Black,
                      ),
                      const Gap(2),
                      Icon(
                        Icons.star,
                        size: 14,
                        color: Colors.amber,
                      ),
                      const Gap(4),
                      Text(
                        '(${store.stats.totalReviews})',
                        style: AppFont.font10w400Black.copyWith(
                          color: AppColor.grey2,
                        ),
                      ),
                    ],
                  ),
                  const Gap(8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              store.stats.totalProducts.toString(),
                              style: AppFont.font12W600Black,
                            ),
                            const Gap(2),
                            Text(
                              'Products'.tr,
                              style: AppFont.font10w400Black.copyWith(
                                color: AppColor.grey2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 30,
                        color: AppColor.grey1,
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              store.stats.totalOrders.toString(),
                              style: AppFont.font12W600Black,
                            ),
                            const Gap(2),
                            Text(
                              'Orders'.tr,
                              style: AppFont.font10w400Black.copyWith(
                                color: AppColor.grey2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
