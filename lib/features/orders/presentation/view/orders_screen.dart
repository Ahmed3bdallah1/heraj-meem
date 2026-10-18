import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj_meem/config/app_font.dart';
import 'package:heraj_meem/features/orders/presentation/manager/fetch_orders_provider.dart';
import 'package:heraj_meem/features/orders/presentation/view/order_details_screen.dart';
import 'package:heraj_meem/helper/riverpod.dart';
import 'package:heraj_meem/ui/shared_widgets/image_or_svg.dart';
import 'package:heraj_meem/ui/shared_widgets/price_widget.dart';
import 'package:heraj_meem/features/categories/presentation/view/widgets/all_categories/animated_background.dart';
import '../../data/models/order_model.dart';

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen>
    with TickerProviderStateMixin {
  late AnimationController _backgroundAnimationController;
  final ScrollController _scrollController = ScrollController();
  bool _handledOpenOrderId = false;

  @override
  void initState() {
    super.initState();
    _backgroundAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 25),
    )..repeat();
  }

  @override
  void dispose() {
    _backgroundAnimationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          AnimatedBackground(
            animation: _backgroundAnimationController,
          ),
          CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // Animated AppBar
              SliverAppBar(
                expandedHeight: 120,
                floating: true,
                pinned: true,
                elevation: 0,
                backgroundColor: Colors.transparent,
                leading: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColor.white.withAlpha(230),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(10),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_back_rounded,
                      color: AppColor.black,
                    ),
                    onPressed: () => Get.back(),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
                  title: Text(
                    "Orders".tr,
                    style: AppFont.font18W700Black,
                  ),
                  centerTitle: true,
                ),
              ),
              // Content
              SliverToBoxAdapter(
                child: RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(fetchOrdersProvider);
                  },
                  child: Consumer(
                    builder: (context, ref, _) {
                      final provider = ref.watch(fetchOrdersProvider);
                      return provider.customWhen(
                        ref: ref,
                        refreshable: fetchOrdersProvider.future,
                        skipLoadingOnRefresh: true,
                        skipLoadingOnReload: true,
                        data: (orders) {
                          if (orders.isEmpty) {
                            return _EmptyOrdersState();
                          }
                          if (!_handledOpenOrderId &&
                              Get.arguments is Map<String, dynamic>) {
                            final openOrderId = (Get.arguments
                                    as Map<String, dynamic>)['openOrderId']
                                as String?;
                            if (openOrderId != null && openOrderId.isNotEmpty) {
                              OrderModel? order;
                              try {
                                order = orders
                                    .firstWhere((o) => o.id == openOrderId);
                              } catch (_) {
                                order = null;
                              }
                              if (order != null) {
                                _handledOpenOrderId = true;
                                WidgetsBinding.instance
                                    .addPostFrameCallback((_) {
                                  Get.to(
                                      () => OrderDetailsScreen(order: order!));
                                });
                              }
                            }
                          }
                          return Column(
                            children: [
                              const Gap(16),
                              ...orders.asMap().entries.expand((entry) {
                                return [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    child: OrderCard(order: entry.value),
                                  ),
                                  if (entry.key < orders.length - 1)
                                    const Gap(12),
                                ];
                              }),
                              Gap(MediaQuery.of(context).padding.bottom + 16),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  final OrderModel order;

  const OrderCard({super.key, required this.order});

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
      case 'processing':
        return Colors.blue;
      case 'shipped':
        return Colors.purple;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return AppColor.grey2;
    }
  }

  @override
  Widget build(BuildContext context) {
    final firstItem = order.items.isNotEmpty ? order.items.first : null;
    final itemCount = order.items.length;
    final totalItems = order.items.fold<int>(
      0,
      (sum, item) => sum + (item.quantity ?? 0),
    );

    return InkWell(
      onTap: () {
        Get.to(() => OrderDetailsScreen(order: order));
      },
      child: Card(
        color: AppColor.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.orderNumber ?? 'Order #${order.id}',
                          style: AppFont.font16W700Black,
                        ),
                        const Gap(4),
                        Text(
                          _formatDate(order.createdAt),
                          style: AppFont.font12w400Black.copyWith(
                            color: AppColor.grey2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(order.status).withAlpha(25),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _getStatusColor(order.status),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      order.status?.toUpperCase() ?? 'PENDING',
                      style: AppFont.font12w400Black.copyWith(
                        color: _getStatusColor(order.status),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const Gap(12),
              if (firstItem != null) ...[
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: ImageOrSvg(
                        firstItem.productInfo?.images.isNotEmpty == true
                            ? firstItem.productInfo!.images.first
                            : (firstItem.product?.thumbImage ?? ''),
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const Gap(12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            firstItem.title ??
                                firstItem.productInfo?.title ??
                                firstItem.product?.name ??
                                'Product',
                            style: AppFont.font14W600Black,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Gap(4),
                          Text(
                            itemCount > 1
                                ? '$itemCount items ($totalItems total)'.tr
                                : '${totalItems} item'.tr,
                            style: AppFont.font12w400Black.copyWith(
                              color: AppColor.grey2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Gap(12),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Total".tr,
                        style: AppFont.font12w400Black.copyWith(
                          color: AppColor.grey2,
                        ),
                      ),
                      const Gap(4),
                      PriceWidget(
                        price: order.totalPrice?.toStringAsFixed(2) ??
                            order.total ??
                            '0.00',
                        style: AppFont.font16W700Black,
                        textColor: AppColor.primary,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.payment,
                        size: 16,
                        color: AppColor.grey2,
                      ),
                      const Gap(4),
                      Text(
                        order.paymentMethod?.toUpperCase() ?? 'CASH',
                        style: AppFont.font12w400Black.copyWith(
                          color: AppColor.grey2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyOrdersState extends StatefulWidget {
  const _EmptyOrdersState();

  @override
  State<_EmptyOrdersState> createState() => _EmptyOrdersStateState();
}

class _EmptyOrdersStateState extends State<_EmptyOrdersState>
    with TickerProviderStateMixin {
  late AnimationController _iconController;
  late AnimationController _pulseController;
  late Animation<double> _iconAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _iconController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _iconAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(
        parent: _iconController,
        curve: Curves.easeInOut,
      ),
    );

    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeOut,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeIn),
      ),
    );
  }

  @override
  void dispose() {
    _iconController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.6,
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Container(
                    width: 120 + (_pulseAnimation.value * 40),
                    height: 120 + (_pulseAnimation.value * 40),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColor.primary.withOpacity(
                        0.1 * (1 - _pulseAnimation.value),
                      ),
                    ),
                  );
                },
              ),
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Container(
                    width: 100 + (_pulseAnimation.value * 30),
                    height: 100 + (_pulseAnimation.value * 30),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColor.primary.withOpacity(
                        0.15 * (1 - _pulseAnimation.value),
                      ),
                    ),
                  );
                },
              ),
              AnimatedBuilder(
                animation: _iconAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _iconAnimation.value,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColor.primary.withAlpha(50),
                            AppColor.primary.withAlpha(25),
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.shopping_bag_rounded,
                        size: 64,
                        color: AppColor.primary,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          const Gap(32),
          // Title with fade animation
          FadeTransition(
            opacity: _fadeAnimation,
            child: Text(
              "No Orders Yet".tr,
              style: AppFont.font20W700Black,
              textAlign: TextAlign.center,
            ),
          ),
          const Gap(12),
          // Message with fade animation
          FadeTransition(
            opacity: _fadeAnimation,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                "You haven't placed any orders yet.".tr,
                style: AppFont.font14W500Black.copyWith(
                  color: AppColor.grey2,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const Gap(32),
          // Button without animation
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColor.primary,
                    AppColor.primaryDark,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColor.primary.withAlpha(100),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => Get.back(),
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.shopping_bag_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        const Gap(12),
                        Text(
                          "Go to Products".tr,
                          style: AppFont.font16W600Black.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
