import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj/config/app_color.dart';
import 'package:heraj/config/app_font.dart';
import 'package:heraj/features/products/data/models/product_model.dart';
import 'package:heraj/features/products/presentation/view/product_details_screen.dart';
import 'package:heraj/features/products/presentation/view/update_product_screen.dart';
import 'package:heraj/features/vendor/presentation/managers/vendor_provider.dart';
import 'package:heraj/ui/shared_widgets/image_or_svg.dart';
import 'package:heraj/ui/shared_widgets/shimmer_effect.dart';
import '../../../../config/app_string.dart';
import '../../../../helper/riverpod.dart';
import '../../../products/presentation/view/add_product_screen.dart';

final myAdsTabIndexProvider = StateProvider.autoDispose<int>((ref) => 0);

class MyAdsScreen extends ConsumerStatefulWidget {
  const MyAdsScreen({super.key});

  @override
  ConsumerState<MyAdsScreen> createState() => _MyAdsScreenState();
}

class _MyAdsScreenState extends ConsumerState<MyAdsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _updateFilter(int index) {
    final filterNotifier = ref.read(myProductsFilterProvider.notifier);
    switch (index) {
      case 0:
        filterNotifier.setStatus('approved');
        break;
      case 1:
        filterNotifier.setStatus('pending');
        break;
      case 2:
        filterNotifier.setStatus('expired');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tabIndex = ref.watch(myAdsTabIndexProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'My Ads'.tr,
          style: AppFont.font18W700Black,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: _TabButton(
                        label: 'Active'.tr,
                        isSelected: tabIndex == 0,
                        onTap: () {
                          ref.read(myAdsTabIndexProvider.notifier).state = 0;
                          _updateFilter(0);
                        },
                      ),
                    ),
                    const Gap(8),
                    Expanded(
                      child: _TabButton(
                        label: 'Pending Review'.tr,
                        isSelected: tabIndex == 1,
                        onTap: () {
                          ref.read(myAdsTabIndexProvider.notifier).state = 1;
                          _updateFilter(1);
                        },
                      ),
                    ),
                    const Gap(8),
                    Expanded(
                      child: _TabButton(
                        label: 'Expired'.tr,
                        isSelected: tabIndex == 2,
                        onTap: () {
                          ref.read(myAdsTabIndexProvider.notifier).state = 2;
                          _updateFilter(2);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search'.tr,
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
                        onChanged: (value) {
                          ref
                              .read(myProductsFilterProvider.notifier)
                              .setSearch(value);
                        },
                      ),
                    ),
                    // const Gap(12),
                    // Container(
                    //   width: 48,
                    //   height: 48,
                    //   decoration: BoxDecoration(
                    //     color: AppColor.primary,
                    //     borderRadius: BorderRadius.circular(12),
                    //   ),
                    //   child: IconButton(
                    //     icon: Icon(Icons.tune, color: Colors.white),
                    //     onPressed: () {
                    //       // Show filter dialog
                    //     },
                    //   ),
                    // ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: IndexedStack(
              index: tabIndex,
              children: [
                _AdsList(status: 'approved'),
                _AdsList(status: 'pending'),
                _AdsList(status: 'expired'),
              ],
            ),
          ),
          PositionedDirectional(
            bottom: MediaQuery.of(context).padding.bottom + 60,
            end: 16,
            child: FloatingActionButton(
              onPressed: () {
                Get.to(() => const AddProductScreen());
              },
              backgroundColor: AppColor.primary,
              child: Icon(Icons.add, color: Colors.white),
            ),
          )
        ],
      ),
    );
  }
}

class _AdsList extends ConsumerWidget {
  final String status;

  const _AdsList({required this.status});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(myProductsFilterProvider);
    final filterWithStatus = filter.copyWith(status: status);
    final productsAsync = ref.watch(fetchMyProductsProvider(filterWithStatus));

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(fetchMyProductsProvider);
      },
      child: productsAsync.customWhen(
        ref: ref,
        refreshable: fetchMyProductsProvider(filterWithStatus).future,
        data: (products) {
          if (products.data.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inbox_outlined, size: 64, color: AppColor.grey2),
                    const Gap(16),
                    Text(
                      'No ads found'.tr,
                      style: AppFont.font16W600Black,
                    ),
                    const Gap(8),
                    Text(
                      'Create your first ad'.tr,
                      style: AppFont.font14W500Black.copyWith(
                        color: AppColor.grey2,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: products.data.length,
            itemBuilder: (context, index) {
              final product = products.data[index];
              return _AdCard(product: product);
            },
          );
        },
        loading: () => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: 5,
          itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
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
        ),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Text('Error loading ads'.tr),
          ),
        ),
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
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColor.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: AppFont.font14W600Black.copyWith(
            color: isSelected ? Colors.white : AppColor.primary,
          ),
        ),
      ),
    );
  }
}

class _AdCard extends StatelessWidget {
  final ProductModel product;

  const _AdCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final status = _getStatusText(product.status);
    final statusColor = _getStatusColor(product.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.grey1),
      ),
      child: InkWell(
        onTap: () {
          Get.to(() => ProductDetailsScreen(productId: product.id));
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: ImageOrSvg(
                  product.thumbImage ??
                      (product.images.isNotEmpty ? product.images.first : ''),
                  width: 100.w,
                  height: 100.w,
                  fit: BoxFit.fill,
                ),
              ),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            product.name,
                            style: AppFont.font16W600Black,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Gap(8),
                        IconButton(
                          icon: Icon(Icons.edit_outlined,
                              size: 20, color: Colors.black),
                          onPressed: () {
                            Get.to(() => UpdateProductScreen(
                                  product: product,
                                ));
                          },
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    const Gap(8),
                    // Price
                    Text(
                      '${product.price ?? 0}${AppString.currency}',
                      style: AppFont.font18W700Black.copyWith(
                        color: AppColor.primary,
                      ),
                    ),
                    const Gap(8),
                    // Date
                    Row(
                      children: [
                        Icon(Icons.calendar_today,
                            size: 14, color: AppColor.grey2),
                        const Gap(4),
                        Text(
                          _formatDate(product.createdAt),
                          style: AppFont.font12w400Black.copyWith(
                            color: AppColor.grey2,
                          ),
                        ),
                      ],
                    ),
                    const Gap(8),
                    // Status Button
                    Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          status,
                          style: AppFont.font12w400Black.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.w600,
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
    );
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return 'Active'.tr;
      case 'pending':
        return 'Pending Review'.tr;
      case 'expired':
        return 'Expired'.tr;
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return AppColor.primary;
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
