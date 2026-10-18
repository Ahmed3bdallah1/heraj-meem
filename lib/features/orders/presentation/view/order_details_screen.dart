import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj/config/app_font.dart';
import 'package:heraj/core/service/loading_provider.dart';
import 'package:heraj/features/orders/data/models/order_model.dart';
import 'package:heraj/features/orders/domain/use_case/cancel_order_use_case.dart';
import 'package:heraj/features/orders/presentation/manager/fetch_orders_provider.dart';
import 'package:heraj/features/orders/presentation/view/widgets/cancel_order_bottom_sheet.dart';
import 'package:heraj/features/products/presentation/view/product_details_screen.dart';
import 'package:heraj/main.dart';
import 'package:heraj/ui/shared_widgets/image_or_svg.dart';
import 'package:heraj/ui/shared_widgets/price_widget.dart';
import 'package:heraj/ui/ui.dart';
import 'package:heraj/features/categories/presentation/view/widgets/all_categories/animated_background.dart';

class OrderDetailsScreen extends ConsumerStatefulWidget {
  final OrderModel order;

  const OrderDetailsScreen({super.key, required this.order});

  @override
  ConsumerState<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends ConsumerState<OrderDetailsScreen>
    with TickerProviderStateMixin {
  late AnimationController _backgroundAnimationController;
  late OrderModel _currentOrder;

  @override
  void initState() {
    super.initState();
    _currentOrder = widget.order;
    _backgroundAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 25),
    )..repeat();
  }

  @override
  void dispose() {
    _backgroundAnimationController.dispose();
    super.dispose();
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
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

  Color _getPaymentStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'paid':
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
      case 'cancelled':
        return Colors.red;
      default:
        return AppColor.grey2;
    }
  }

  bool get _canCancelOrder {
    final status = _currentOrder.status?.toLowerCase();
    return status != null && 
           status != 'delivered' && 
           status != 'cancelled';
  }

  Future<void> _cancelOrder() async {
    try {
      ref.read(isLoadingProvider("cancelOrder${_currentOrder.id}").notifier).state = true;

      final result = await getIt<CancelOrderUseCase>().call(_currentOrder.id);
      
      result.fold(
        (failure) {
          UIHelper.showAlert(
            failure.message,
            type: DialogType.error,
          );
        },
        (response) {
          final message = response['message']?.toString() ?? 'Order cancelled successfully';
          ref.invalidate(fetchOrdersProvider);
          setState(() {
            _currentOrder = OrderModel(
              id: _currentOrder.id,
              orderNumber: _currentOrder.orderNumber,
              customerId: _currentOrder.customerId,
              status: 'cancelled',
              totalPrice: _currentOrder.totalPrice,
              paymentStatus: _currentOrder.paymentStatus,
              paymentMethod: _currentOrder.paymentMethod,
              createdAt: _currentOrder.createdAt,
              updatedAt: _currentOrder.updatedAt,
              items: _currentOrder.items,
              deliveryAddress: _currentOrder.deliveryAddress,
              userId: _currentOrder.userId,
              total: _currentOrder.total,
              discount: _currentOrder.discount,
              shippingCost: _currentOrder.shippingCost,
              couponId: _currentOrder.couponId,
              couponDiscountValue: _currentOrder.couponDiscountValue,
              finalTotal: _currentOrder.finalTotal,
              shippingAddressId: _currentOrder.shippingAddressId,
              billingAddressId: _currentOrder.billingAddressId,
              shippingAddress: _currentOrder.shippingAddress,
              billingAddress: _currentOrder.billingAddress,
              prespictions: _currentOrder.prespictions,
              coupon: _currentOrder.coupon,
            );
          });

          UIHelper.showAlert(
            message,
            type: DialogType.success,
          );
        },
      );
    } catch (e) {
      UIHelper.showAlert(
        'An error occurred while cancelling the order',
        type: DialogType.error,
      );
    } finally {
      if (mounted) {
        ref.read(isLoadingProvider("cancelOrder${_currentOrder.id}").notifier).state = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalItems = _currentOrder.items.fold<int>(
      0,
      (sum, item) => sum + (item.quantity ?? 0),
    );
    final isLoading = ref.watch(isLoadingProvider("cancelOrder${_currentOrder.id}"));


    return Scaffold(
      body: Stack(
        children: [
          AnimatedBackground(
            animation: _backgroundAnimationController,
          ),
          CustomScrollView(
            slivers: [
              // AppBar
              SliverAppBar(
                expandedHeight: 100,
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
                  titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
                  title: Text(
                    "Order Details".tr,
                    style: AppFont.font20W700Black,
                  ),
                  centerTitle: false,
                ),
              ),
              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedOrderCard(
                        index: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColor.white,
                                AppColor.primary2.withAlpha(77),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppColor.primary.withAlpha(26),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                                spreadRadius: 0,
                              ),
                              BoxShadow(
                                color: Colors.black.withAlpha(13),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                            border: Border.all(
                              color: AppColor.primary.withAlpha(51),
                              width: 1.5,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
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
                                            _currentOrder.orderNumber ?? 'Order #${_currentOrder.id}',
                                            style: AppFont.font18W700Black,
                                          ),
                                          const Gap(4),
                                          Text(
                                            _formatDate(_currentOrder.createdAt),
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
                                        color: _getStatusColor(_currentOrder.status).withAlpha(26),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: _getStatusColor(_currentOrder.status),
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Text(
                                        _currentOrder.status?.toUpperCase() ?? 'PENDING',
                                        style: AppFont.font12w400Black.copyWith(
                                          color: _getStatusColor(_currentOrder.status),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const Gap(16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _InfoItem(
                                        label: "Payment Method".tr,
                                        value: _currentOrder.paymentMethod?.toUpperCase() ?? 'CASH',
                                      ),
                                    ),
                                    Expanded(
                                      child: _InfoItem(
                                        label: "Payment Status".tr,
                                        value: _currentOrder.paymentStatus?.toUpperCase() ?? 'PENDING',
                                        valueColor: _getPaymentStatusColor(_currentOrder.paymentStatus),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const Gap(16),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColor.primary.withAlpha(38),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.shopping_bag_rounded,
                              color: AppColor.primary,
                              size: 20,
                            ),
                          ),
                          const Gap(12),
                          Text(
                            "Order Items".tr,
                            style: AppFont.font20W700Black,
                          ),
                        ],
                      ),
                      const Gap(16),
                      ..._currentOrder.items.asMap().entries.map((entry) {
                        return AnimatedOrderCard(
                          key: ValueKey('order_item_${entry.value.id}_${entry.key}'),
                          index: entry.key + 1,
                          child: _OrderItemCard(item: entry.value),
                        );
                      }),
                      const Gap(16),
                      AnimatedOrderCard(
                        index: _currentOrder.items.length + 1,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColor.white,
                                AppColor.primary2.withAlpha(77),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppColor.primary.withAlpha(26),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                            border: Border.all(
                              color: AppColor.primary.withAlpha(51),
                              width: 1.5,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: AppColor.primary.withAlpha(38),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(
                                        Icons.receipt_long_rounded,
                                        color: AppColor.primary,
                                        size: 20,
                                      ),
                                    ),
                                    const Gap(12),
                                    Text(
                                      "Order Summary".tr,
                                      style: AppFont.font20W700Black,
                                    ),
                                  ],
                                ),
                                const Gap(16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Total Items".tr,
                                      style: AppFont.font14W600Black,
                                    ),
                                    Text(
                                      '$totalItems',
                                      style: AppFont.font14W600Black,
                                    ),
                                  ],
                                ),
                                const Gap(16),
                                Container(
                                  height: 1,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.transparent,
                                        AppColor.primary.withAlpha(77),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                ),
                                const Gap(16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Total Amount".tr,
                                      style: AppFont.font18W700Black,
                                    ),
                                    PriceWidget(
                                      price: _currentOrder.totalPrice?.toStringAsFixed(2) ?? 
                                          (_currentOrder.total != null 
                                              ? (double.tryParse(_currentOrder.total!)?.toStringAsFixed(2) ?? _currentOrder.total!)
                                              : '0.00'),
                                      style: AppFont.font20W700Black,
                                      textColor: AppColor.primary,
                                      currencySize: 20,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (_canCancelOrder) ...[
                        const Gap(16),
                        AnimatedOrderCard(
                          index: _currentOrder.items.length + 2,
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppColor.white,
                                  AppColor.primary2.withAlpha(77),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColor.primary.withAlpha(26),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                              border: Border.all(
                                color: AppColor.primary.withAlpha(51),
                                width: 1.5,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: ElevatedButton(
                                onPressed: isLoading
                                    ? null
                                    : () {
                                        CancelOrderBottomSheet.show(
                                          context,
                                          orderNumber: _currentOrder.orderNumber ??
                                              'Order #${_currentOrder.id}',
                                          onConfirm: _cancelOrder,
                                        );
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColor.danger,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                                child: isLoading
                                    ? SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      )
                                    : Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.cancel_outlined, size: 20),
                                          const Gap(8),
                                          Text(
                                            "Cancel Order".tr,
                                            style: AppFont.font16W600NearlyWhite,
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ],
                      Gap(MediaQuery.of(context).padding.bottom + 16),
                    ],
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

class AnimatedOrderCard extends StatefulWidget {
  final Widget child;
  final int index;

  const AnimatedOrderCard({
    super.key,
    required this.child,
    required this.index,
  });

  @override
  State<AnimatedOrderCard> createState() => _AnimatedOrderCardState();
}

class _AnimatedOrderCardState extends State<AnimatedOrderCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 600 + (widget.index * 100)),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 1.0, curve: Curves.elasticOut),
      ),
    );

    // Start animation after a small delay based on index
    Future.delayed(Duration(milliseconds: widget.index * 80), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.translate(
            offset: Offset(0, _slideAnimation.value),
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: widget.child,
            ),
          ),
        );
      },
    );
  }
}

class _OrderItemCard extends StatelessWidget {
  final OrderItemModel item;

  const _OrderItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final productTitle = item.title ??
        item.productInfo?.title ??
        item.product?.name ??
        'Product';
    final productImage = item.productInfo?.images.isNotEmpty == true
        ? item.productInfo!.images.first
        : (item.product?.thumbImage ?? '');
    final productId = item.productId ??
        item.productInfo?.id ??
        item.product?.id ??
        '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColor.white,
            AppColor.primary2.withAlpha(38),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColor.primary.withAlpha(26),
            blurRadius: 10,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
        border: Border.all(
          color: AppColor.primary.withAlpha(38),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: productId.isNotEmpty
              ? () {
                  Get.to(() => ProductDetailsScreen(productId: productId,isReviewEnabled: true,));
                }
              : null,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColor.primary.withAlpha(51),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: ImageOrSvg(
                      productImage,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const Gap(16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        productTitle,
                        style: AppFont.font15W700Black,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Gap(8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColor.primary.withAlpha(38),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "Quantity".tr + ': ${item.quantity ?? 0}',
                          style: AppFont.font12w400Black.copyWith(
                            color: AppColor.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Gap(12),
                      PriceWidget(
                        price: item.price?.toStringAsFixed(2) ?? '0.00',
                        style: AppFont.font14W600Green,
                        textColor: AppColor.green,
                        currencySize: 16,
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
}

class _InfoItem extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoItem({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppFont.font12w400Black.copyWith(
            color: AppColor.grey2,
          ),
        ),
        const Gap(4),
        Text(
          value,
          style: AppFont.font14W600Black.copyWith(
            color: valueColor ?? AppColor.black,
          ),
        ),
      ],
    );
  }
}

