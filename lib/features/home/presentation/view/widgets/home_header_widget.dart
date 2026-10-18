import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj/core/service/location_service/location_provider.dart';
import 'package:heraj/features/favorites/presentation/managers/favorites.dart';
import 'package:heraj/features/favorites/presentation/view/favorites_list_screen.dart';
import 'package:heraj/features/notifications/presentation/managers/fetch_notificatons_provider.dart';
import 'package:heraj/features/notifications/presentation/view/notifications_screen.dart';
import 'package:heraj/ui/shared_widgets/loading_widget.dart';
import 'package:heraj/ui/shared_widgets/price_widget.dart';
import '../../../../cart/presentation/manager/fetch_cart_provider.dart';
import 'location_bottom_sheet.dart';
import '../../../../../config/app_font.dart';
import '../../../../cart/presentation/view/cart_items_screen.dart';
import '../../../../products/data/models/product_model.dart';
import '../../../../products/presentation/managers/products_managers.dart';
import '../../../../products/presentation/view/product_details_screen.dart';
import '../../../../search/presentation/view/search_screen.dart';

class HomeHeaderWidget extends ConsumerWidget {
  final bool isHome;
  final GlobalKey<ScaffoldState>? scaffoldKey;

  const HomeHeaderWidget({
    super.key,
    this.isHome = false,
    this.scaffoldKey,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationAsync = ref.watch(fetchLocationDetailsProvider);
    final currentDisplayLocation = ref.watch(currentDisplayLocationProvider);

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          await showLocationBottomSheet(context: context);
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColor.primary.withAlpha(40),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.location_on,
                                color: AppColor.primary,
                                size: 25,
                              ),
                            ),
                            const Gap(6),
                            Expanded(
                              child: Builder(
                                builder: (context) {
                                  final displayLocation =
                                      currentDisplayLocation ??
                                          locationAsync.value;

                                  if (displayLocation != null) {
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          displayLocation.fullAddress,
                                          style: AppFont.font11W400Grey2,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Row(
                                          children: [
                                            Flexible(
                                              child: Text(
                                                displayLocation.name,
                                                style: AppFont.font14W600Black,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const Gap(4),
                                            Icon(
                                              Icons.keyboard_arrow_down,
                                              color: AppColor.black,
                                              size: 18,
                                            ),
                                          ],
                                        ),
                                      ],
                                    );
                                  }

                                  // Loading state
                                  if (locationAsync.isLoading) {
                                    return Row(
                                      children: [
                                        Text(
                                          'Loading...'.tr,
                                          style: AppFont.font14W500Grey2,
                                        ),
                                        const Gap(4),
                                        SizedBox(
                                            width: 14,
                                            height: 14,
                                            child: LoadingWidget(size: 14,)),
                                      ],
                                    );
                                  }

                                  return Row(
                                    children: [
                                      Text(
                                        'All Turkey'.tr,
                                        style: AppFont.font14W600Black,
                                      ),
                                      const Gap(4),
                                      Icon(
                                        Icons.keyboard_arrow_down,
                                        color: AppColor.black,
                                        size: 18,
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (isHome) ...[
                      if (!(ref.watch(favoritesProvider).valueOrNull?.isEmpty ??
                          true)) ...[
                        Stack(
                          children: [
                            IconButton(
                              icon: Icon(
                                CupertinoIcons.heart,
                                color: AppColor.black,
                                size: 20,
                              ),
                              onPressed: () {
                                Get.to(() => const FavoritesListScreen());
                              },
                            ),
                            PositionedDirectional(
                                end: 8,
                                top: 8,
                                child: CircleAvatar(
                                  radius: 6,
                                  backgroundColor: AppColor.danger,
                                )),
                          ],
                        ),
                      ] else ...[
                        IconButton(
                          icon: Icon(
                            CupertinoIcons.heart,
                            color: AppColor.black,
                            size: 20,
                          ),
                          onPressed: () {
                            Get.to(() => const FavoritesListScreen());
                          },
                        ),
                      ],
                    ] else ...[
                      if (!(ref
                              .watch(fetchCartProvider)
                              .valueOrNull
                              ?.items
                              .isEmpty ??
                          true)) ...[
                        Stack(
                          children: [
                            IconButton(
                              icon: Icon(
                                CupertinoIcons.shopping_cart,
                                color: AppColor.black,
                                size: 20,
                              ),
                              onPressed: () {
                                Get.to(() => const CartItemsScreen2());
                              },
                            ),
                            PositionedDirectional(
                                end: 8,
                                top: 8,
                                child: CircleAvatar(
                                  radius: 6,
                                  backgroundColor: AppColor.danger,
                                )),
                          ],
                        ),
                      ] else ...[
                        IconButton(
                          icon: Icon(
                            CupertinoIcons.shopping_cart,
                            color: AppColor.black,
                            size: 20,
                          ),
                          onPressed: () {
                            Get.to(() => const CartItemsScreen2());
                          },
                        ),
                      ],
                    ],
                    if (!isHome)
                      IconButton(
                        icon: Icon(
                          Icons.category_outlined,
                          color: AppColor.black,
                          size: 20,
                        ),
                        onPressed: () {
                          if (scaffoldKey?.currentState != null) {
                            scaffoldKey!.currentState!.openEndDrawer();
                          } else {
                            Scaffold.of(context).openEndDrawer();
                          }
                        },
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
                                    size: 20,
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
                                          unreadCount > 99
                                              ? '99+'
                                              : '$unreadCount',
                                          style:
                                              AppFont.font10w400Black.copyWith(
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
                              size: 20,
                            ),
                            onPressed: () {
                              Get.to(() => const NotificationsScreen());
                            },
                          ),
                          error: (_, __) => IconButton(
                            icon: Icon(
                              CupertinoIcons.bell,
                              color: AppColor.black,
                              size: 20,
                            ),
                            onPressed: () {
                              Get.to(() => const NotificationsScreen());
                            },
                          ),
                        ),
                  ],
                ),
                const Gap(12),
                Row(
                  children: [
                    Expanded(
                      child: TypeAheadField<ProductModel>(
                        builder: (context, controller, focusNode) {
                          return Container(
                            decoration: BoxDecoration(
                              color: AppColor.primary2,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColor.primary.withAlpha(75),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColor.primary.withAlpha(30),
                                  blurRadius: 10,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: controller,
                              focusNode: focusNode,
                              decoration: InputDecoration(
                                hintText: 'Search'.tr,
                                hintStyle: AppFont.font14W500Grey2,
                                prefixIcon: Icon(
                                  CupertinoIcons.search,
                                  color: AppColor.grey2,
                                  size: 20,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                      color: AppColor.grey1.withAlpha(100)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                      color: AppColor.grey1.withAlpha(100)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                      color: AppColor.primary, width: 2),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                filled: false,
                                fillColor: Colors.white,
                              ),
                              style: AppFont.font14W500Grey2,
                            ),
                          );
                        },
                        suggestionsCallback: (pattern) async {
                          if (pattern.isEmpty) return [];
                          try {
                            final products = await ref
                                .read(searchProductsProvider(pattern).future);
                            return products.take(6).toList();
                          } catch (e) {
                            return <ProductModel>[];
                          }
                        },
                        itemBuilder: (context, ProductModel product) {
                          return ListTile(
                            leading: (product.thumbImage?.isNotEmpty ?? false)
                                ? Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        boxShadow: [
                                          BoxShadow(
                                              color: AppColor.primary
                                                  .withAlpha(120),
                                              spreadRadius: 2,
                                              blurRadius: 8)
                                        ]),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        product.thumbImage ?? '',
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Container(
                                            width: 50,
                                            height: 50,
                                            color: AppColor.grey1,
                                            child: Icon(
                                              Icons.image_not_supported,
                                              color: AppColor.grey2,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  )
                                : Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: AppColor.grey1,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.image_not_supported,
                                      color: AppColor.grey2,
                                    ),
                                  ),
                            title: Text(
                              product.name,
                              style: AppFont.font14W600Black,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Row(
                              spacing: 6,
                              children: [
                                PriceWidget(
                                  price: product.afterPrice.toString(),
                                  textColor: AppColor.primary,
                                ),
                                PriceWidget(
                                  price: product.beforePrice.toString(),
                                  style: AppFont.font10w400Black.copyWith(
                                      decoration: TextDecoration.lineThrough),
                                ),
                              ],
                            ),
                          );
                        },
                        onSelected: (ProductModel product) {
                          Get.to(() =>
                              ProductDetailsScreen(productId: product.id));
                        },
                        emptyBuilder: (context) => Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            'No products found'.tr,
                            style: AppFont.font14W600Primary,
                          ),
                        ),
                        loadingBuilder: (context) => Padding(
                          padding: const EdgeInsets.all(16),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppColor.primary,
                            ),
                          ),
                        ),
                        errorBuilder: (context, error) => Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            'Error loading suggestions'.tr,
                            style: AppFont.font14W500Grey2,
                          ),
                        ),
                      ),
                    ),
                    if (!isHome) ...[
                      const Gap(8),
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColor.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.tune,
                            color: Colors.white,
                            size: 24,
                          ),
                          onPressed: () {
                            Get.to(() => const SearchAllProductsScreen());
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
