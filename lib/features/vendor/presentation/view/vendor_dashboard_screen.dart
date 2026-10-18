import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj/config/app_font.dart';
import 'package:heraj/config/app_string.dart';
import 'package:heraj/core/service/auth_service.dart';
import 'package:heraj/features/products/data/models/product_model.dart';
import 'package:heraj/features/root/controller/root_controller.dart';
import 'package:heraj/features/store/data/models/store_model.dart';
import 'package:heraj/features/vendor/data/models/vendor_profile_model.dart';
import 'package:heraj/features/vendor/presentation/managers/vendor_provider.dart';
import 'package:heraj/helper/riverpod.dart';
import 'package:heraj/ui/shared_widgets/image_or_svg.dart';
import 'package:heraj/ui/shared_widgets/shimmer_effect.dart';

import '../../../notifications/presentation/managers/fetch_notificatons_provider.dart';
import '../../../notifications/presentation/view/notifications_screen.dart';

class VendorDashboardScreen extends ConsumerWidget {
  const VendorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(fetchVendorProfileProvider);
    final user = ref.watch(userProvider);

    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: profileAsync.customWhen(
              refreshable: fetchVendorProfileProvider.future,
              ref: ref,
              loading: () {
                return CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      expandedHeight: 120,
                      floating: false,
                      pinned: true,
                      backgroundColor: Colors.white,
                      elevation: 0,
                      flexibleSpace:
                          FlexibleSpaceBar(background: _buildHeaderShimmer()),
                    ),
                    SliverToBoxAdapter(child: _buildContentShimmer()),
                  ],
                );
              },
              data: (profile) {
                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(fetchVendorProfileProvider);
                    ref.invalidate(fetchMyProductsProvider);
                  },
                  child: CustomScrollView(
                    slivers: [
                      SliverAppBar(
                        expandedHeight: 120,
                        floating: false,
                        pinned: true,
                        backgroundColor: Colors.white,
                        elevation: 0,
                        flexibleSpace: FlexibleSpaceBar(
                          background: _buildHeader(profile, user?.name ?? '',ref),
                        ),
                      ),
                      SliverToBoxAdapter(
                          child: _buildContent(context, ref, profile)),
                    ],
                  ),
                );
              }),
        ));
  }

  Widget _buildHeader(VendorProfileModel profile, String userName,WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppColor.grey1,
            backgroundImage: profile.logo != null && profile.logo!.isNotEmpty
                ? NetworkImage(profile.logo!)
                : null,
            child: profile.logo == null || profile.logo!.isEmpty
                ? Icon(Icons.store, color: AppColor.primary, size: 30)
                : null,
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Welcome Back!'.tr,
                  style: AppFont.font14W600Black.copyWith(
                    color: AppColor.primary,
                  ),
                ),
                Text(
                  profile.storeName,
                  style: AppFont.font18W700Black,
                ),
              ],
            ),
          ),
          ref.watch(unreadNotificationCountProvider).when(
            data: (unreadCount) {
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    icon: Icon(
                      CupertinoIcons.bell,
                      color: AppColor.black,
                      size: 24,
                    ),
                    onPressed: () {
                      Get.to(() => const NotificationsScreen());
                    },
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColor.danger,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColor.white,
                            width: 2,
                          ),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Center(
                          child: Text(
                            unreadCount > 99 ? '99+' : '$unreadCount',
                            style: AppFont.font10w400Black.copyWith(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
            loading: () => IconButton(
              icon: Icon(
                CupertinoIcons.bell,
                color: AppColor.black,
                size: 24,
              ),
              onPressed: () {
                Get.to(() => const NotificationsScreen());
              },
            ),
            error: (_, __) => IconButton(
              icon: Icon(
                CupertinoIcons.bell,
                color: AppColor.black,
                size: 24,
              ),
              onPressed: () {
                Get.to(() => const NotificationsScreen());
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderShimmer() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          ShimmerEffect(
            enable: true,
            child: CircleAvatar(radius: 30, backgroundColor: Colors.white),
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ShimmerEffect(
                  enable: true,
                  child: Container(
                    height: 14,
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const Gap(8),
                ShimmerEffect(
                  enable: true,
                  child: Container(
                    height: 18,
                    width: 150,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentShimmer() {
    return Column(
      children: [
        const Gap(16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: List.generate(
              3,
              (index) => Expanded(
                child: ShimmerEffect(
                  enable: true,
                  child: Container(
                    height: 100,
                    margin: EdgeInsets.only(right: index < 2 ? 8 : 0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent(
      BuildContext context, WidgetRef ref, VendorProfileModel profile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Gap(16),
        _buildStatistics(profile.stats),
        const Gap(24),
        TopViewsAds(),
        const Gap(24),
        _buildRecentActivity(context, ref),
        const Gap(24),
      ],
    );
  }

  Widget _buildStatistics(StoreStats stats) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              value: stats.totalProducts.toString(),
              label: 'My Ads'.tr,
              progress: stats.totalProducts == 10 && stats.totalProducts != 0
                  ? 1
                  : stats.totalProducts > 0
                      ? (stats.totalProducts * 0.1)
                      : 0.0,
            ),
          ),
          const Gap(12),
          Expanded(
            child: _StatCard(
              value: stats.totalViews.toString(),
              label: 'Views'.tr,
              progress: stats.totalViews > 0 ? 0.8 : 0.0,
            ),
          ),
          const Gap(12),
          Expanded(
            child: _StatCard(
              value: stats.totalReviews.toString(),
              label: 'Favorites'.tr,
              progress: stats.totalReviews > 0 ? 0.4 : 0.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Activity'.tr,
                style: AppFont.font18W700Black,
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'See More'.tr,
                  style: AppFont.font14W600Black.copyWith(
                    color: AppColor.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Gap(12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              _ActivityItem(
                icon: Icons.check_circle_outline,
                title: "Your ad 'Hyundai Car' was approved 4h".tr,
                iconColor: AppColor.green,
              ),
              const Gap(12),
              _ActivityItem(
                icon: Icons.notifications_outlined,
                title: 'New order received 24h'.tr,
                iconColor: AppColor.primary,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class TopViewsAds extends ConsumerWidget {
  const TopViewsAds({super.key});

  static const _topViewsFilter = MyProductsFilter(status: 'approved', limit: 3);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(fetchMyProductsProvider(_topViewsFilter));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Top views Ads'.tr,
                style: AppFont.font18W700Black,
              ),
              TextButton(
                onPressed: () {
                  ref.watch(rootIndex.notifier).setSelectedIndex(1);
                },
                child: Text(
                  'See More'.tr,
                  style: AppFont.font14W600Black.copyWith(
                    color: AppColor.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Gap(12),
        productsAsync.when(
          data: (products) {
            if (products.data.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'No ads yet'.tr,
                  style: AppFont.font14W500Black,
                ),
              );
            }
            return SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: products.data.length,
                itemBuilder: (context, index) {
                  final product = products.data[index];
                  return Container(
                    width: MediaQuery.of(context).size.width * 0.85,
                    margin: const EdgeInsets.only(right: 12),
                    child: _MyAdTile(product: product),
                  );
                },
              ),
            );
          },
          loading: () => SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 3,
              itemBuilder: (context, index) => Container(
                width: MediaQuery.of(context).size.width * 0.85,
                margin: const EdgeInsets.only(right: 12),
                child: ShimmerEffect(
                  enable: true,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
          ),
          error: (_, __) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text('Error loading ads'.tr),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final double progress;

  const _StatCard({
    required this.value,
    required this.label,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 6,
                    backgroundColor: AppColor.grey1,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColor.primary),
                  ),
                ),
                Text(
                  value,
                  style: AppFont.font18W700Black,
                ),
              ],
            ),
          ),
          const Gap(8),
          Text(
            label,
            style: AppFont.font12w400Black,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _MyAdTile extends StatelessWidget {
  final ProductModel product;

  const _MyAdTile({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.grey1),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: ImageOrSvg(
              product.thumbImage ??
                  (product.images.isNotEmpty ? product.images.first : ''),
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: AppFont.font14W600Black,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const Gap(4),
                Text(
                  '${product.price ?? 0}${AppString.currency}',
                  style: AppFont.font16W700Black.copyWith(
                    color: AppColor.primary,
                  ),
                ),
                const Gap(4),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 12, color: AppColor.grey2),
                    const Gap(4),
                    Text(
                      _formatDate(product.createdAt),
                      style: AppFont.font12w400Black.copyWith(
                        color: AppColor.grey2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getStatusColor(product.status).withAlpha(50),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              product.status.toUpperCase(),
              style: AppFont.font10w400Black.copyWith(
                color: _getStatusColor(product.status),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
      case 'active':
        return AppColor.green;
      case 'pending':
        return Colors.orange;
      case 'expired':
        return AppColor.grey2;
      default:
        return AppColor.grey2;
    }
  }

  String _formatDate(String date) {
    try {
      final parsed = DateTime.parse(date);
      final now = DateTime.now();
      final difference = now.difference(parsed);

      if (difference.inDays > 0) {
        return '${difference.inDays} ${difference.inDays == 1 ? 'day'.tr : 'days'.tr} ago'.tr;
      } else if (difference.inHours > 0) {
        return '${difference.inHours} ${difference.inHours == 1 ? 'hour'.tr : 'hours'.tr} ago'.tr;
      } else {
        return 'Just now'.tr;
      }
    } catch (e) {
      return date;
    }
  }
}

class _ActivityItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color iconColor;

  const _ActivityItem({
    required this.icon,
    required this.title,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withAlpha(30),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const Gap(12),
        Expanded(
          child: Text(
            title,
            style: AppFont.font14W500Black,
          ),
        ),
      ],
    );
  }
}
