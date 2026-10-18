import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj/config/app_color.dart';
import 'package:heraj/config/app_font.dart';
import 'package:heraj/ui/shared_widgets/image_or_svg.dart';
import '../../../data/models/store_model.dart';
import '../store_details_screen.dart';

class StoreTile extends ConsumerStatefulWidget {
  final StoreModel store;
  final bool isFavorite;
  final VoidCallback? onFavoriteTap;

  const StoreTile({
    super.key,
    required this.store,
    this.isFavorite = false,
    this.onFavoriteTap,
  });

  @override
  ConsumerState<StoreTile> createState() => _StoreTileState();
}

class _StoreTileState extends ConsumerState<StoreTile> {
  bool _isNavigating = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (_isNavigating) return;
        _isNavigating = true;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StoreDetailsScreen(
              key: ValueKey('store_details_${widget.store.id}'),
              vendorId: widget.store.id,
            ),
          ),
        ).then((_) {
          _isNavigating = false;
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Get.isDarkMode ? AppColor.backGround : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
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
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: widget.store.banner != null &&
                          widget.store.banner!.isNotEmpty
                      ? KeyedSubtree(
                          key: ValueKey('tile_banner_${widget.store.id}'),
                          child: ImageOrSvg(
                            widget.store.banner!,
                            width: double.infinity,
                            height: 180,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Container(
                          width: double.infinity,
                          height: 180,
                          color: AppColor.grey1.withAlpha(75),
                          child: Icon(
                            Icons.store,
                            color: AppColor.grey2,
                            size: 60,
                          ),
                        ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: GestureDetector(
                    onTap: () {
                      widget.onFavoriteTap?.call();
                    },
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(25),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        widget.isFavorite
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: widget.isFavorite ? Colors.red : AppColor.grey2,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: widget.store.logo != null &&
                            widget.store.logo!.isNotEmpty
                        ? KeyedSubtree(
                            key: ValueKey('tile_logo_${widget.store.id}'),
                            child: ImageOrSvg(
                              widget.store.logo!,
                              width: 70,
                              height: 70,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Container(
                            width: 70,
                            height: 70,
                            color: AppColor.grey1.withOpacity(0.2),
                            child: Icon(
                              Icons.store,
                              color: AppColor.grey2,
                              size: 24,
                            ),
                          ),
                  ),
                  const Gap(12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.store.storeName,
                          style: AppFont.font16W700Black,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Gap(4),
                        if (widget.store.description != null &&
                            widget.store.description!.isNotEmpty)
                          Text(
                            widget.store.description!,
                            style: AppFont.font12w500Grey2,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )
                        else if (widget.store.address.isNotEmpty)
                          Text(
                            widget.store.address,
                            style: AppFont.font12w500Grey2,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        const Gap(8),
                        // Rating
                        Row(
                          children: [
                            if (widget.store.stats.rating > 0) ...[
                              Icon(
                                Icons.star,
                                size: 16,
                                color: Colors.amber,
                              ),
                              const Gap(4),
                              Text(
                                widget.store.stats.rating.toStringAsFixed(1),
                                style: AppFont.font14W600Black,
                              ),
                              const Gap(4),
                              Text(
                                "(${widget.store.stats.totalReviews})".tr,
                                style: AppFont.font12w500Grey2,
                              ),
                            ] else
                              Text(
                                "No ratings yet".tr,
                                style: AppFont.font12w500Grey2,
                              ),
                          ],
                        ),
                        const Gap(8),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 14,
                              color: AppColor.grey2,
                            ),
                            const Gap(4),
                            Text(
                              "60 min".tr,
                              style: AppFont.font12w500Grey2,
                            ),
                          ],
                        ),
                      ],
                    ),
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
