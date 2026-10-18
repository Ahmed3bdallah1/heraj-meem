import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj/config/app_color.dart';
import 'package:heraj/config/app_font.dart';
import 'package:heraj/features/store/data/models/store_model.dart';
import 'package:heraj/ui/shared_widgets/image_or_svg.dart';
import '../../store_details_screen.dart';

class StoreCardNew extends StatelessWidget {
  final StoreModel store;

  const StoreCardNew({
    super.key,
    required this.store,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.to(() => StoreDetailsScreen(vendorId: store.id));
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(12),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner Image with Logo and Favorite Button
            Stack(
              children: [
                // Banner Image
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: Container(
                    height: 150,
                    width: double.infinity,
                    color: Colors.grey[200],
                    child: store.banner != null
                        ? ImageOrSvg(
                            store.banner!,
                            fit: BoxFit.cover,
                          )
                        : Center(
                            child: Icon(
                              Icons.store,
                              size: 60,
                              color: Colors.grey[400],
                            ),
                          ),
                  ),
                ),
                
                // Logo in bottom left
                Positioned(
                  left: 16,
                  bottom: -20,
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(25),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(9),
                      child: store.logo != null
                          ? ImageOrSvg(
                              store.logo!,
                              fit: BoxFit.cover,
                            )
                          : Center(
                              child: Text(
                                store.storeName.isNotEmpty
                                    ? store.storeName[0].toUpperCase()
                                    : 'S',
                                style: AppFont.font18W700Black.copyWith(
                                  color: AppColor.primary,
                                ),
                              ),
                            ),
                    ),
                  ),
                ),
                
                // Favorite Button
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(25),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(
                        Icons.favorite_border,
                        size: 20,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        // TODO: Toggle favorite
                      },
                    ),
                  ),
                ),
              ],
            ),
            
            const Gap(28),
            
            // Store Info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Store Name and Verified Badge
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          store.storeName,
                          style: AppFont.font16W700Black,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (store.status == 'approved')
                        const Icon(
                          Icons.verified,
                          color: Color(0xFF2196F3),
                          size: 18,
                        ),
                    ],
                  ),
                  const Gap(8),
                  
                  // Rating
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        color: const Color(0xFFFF9800),
                        size: 16,
                      ),
                      const Gap(4),
                      Text(
                        store.stats.rating.toStringAsFixed(1),
                        style: AppFont.font14W600Black.copyWith(
                          color: Colors.grey[800],
                        ),
                      ),
                      const Gap(4),
                      Text(
                        '(${store.stats.totalReviews})',
                        style: AppFont.font12W400Grey1.copyWith(
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                  const Gap(8),
                  
                  // Location
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        color: Colors.grey[500],
                        size: 16,
                      ),
                      const Gap(4),
                      Expanded(
                        child: Text(
                          store.address.isNotEmpty ? store.address : 'Not specified'.tr,
                          style: AppFont.font12W400Grey1.copyWith(
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const Gap(12),
                  
                  // Products and Followers Count
                  Row(
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        color: Colors.grey[600],
                        size: 16,
                      ),
                      const Gap(4),
                      Text(
                        '${store.stats.totalProducts}',
                        style: AppFont.font14W600Black.copyWith(
                          color: Colors.grey[800],
                        ),
                      ),
                      const Gap(4),
                      Text(
                        'Products'.tr,
                        style: AppFont.font12W400Grey1.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const Gap(16),
                      Icon(
                        Icons.people_outline,
                        color: Colors.grey[600],
                        size: 16,
                      ),
                      const Gap(4),
                      Text(
                        '${store.followerCount}',
                        style: AppFont.font14W600Black.copyWith(
                          color: const Color(0xFF4CAF50),
                        ),
                      ),
                    ],
                  ),
                  const Gap(16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

