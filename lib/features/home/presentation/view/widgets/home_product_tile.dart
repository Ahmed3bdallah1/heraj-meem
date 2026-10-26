import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj_meem/config/app_font.dart';
import 'package:heraj_meem/core/service/localization_service/localization_service.dart';
import 'package:heraj_meem/features/favorites/presentation/managers/favorites.dart';
import 'package:heraj_meem/features/favorites/presentation/view/widgets/favorite_button.dart';
import 'package:heraj_meem/features/ads/presentation/view/ad_details_screen.dart';
import 'package:heraj_meem/main.dart';
import 'package:heraj_meem/ui/shared_widgets/image_or_svg.dart';
import 'package:heraj_meem/ui/shared_widgets/price_widget.dart';
import '../../../../ads/data/models/product_model.dart';

enum ProductStatus {
  sellingFast,
  bestSeller,
  almostGone,
  none,
}

class HomeProductTile extends ConsumerStatefulWidget {
  final ProductModel product;
  final ProductStatus status;

  const HomeProductTile({
    super.key,
    required this.product,
    this.status = ProductStatus.none,
  });

  @override
  ConsumerState<HomeProductTile> createState() => _HomeProductTileState();
}

class _HomeProductTileState extends ConsumerState<HomeProductTile> {
  bool get _hasOffer {
    if (widget.product.beforePrice == null ||
        widget.product.afterPrice == null) {
      return false;
    }
    final before = double.tryParse(widget.product.beforePrice.toString()) ?? 0;
    final after = double.tryParse(widget.product.afterPrice.toString()) ?? 0;
    return before > 0 && after > 0 && before > after;
  }

  double get _discountPercentage {
    if (!_hasOffer) return 0;
    final before = double.tryParse(widget.product.beforePrice.toString()) ?? 0;
    final after = double.tryParse(widget.product.afterPrice.toString()) ?? 0;
    if (before == 0) return 0;
    return ((before - after) / before) * 100;
  }

  String _formatViews(int views) {
    if (views >= 1000) {
      return '${(views / 1000).toStringAsFixed(1)}K';
    }
    return views.toString();
  }

  String _getStatusText() {
    switch (widget.status) {
      case ProductStatus.sellingFast:
        return 'Selling Fast!'.tr;
      case ProductStatus.bestSeller:
        return 'Best Seller #1'.tr;
      case ProductStatus.almostGone:
        return 'Almost Gone!'.tr;
      case ProductStatus.none:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final langCode = getIt<LocaleService>().getLocale().locale.languageCode;
    final productName = langCode == "en"
        ? widget.product.name
        : langCode == "ar"
            ? widget.product.titleAr ?? ""
            : widget.product.titleTr ?? "";

    return Container(
      width: 160,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => Get.to(
          () => AdDetailsScreen(productId: widget.product.id),
          preventDuplicates: false,
        ),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: SizedBox(
                    height: 160,
                    width: double.infinity,
                    child: widget.product.thumbImage != null &&
                            widget.product.thumbImage!.isNotEmpty
                        ? ImageOrSvg(
                            widget.product.thumbImage,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            color: AppColor.grey1,
                            child: const Icon(Icons.image, size: 48),
                          ),
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                            colors: [AppColor.primary, Colors.yellow]),
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          AppColor.defaultPrimaryShadow,
                        ]),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.verified,
                          size: 12,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Official'.tr,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                PositionedDirectional(
                  top: 8,
                  end: 8,
                  child: FavoriteButton(
                      product: widget.product,
                      ref: ref,
                      isFavorited:
                          ref.watch(isFavoritedProduct(widget.product.id))),
                ),
                if (widget.status != ProductStatus.none)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                              colors: [AppColor.primary, Colors.yellow]),
                          boxShadow: [
                            AppColor.defaultPrimaryShadow,
                          ]),
                      child: Text(
                        _getStatusText(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    productName,
                    style: AppFont.font14W700Black.copyWith(
                      fontSize: 13,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Gap(6),
                  if (widget.product.views > 0)
                    Row(
                      children: [
                        Icon(
                          Icons.local_fire_department,
                          size: 14,
                          color: AppColor.primary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${_formatViews(widget.product.views)} ${'people purchased rec...'.tr}',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  const Gap(6),
                  Row(
                    children: [
                      ...List.generate(5, (index) {
                        final trustScore = widget.product.trustScore?.score;
                        final rating = trustScore ??
                            (double.tryParse(
                                    widget.product.averageRating ?? "0") ??
                                0);
                        return Icon(
                          Icons.star,
                          size: 12,
                          color: index < rating.floor()
                              ? const Color(0xFFFFB800)
                              : Colors.grey[300],
                        );
                      }),
                      const SizedBox(width: 4),
                      Text(
                        widget.product.trustScore != null
                            ? widget.product.trustScore!.score.toStringAsFixed(1)
                            : '(${widget.product.rating?.count ?? 0})',
                        style: AppFont.font10w400Black.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const Gap(8),
                  widget.product.hasListedPrice
                      ? Row(
                    children: [
                      if (widget.product.afterPrice != null)
                        PriceWidget(
                          price: widget.product.afterPrice!,
                          style: AppFont.font14W600Primary.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                          textColor: AppColor.primary,
                          currencySize: 14,
                        ),
                      if (_hasOffer && widget.product.beforePrice != null) ...[
                        const SizedBox(width: 6),
                        PriceWidget(
                          price: widget.product.beforePrice!,
                          style: AppFont.font10w400Black.copyWith(
                            fontSize: 11,
                          ),
                          textColor: Colors.grey[500]!,
                          decoration: TextDecoration.lineThrough,
                          currencySize: 9,
                        ),
                      ],
                    ],
                  )
                      : Text(
                          'Contact the publisher'.tr,
                          style: AppFont.font14W600Primary,
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
