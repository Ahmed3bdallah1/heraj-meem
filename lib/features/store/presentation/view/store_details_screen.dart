import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj_meem/config/app_font.dart';
import 'package:heraj_meem/core/service/auth_service.dart';
import 'package:heraj_meem/features/products/presentation/view/widgets/product_tile.dart';
import 'package:heraj_meem/helper/riverpod.dart';
import 'package:heraj_meem/ui/shared_widgets/container_button.dart';
import 'package:heraj_meem/ui/shared_widgets/image_or_svg.dart';
import 'package:heraj_meem/ui/shared_widgets/shimmer_effect.dart';
import 'package:heraj_meem/ui/ui.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';
import '../managers/store_details_provider.dart';
import '../managers/stores_provider.dart';

class StoreDetailsScreen extends ConsumerStatefulWidget {
  final String vendorId;

  const StoreDetailsScreen({
    super.key,
    required this.vendorId,
  });

  @override
  ConsumerState<StoreDetailsScreen> createState() => _StoreDetailsScreenState();
}

class _StoreDetailsScreenState extends ConsumerState<StoreDetailsScreen> {
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final storeDetailsAsync =
        ref.watch(fetchStoreDetailsProvider(widget.vendorId));
    final currentUser = ref.watch(userProvider);
    return Scaffold(
      body: storeDetailsAsync.customWhen(
        ref: ref,
        refreshable: fetchStoreDetailsProvider(widget.vendorId).future,
        data: (store) {
          final isOwnStore = currentUser?.id == store.userId.id;
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back, color: AppColor.black),
                  onPressed: () => Get.back(),
                ),
                title: Text(
                  store.storeName,
                  style: AppFont.font18W700Black,
                ),
                backgroundColor: Colors.white,
                elevation: 0,
              ),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 20,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      children: [
                        if (store.banner != null && store.banner!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0)
                                .copyWith(bottom: 50),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: ImageOrSvg(
                                store.banner!,
                                width: double.infinity,
                                height: 200,
                                fit: BoxFit.cover,
                              ),
                            ),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0)
                                .copyWith(bottom: 50),
                            height: 200,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppColor.primary.withAlpha(25),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.store,
                              size: 80,
                              color: AppColor.primary,
                            ),
                          ),
                        PositionedDirectional(
                          bottom: 5,
                          start: 16,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white,
                                width: 4,
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
                              borderRadius: BorderRadius.circular(12),
                              child: ImageOrSvg(
                                store.logo!,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        PositionedDirectional(
                          end: 10,
                          bottom: 0,
                          child: Row(
                            children: [
                              Opacity(
                                opacity: isOwnStore ? 0 : 1.0,
                                child: ContainerButton(
                                  size: 40,
                                  isCircle: true,
                                  color: AppColor.primary,
                                  iconColor: AppColor.white,
                                  icon: Icons.phone,
                                  onTap: isOwnStore
                                      ? null
                                      : () {
                                          if (store.phone.isNotEmpty) {
                                            UIHelper.phoneCall(store.phone);
                                          }
                                        },
                                ),
                              ),
                              const Gap(12),
                              Opacity(
                                opacity: isOwnStore ? 0 : 1.0,
                                child: ContainerButton(
                                  size: 40,
                                  isCircle: true,
                                  icon: Icons.share,
                                  iconColor: AppColor.primary,
                                  color: AppColor.white,
                                  onTap: isOwnStore
                                      ? null
                                      : () {
                                          SharePlus.instance.share(ShareParams(
                                            title:
                                                '${store.storeName}\n${store.phone}',
                                          ));
                                        },
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Gap(16),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        store.storeName,
                                        style: AppFont.font20W700Black,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (store.status == 'approved')
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.withAlpha(50),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.verified,
                                              size: 18,
                                              color: Colors.blue,
                                            ),
                                            const Gap(4),
                                            Text(
                                              "Verified".tr,
                                              style: AppFont.font12W600White
                                                  .copyWith(color: Colors.blue),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                                const Gap(8),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.star,
                                      size: 18,
                                      color: Colors.amber,
                                    ),
                                    const Gap(4),
                                    Text(
                                      store.stats.rating > 0
                                          ? store.stats.rating
                                              .toStringAsFixed(1)
                                          : '0.0',
                                      style: AppFont.font14W600Black,
                                    ),
                                    const Gap(8),
                                    Text(
                                      "(${store.stats.totalReviews} ${'reviews'.tr})",
                                      style: AppFont.font12W400Grey1,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              icon: Icons.chat_bubble_outline,
                              iconColor: Colors.purple,
                              label: "Reviews".tr,
                              value: store.stats.totalReviews.toString(),
                            ),
                          ),
                          const Gap(12),
                          Expanded(
                            child: _StatCard(
                              icon: Icons.star_outline,
                              iconColor: Colors.amber,
                              label: "Rating".tr,
                              value: store.stats.rating > 0
                                  ? store.stats.rating.toStringAsFixed(1)
                                  : '0.0',
                            ),
                          ),
                          const Gap(12),
                          Expanded(
                            child: _StatCard(
                              icon: Icons.shopping_bag_outlined,
                              iconColor: Colors.green,
                              label: "Orders".tr,
                              value: store.stats.totalOrders.toString(),
                            ),
                          ),
                          const Gap(12),
                          Expanded(
                            child: _StatCard(
                              icon: Icons.inventory_2_outlined,
                              iconColor: Colors.blue,
                              label: "Products".tr,
                              value: store.stats.totalProducts.toString(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        constraints: const BoxConstraints(
                          maxHeight: 40,
                          maxWidth: 200,
                          minWidth: 100,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: _TabButton(
                                label: 'Products'.tr,
                                isSelected: _selectedTabIndex == 0,
                                onTap: () {
                                  setState(() {
                                    _selectedTabIndex = 0;
                                  });
                                },
                              ),
                            ),
                            Expanded(
                              child: _TabButton(
                                label: 'About'.tr,
                                isSelected: _selectedTabIndex == 1,
                                onTap: () {
                                  setState(() {
                                    _selectedTabIndex = 1;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (_selectedTabIndex == 0)
                _buildProductsSliver(store.id, ref)
              else
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16).copyWith(
                        bottom: MediaQuery.of(context).padding.bottom),
                    child: _buildAboutTab(store),
                  ),
                ),
            ],
          );
        },
        loading: () {
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back, color: AppColor.black),
                  onPressed: () => Get.back(),
                ),
                title: Text(
                  "Store Details".tr,
                  style: AppFont.font18W700Black,
                ),
                backgroundColor: Colors.white,
                elevation: 0,
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: List.generate(
                      5,
                      (index) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProductsSliver(String vendorId, WidgetRef ref) {
    final productsAsync = ref.watch(fetchStoreProductsProvider(vendorId));
    return productsAsync.customWhen(
      ref: ref,
      refreshable: fetchStoreProductsProvider(vendorId).future,
      data: (products) {
        if (products.data.isEmpty) {
          return SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24)
                  .copyWith(bottom: MediaQuery.of(context).padding.bottom),
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 48, horizontal: 16),
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      size: 80,
                      color: Colors.grey[300],
                    ),
                    const Gap(24),
                    Text(
                      'No products yet'.tr,
                      style: AppFont.font18W700Black,
                      textAlign: TextAlign.center,
                    ),
                    const Gap(8),
                    Text(
                      'This store hasn\'t added any products yet'.tr,
                      style: AppFont.font14W500Black.copyWith(
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        return SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverMasonryGrid(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return ProductTile(product: products.data[index]);
              },
              childCount: products.data.length,
            ),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
            ),
          ),
        );
      },
      loading: () {
        return SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return ShimmerEffect(
                  enable: true,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              },
              childCount: 6,
            ),
          ),
        );
      },
    );
  }

  Widget _buildAboutTab(store) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
          // About Section
          Text(
            'About'.tr,
            style: AppFont.font18W700Black,
          ),
          const Gap(12),
          Text(
            store.description ?? store.storeName,
            style: AppFont.font14W500Black.copyWith(
              color: Colors.grey[700],
            ),
          ),
          const Gap(32),
          // Contact Information Section
          Text(
            'Contact Information'.tr,
            style: AppFont.font18W700Black,
          ),
          const Gap(16),
          // Address
          _ContactInfoRow(
            icon: Icons.location_on,
            label: 'Address'.tr,
            value: store.address,
          ),
          const Gap(16),
          // Phone
          _ContactInfoRow(
            icon: Icons.phone,
            label: 'Phone'.tr,
            value: store.phone,
          ),
          const Gap(16),
          // Email
          _ContactInfoRow(
            icon: Icons.email,
            label: 'Email'.tr,
            value: store.email,
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
            color: isSelected ? AppColor.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColor.primary.withAlpha(200),
                      blurRadius: 8,
                    ),
                  ]
                : null),
        child: Center(
          child: Text(
            label,
            style: isSelected
                ? AppFont.font14W600Black.copyWith(color: Colors.white)
                : AppFont.font14W500Black.copyWith(color: Colors.black),
          ),
        ),
      ),
    );
  }
}

class _ContactInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ContactInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: AppColor.primary,
          size: 24,
        ),
        const Gap(12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppFont.font14W500Black,
              ),
              const Gap(4),
              Text(
                value,
                style: AppFont.font14W500Black.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              color: iconColor.withAlpha(50),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(icon, color: iconColor, size: 24),
            ),
          ),
          const Gap(8),
          Text(
            value,
            style: AppFont.font16W700Black,
          ),
          const Gap(4),
          Text(
            label,
            style: AppFont.font12W400Grey1,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
