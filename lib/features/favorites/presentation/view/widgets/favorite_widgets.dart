import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj_meem/features/ads/data/models/product_model.dart';
import '../../../../../config/app_font.dart';
import '../../../../../main.dart';
import '../../../../../ui/shared_widgets/image_or_svg.dart';
import '../../../../../ui/shared_widgets/price_widget.dart';
import '../../../../../ui/ui.dart';
import '../../../../ads/presentation/view/ad_details_screen.dart';
import '../../../domain/use_case/favorites_use_case.dart';
import '../../managers/favorites.dart';

class FavoriteWidget extends ConsumerStatefulWidget {
  final ProductModel favoritesModel;

  const FavoriteWidget({
    super.key,
    required this.favoritesModel,
  });

  @override
  ConsumerState<FavoriteWidget> createState() => _FavoriteWidgetState();
}

class _FavoriteWidgetState extends ConsumerState<FavoriteWidget>
    with SingleTickerProviderStateMixin {
  final ValueNotifier<bool> _hoverNotifier = ValueNotifier(false);
  late AnimationController _heartController;
  late Animation<double> _heartScaleAnimation;
  late Animation<double> _heartRotationAnimation;

  @override
  void initState() {
    super.initState();

    _heartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _heartScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(
      CurvedAnimation(
        parent: _heartController,
        curve: Curves.elasticOut,
      ),
    );

    _heartRotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.2,
    ).animate(
      CurvedAnimation(
        parent: _heartController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _heartController.dispose();
    _hoverNotifier.dispose();
    super.dispose();
  }

  void _handleHeartTap() async {
    _heartController.forward().then((_) {
      _heartController.reverse();
    });
    await _removeItem();
  }

  Future<void> _removeItem() async {
    final res = await getIt<RemoveFavoriteUseCase>().call(
      widget.favoritesModel.id.toString(),
    );
    res.fold(
      (l) => UIHelper.showGlobalSnackBar(
        text: l.message,
        color: AppColor.danger,
      ),
      (r) {
        UIHelper.showGlobalSnackBar(
          text: "Product Removed from favorites successfully".tr,
          color: AppColor.green,
        );
        ref.invalidate(favoritesProvider);
        ref.invalidate(
          isFavoritedProduct(widget.favoritesModel.id.toString()),
        );
      },
    );
  }

  String _getPrice() {
    if (widget.favoritesModel.price != null) {
      return widget.favoritesModel.price!.toStringAsFixed(2);
    }
    if (widget.favoritesModel.afterPrice != null) {
      return widget.favoritesModel.afterPrice!;
    }
    return 'N/A';
  }

  String? _getComparePrice() {
    if (widget.favoritesModel.compareAtPrice != null &&
        widget.favoritesModel.price != null &&
        widget.favoritesModel.compareAtPrice! > widget.favoritesModel.price!) {
      return widget.favoritesModel.compareAtPrice!.toStringAsFixed(2);
    }

    if (widget.favoritesModel.beforePrice != null &&
        widget.favoritesModel.afterPrice != null) {
      return widget.favoritesModel.beforePrice;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final comparePrice = _getComparePrice();

    return GestureDetector(
        onTap: () => Get.to(
          () => AdDetailsScreen(
            productId: widget.favoritesModel.id,
          ),
        ),
        onTapDown: (_) => _hoverNotifier.value = true,
        onTapUp: (_) => _hoverNotifier.value = false,
        onTapCancel: () => _hoverNotifier.value = false,
        child: ValueListenableBuilder<bool>(
          valueListenable: _hoverNotifier,
          builder: (context, isHovered, child) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              transform: Matrix4.identity()..scale(isHovered ? 0.98 : 1.0),
              child: child,
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
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
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Image
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColor.primary.withAlpha(51),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Stack(
                        children: [
                          ImageOrSvg(
                            widget.favoritesModel.thumbImage,
                            height: 100,
                            width: 100,
                            fit: BoxFit.cover,
                          ),
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withAlpha(26),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Gap(16),

                  // Product Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.favoritesModel.name,
                          style: AppFont.font16W700Black,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Gap(8),
                        if (widget.favoritesModel.category?.name != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColor.primary.withAlpha(38),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColor.primary.withAlpha(77),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.category_rounded,
                                  size: 12,
                                  color: AppColor.primary,
                                ),
                                const Gap(4),
                                Text(
                                  widget.favoritesModel.category!.name,
                                  style: AppFont.font12W600Primary.copyWith(
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const Gap(12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (widget.favoritesModel.hasListedPrice)
                              PriceWidget(
                                price: _getPrice(),
                                style: AppFont.font18W700Black.copyWith(
                                  fontSize: 16,
                                ),
                                textColor: AppColor.primary,
                                currencySize: 16,
                              )
                            else
                              Text(
                                'Contact the publisher'.tr,
                                style: AppFont.font14W600Primary,
                              ),
                            if (comparePrice != null) ...[
                              const Gap(8),
                              PriceWidget(
                                price: comparePrice,
                                style: AppFont.font14W600Black,
                                textColor: AppColor.grey2,
                                decoration: TextDecoration.lineThrough,
                                currencySize: 12,
                              ),
                            ],
                          ],
                        ),
                        if (widget.favoritesModel.averageRating != null) ...[
                          const Gap(8),
                          Row(
                            children: [
                              Icon(
                                Icons.star_rounded,
                                size: 14,
                                color: AppColor.orange,
                              ),
                              const Gap(4),
                              Text(
                                widget.favoritesModel.averageRating!,
                                style: AppFont.font12w400Black.copyWith(
                                  color: AppColor.grey2,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Heart Button
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: AnimatedBuilder(
                      animation: _heartController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _heartScaleAnimation.value,
                          child: Transform.rotate(
                            angle: _heartRotationAnimation.value,
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: _handleHeartTap,
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        AppColor.danger.withAlpha(38),
                                        AppColor.danger.withAlpha(64),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppColor.danger.withAlpha(77),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.favorite_rounded,
                                    color: AppColor.danger,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
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
