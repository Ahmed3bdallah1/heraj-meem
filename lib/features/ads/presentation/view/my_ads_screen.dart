import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj_meem/config/app_font.dart';
import 'package:heraj_meem/features/ads/data/models/product_model.dart';
import 'package:heraj_meem/features/ads/presentation/managers/products_managers.dart';
import 'package:heraj_meem/features/ads/presentation/view/ad_details_screen.dart';
import 'package:heraj_meem/helper/riverpod.dart';
import 'package:heraj_meem/ui/shared_widgets/image_or_svg.dart';
import 'package:heraj_meem/ui/shared_widgets/shimmer_effect.dart';

class MyAdsScreen extends ConsumerStatefulWidget {
  const MyAdsScreen({super.key});

  @override
  ConsumerState<MyAdsScreen> createState() => _MyAdsScreenState();
}

class _MyAdsScreenState extends ConsumerState<MyAdsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  final ValueNotifier<String> _query = ValueNotifier('');

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ads = ref.watch(fetchMyAdsProvider);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text('My Ads'.tr, style: AppFont.font18W700Black),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(fetchMyAdsProvider);
          await ref.read(fetchMyAdsProvider.future);
        },
        child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocus,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _searchFocus.unfocus(),
                decoration: InputDecoration(
                  hintText: 'Search'.tr,
                  hintStyle: AppFont.font14W500Black.copyWith(
                    color: AppColor.grey2,
                  ),
                  prefixIcon: Icon(Icons.search, color: AppColor.grey2),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColor.grey1),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColor.grey1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColor.primary),
                  ),
                ),
                style: AppFont.font14W500Black,
                onChanged: (value) => _query.value = value.trim().toLowerCase(),
              ),
            ),
          ),
          ads.customWhen(
            ref: ref,
            refreshable: fetchMyAdsProvider.future,
            skipLoadingOnRefresh: true,
            loading: () => SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: ShimmerEffect(
                    enable: true,
                    child: Container(
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                childCount: 5,
              ),
            ),
            error: (_, __) => SliverFillRemaining(
              child: Center(child: Text('Error loading ads'.tr)),
            ),
            data: (items) => ValueListenableBuilder<String>(
              valueListenable: _query,
              builder: (context, query, _) {
                final shown = query.isEmpty
                    ? items
                    : items
                        .where((ad) =>
                            ad.name.toLowerCase().contains(query) ||
                            (ad.titleAr ?? '').toLowerCase().contains(query))
                        .toList();
                if (shown.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.inbox_outlined,
                                size: 64, color: AppColor.grey2),
                            const Gap(16),
                            Text('No ads found'.tr, style: AppFont.font16W600Black),
                          ],
                        ),
                      ),
                    ),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _AdCard(product: shown[index]),
                      childCount: shown.length,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
        ),
      ),
    );
  }
}

class _AdCard extends StatelessWidget {
  const _AdCard({required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final status = _statusLabel(product.status);
    final statusColor = _statusColor(product.status);
    final image = product.thumbImage ??
        (product.images.isNotEmpty ? product.images.first : '');
    final price = product.hasListedPrice
        ? '${product.afterPrice} ${'SAR'.tr}'
        : 'Contact the publisher'.tr;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: AppColor.grey1),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => Get.to(
            () => AdDetailsScreen(productId: product.id, mine: true),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: ImageOrSvg(
                    image,
                    width: 100,
                    height: 100,
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
                        style: AppFont.font16W600Black,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Gap(8),
                      Text(
                        price,
                        style: AppFont.font16W700Black.copyWith(
                          color: AppColor.primary,
                        ),
                      ),
                      const Gap(8),
                      Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withAlpha(38),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            status,
                            style: AppFont.font12W600Primary.copyWith(
                              color: statusColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _statusLabel(String status) {
    switch (status.toUpperCase()) {
      case 'ACTIVE':
      case 'APPROVED':
        return 'Active'.tr;
      case 'PENDING':
      case 'PENDING_REVIEW':
        return 'Pending Review'.tr;
      case 'EXPIRED':
        return 'Expired'.tr;
      default:
        return status;
    }
  }

  Color _statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'ACTIVE':
      case 'APPROVED':
        return AppColor.primary;
      case 'PENDING':
      case 'PENDING_REVIEW':
        return const Color(0xffE39B00);
      default:
        return AppColor.grey2;
    }
  }
}
