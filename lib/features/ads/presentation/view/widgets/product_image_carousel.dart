import 'package:flutter/material.dart' hide CarouselController;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj_meem/features/favorites/presentation/managers/favorites.dart';
import 'package:heraj_meem/config/app_font.dart';
import 'package:heraj_meem/features/favorites/presentation/view/widgets/favorite_button.dart';
import 'package:heraj_meem/features/ads/data/models/product_details_model.dart';
import 'package:heraj_meem/features/ads/data/models/product_model.dart';
import 'package:heraj_meem/ui/shared_widgets/container_button.dart';
import 'package:heraj_meem/ui/shared_widgets/image_or_svg.dart';

import 'product_badge_widget.dart';

class ProductImageCarousel extends ConsumerStatefulWidget {
  final ProductModel productModel;
  final List<dynamic> images;
  final List<BadgeModel>? badges;
  final bool isMine;

  const ProductImageCarousel({
    super.key,
    required this.images,
    this.badges,
    required this.productModel,
    this.isMine = false,
  });

  @override
  ConsumerState<ProductImageCarousel> createState() =>
      _ProductImageCarouselState();
}

class _ProductImageCarouselState extends ConsumerState<ProductImageCarousel> {
  final indexChanged = StateProvider.autoDispose((ref) => 0);
  final CarouselController _carouselController = CarouselController();

  bool get _hasOffer {
    if (widget.productModel.beforePrice == null ||
        widget.productModel.afterPrice == null) {
      return false;
    }
    final before =
        double.tryParse(widget.productModel.beforePrice.toString()) ?? 0;
    final after =
        double.tryParse(widget.productModel.afterPrice.toString()) ?? 0;
    return before > 0 && after > 0 && before > after;
  }

  double get _discountPercentage {
    if (!_hasOffer) return 0;
    final before =
        double.tryParse(widget.productModel.beforePrice.toString()) ?? 0;
    final after =
        double.tryParse(widget.productModel.afterPrice.toString()) ?? 0;
    if (before == 0) return 0;
    return ((before - after) / before) * 100;
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.images;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Stack(
            children: [
              CarouselSlider.builder(
                itemCount: images.isNotEmpty ? images.length : 1,
                carouselController: _carouselController,
                options: CarouselOptions(
                    initialPage: ref.watch(indexChanged),
                    height: 350,
                    viewportFraction: 1.0,
                    aspectRatio: 1,
                    autoPlay: true,
                    onPageChanged: (index, _) {
                      ref.read(indexChanged.notifier).state = index;
                    }),
                itemBuilder: (context, index, realIndex) {
                  final image =
                      images.isNotEmpty ? images[index].toString() : "";
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      color: AppColor.white,
                      child: ImageOrSvg(
                        image,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        height: 350,
                        magnifier: true,
                      ),
                    ),
                  );
                },
              ),
              if (_hasOffer)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColor.danger,
                    borderRadius: BorderRadiusDirectional.only(
                      bottomEnd: Radius.circular(20),
                      topStart: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'OFFER'.tr,
                        style: AppFont.font10w400Black.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${_discountPercentage.toStringAsFixed(0)}%',
                        style: AppFont.font10w400Black.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              if (widget.badges != null && widget.badges!.isNotEmpty)
                PositionedDirectional(
                  top: 20,
                  end: 10,
                  child: Column(
                    children: [
                      ProductBadgesList(badges: widget.badges!),
                      const Gap(12),
                    ],
                  ),
                ),
              PositionedDirectional(
                end: 10,
                bottom: 15,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(20),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star, size: 16, color: AppColor.primary),
                      const SizedBox(width: 4),
                      Text(
                        (widget.productModel.averageRating ?? '0.0').toString(),
                        style: AppFont.font12w400Black,
                      ),
                    ],
                  ),
                ),
              ),
              if (!widget.isMine)
                PositionedDirectional(
                  start: 10,
                  bottom: 15,
                  child: Row(
                    children: [
                      ContainerButton(
                        radius: 20,
                        size: 30,
                        color: Colors.white,
                        icon: Icons.share,
                        iconColor: AppColor.black,
                        onTap: () {},
                      ),
                      const Gap(8),
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: AppColor.white,
                        child: FavoriteButton(
                          product: widget.productModel,
                          ref: ref,
                          size: 50,
                          color: AppColor.black,
                          isFavorited: ref.watch(isFavoritedProduct(
                              widget.productModel.id.toString())),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        if (images.isNotEmpty)
          SizedBox(
            height: 90,
            child: ListView.separated(
              padding: EdgeInsetsDirectional.only(start: 16, top: 5, end: 5),
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              separatorBuilder: (_, __) => const Gap(10),
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    ref.read(indexChanged.notifier).state = index;
                    _carouselController.jumpToPage(ref.watch(indexChanged));
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                              color: index == ref.watch(indexChanged)
                                  ? AppColor.primary.withAlpha(120)
                                  : AppColor.white,
                              blurRadius: 5,
                              spreadRadius: 1)
                        ],
                        border: Border.all(
                            color: index == ref.watch(indexChanged)
                                ? AppColor.primary
                                : Colors.transparent)),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: ImageOrSvg(
                        images[index],
                        height: 80,
                        width: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              },
            ),
          )
      ],
    );
  }
}
