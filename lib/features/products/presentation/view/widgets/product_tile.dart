import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj/core/service/local_data_manager.dart';
import 'package:heraj/features/cart/domain/use_cases/cart_use_case.dart';
import 'package:heraj/features/cart/presentation/manager/fetch_cart_provider.dart';
import 'package:heraj/features/cart/presentation/view/cart_items_screen.dart';
import 'package:heraj/features/chats/domain/entities/chat_entity.dart';
import 'package:heraj/features/chats/domain/use_case/create_chat_use_case.dart';
import 'package:heraj/features/chats/domain/use_case/send_message_use_case.dart';
import 'package:heraj/features/chats/presentation/managers/chats_provider.dart';
import 'package:heraj/features/chats/presentation/view/chat_messages_screen.dart';
import 'package:heraj/features/favorites/presentation/managers/favorites.dart';
import 'package:heraj/features/favorites/presentation/view/widgets/favorite_button.dart';
import 'package:heraj/features/products/presentation/view/product_details_screen.dart';
import 'package:heraj/main.dart';
import '../../../../../config/app_font.dart';
import '../../../../../core/service/localization_service/localization_service.dart';
import '../../../../../ui/shared_widgets/image_or_svg.dart';
import '../../../../../ui/shared_widgets/price_widget.dart';
import '../../../../../ui/ui.dart';
import '../../../data/models/product_model.dart';

// Helper Extensions
extension ProductTileHelpers on ProductModel {
  bool get hasOffer {
    if (beforePrice == null || afterPrice == null) return false;
    final before = double.tryParse(beforePrice.toString()) ?? 0;
    final after = double.tryParse(afterPrice.toString()) ?? 0;
    return before > 0 && after > 0 && before > after;
  }

  double get discountPercentage {
    if (!hasOffer) return 0;
    final before = double.tryParse(beforePrice.toString()) ?? 0;
    final after = double.tryParse(afterPrice.toString()) ?? 0;
    if (before == 0) return 0;
    return ((before - after) / before) * 100;
  }

  bool get isAdminProduct {
    return productType == "admin" || adminCategory != null;
  }

  String formatViews(int views) {
    if (views >= 1000) {
      return '${(views / 1000).toStringAsFixed(1)}K';
    }
    return views.toString();
  }

  String getProductName(String langCode) {
    return langCode == "en"
        ? name
        : langCode == "ar"
            ? titleAr ?? ""
            : titleTr ?? "";
  }
}

class ProductTile extends ConsumerWidget {
  final ProductModel product;

  const ProductTile({super.key, required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return product.isAdminProduct
        ? RepaintBoundary(child: AdminProductTile(product: product))
        : RepaintBoundary(child: VendorProductTile(product: product));
  }
}

// Official Store Badge Widget
class _OfficialStoreBadge extends StatelessWidget {
  const _OfficialStoreBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: AppColor.primary,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColor.primary.withAlpha(75),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, size: 10, color: Colors.white),
          const SizedBox(width: 2),
          Text(
            'Official Store'.tr,
            style:
                AppFont.font10w400White.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 2),
          const Icon(Icons.verified, size: 10, color: Colors.white),
        ],
      ),
    );
  }
}

// Sale Badge Widget
class _SaleBadge extends StatelessWidget {
  const _SaleBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: AppColor.danger,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        'Sale'.tr,
        style: AppFont.font10w400White.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// Star Rating Widget
class StarRating extends StatelessWidget {
  final ProductModel product;

  const StarRating({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ...List.generate(5, (index) {
          final rating = product.rating?.average ?? 0.0;
          if (index + 1 <= rating.floor()) {
            return Icon(
              Icons.star,
              size: 13,
              color: AppColor.orange,
            );
          } else if (index < rating && rating - rating.floor() >= 0.5) {
            return Icon(
              Icons.star_half,
              size: 13,
              color: AppColor.orange,
            );
          } else {
            return Icon(
              Icons.star_border,
              size: 13,
              color: AppColor.grey2,
            );
          }
        }),
        Text(
          '(${product.rating?.count ?? 0})',
          style: AppFont.font10w400Black.copyWith(color: AppColor.grey2),
        ),
      ],
    );
  }
}

// Verified Badge Widget
class _VerifiedBadge extends StatelessWidget {
  const _VerifiedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
      decoration: BoxDecoration(
        color: AppColor.primary.withAlpha(25),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColor.primary, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified, size: 10, color: AppColor.primary),
          const SizedBox(width: 3),
          Text(
            'VERIFIED'.tr,
            style: AppFont.font10w400Black.copyWith(
              fontSize: 8,
              fontWeight: FontWeight.w700,
              color: AppColor.primary,
            ),
          ),
        ],
      ),
    );
  }
}

// Purchase Activity Widget
class _PurchaseActivity extends StatelessWidget {
  final int views;

  const _PurchaseActivity({required this.views});

  String _formatViews() {
    if (views >= 1000) {
      return '${(views / 1000).toStringAsFixed(1)}K';
    }
    return views.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.local_fire_department, size: 13, color: AppColor.primary),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            '${_formatViews()} ${'people purchased recently!'.tr}',
            style: AppFont.font10w400Black.copyWith(
              color: AppColor.primary,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// Price Display Widget
class _PriceDisplay extends StatelessWidget {
  final ProductModel product;

  const _PriceDisplay({required this.product});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (product.afterPrice != null)
          PriceWidget(
            price: product.afterPrice!,
            style: AppFont.font18W700Black.copyWith(color: AppColor.primary),
            textColor: AppColor.primary,
            currencySize: 16,
          ),
        if (product.hasOffer && product.beforePrice != null) ...[
          const SizedBox(width: 6),
          PriceWidget(
            price: product.beforePrice!,
            style: AppFont.font10w400Black.copyWith(
              fontSize: 11,
              color: AppColor.grey2,
            ),
            textColor: AppColor.grey2,
            decoration: TextDecoration.lineThrough,
            currencySize: 9,
          ),
        ],
      ],
    );
  }
}

// Admin Product Tile
class AdminProductTile extends ConsumerWidget {
  final ProductModel product;

  const AdminProductTile({super.key, required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final langCode = getIt<LocaleService>().getLocale().locale.languageCode;
    final productName = product.getProductName(langCode);

    return Container(
      constraints: const BoxConstraints(maxWidth: 200, minWidth: 160),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColor.primary.withAlpha(75),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColor.black.withAlpha(15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => Get.to(
          () => ProductDetailsScreen(productId: product.id),
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
                    top: Radius.circular(10),
                  ),
                  child: SizedBox(
                    height: 180,
                    width: double.infinity,
                    child: product.thumbImage != null &&
                            product.thumbImage!.isNotEmpty
                        ? ImageOrSvg(
                            product.thumbImage,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            color: AppColor.grey1,
                            child: const Icon(Icons.image, size: 48),
                          ),
                  ),
                ),
                // Official Store Badge
                const PositionedDirectional(
                  top: 8,
                  start: 8,
                  child: _OfficialStoreBadge(),
                ),
                // Sale Badge
                if (product.hasOffer)
                  const PositionedDirectional(
                    top: 8,
                    end: 8,
                    child: _SaleBadge(),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    productName,
                    style: AppFont.font12W600Black.copyWith(
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Gap(4),
                  _PriceDisplay(product: product),
                  const Gap(6),
                  if (product.views > 0)
                    _PurchaseActivity(views: product.views),
                  const Gap(6),
                  Row(
                    spacing: 4,
                    children: [
                      StarRating(product: product),
                      const _VerifiedBadge(),
                    ],
                  ),
                  const Gap(10),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColor.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColor.grey1,
                            width: 1,
                          ),
                        ),
                        child: FavoriteButton(
                          product: product,
                          ref: ref,
                          color: AppColor.grey1,
                          isFavorited:
                              ref.watch(isFavoritedProduct(product.id)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Consumer(builder: (context, ref, _) {
                          final isInCart = ref.watch(
                              isInCartProductProvider(product.id.toString()));
                          return ElevatedButton(
                            onPressed: () async {
                              if (isInCart) {
                                Get.to(() => CartItemsScreen2());
                              } else {
                                final res = await getIt<AddToCartItemsUseCase>()
                                    .call(product.id.toString());
                                res.fold(
                                  (l) => UIHelper.showGlobalSnackBar(
                                      text: l.message, color: AppColor.danger),
                                  (r) {
                                    UIHelper.showGlobalSnackBar(
                                        text:
                                            'Product added to cart successfully'
                                                .tr,
                                        color: AppColor.green);
                                  },
                                );
                                ref.invalidate(fetchCartProvider);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColor.primary,
                              foregroundColor: AppColor.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isInCart ? Icons.check : Icons.shopping_cart,
                                  size: 16,
                                  color: AppColor.white,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  isInCart ? 'In Cart'.tr : 'Add'.tr,
                                  style: AppFont.font12W600White.copyWith(
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ),
                    ],
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

// Vendor Product Tile
class VendorProductTile extends ConsumerWidget {
  final ProductModel product;

  const VendorProductTile({super.key, required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final langCode = getIt<LocaleService>().getLocale().locale.languageCode;
    final productName = product.getProductName(langCode);

    return Container(
      constraints: const BoxConstraints(maxWidth: 200, minWidth: 160),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColor.grey1,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColor.black.withAlpha(15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => Get.to(
          () => ProductDetailsScreen(productId: product.id),
          preventDuplicates: false,
        ),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(10),
              ),
              child: SizedBox(
                height: 160,
                width: double.infinity,
                child:
                    product.thumbImage != null && product.thumbImage!.isNotEmpty
                        ? ImageOrSvg(
                            product.thumbImage,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            color: AppColor.grey1,
                            child: const Icon(Icons.image, size: 48),
                          ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    productName,
                    style: AppFont.font12W600Black.copyWith(
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Gap(6),
                  if (product.afterPrice != null)
                    _PriceDisplay(product: product),
                  const Gap(6),
                  StarRating(product: product),
                  const Gap(8),
                  if (product.location != null)
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: AppColor.grey2,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            product.location?.neighborhood ?? 'Location'.tr,
                            style: AppFont.font10w400Black.copyWith(
                              color: AppColor.grey2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  const Gap(8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            final phone = product.sellerPhone;
                            if (phone != null && phone.isNotEmpty) {
                              UIHelper.phoneCall(phone);
                            } else {
                              UIHelper.showGlobalSnackBar(
                                text: 'Phone number not available'.tr,
                                color: AppColor.danger,
                              );
                            }
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColor.primary,
                            side: BorderSide(color: AppColor.primary),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.phone_outlined,
                                size: 14,
                                color: AppColor.primary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Call'.tr,
                                style: AppFont.font10w400Black.copyWith(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColor.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            final currentUser =
                                getIt<LocalDataManager>().getUser();
                            if (product.sellerId == null) {
                              UIHelper.showGlobalSnackBar(
                                text: 'Unable to start chat'.tr,
                                color: Colors.red,
                              );
                              return;
                            }

                            try {
                              final currentUserId = currentUser?.id.toString();
                              final vendorId = product.sellerId?.toString();
                              final useCase = getIt<SendMessageUseCase>();

                              ChatEntity? existingChat;
                              try {
                                final chats =
                                    await ref.read(fetchChatsProvider.future);
                                for (final chat in chats) {
                                  final hasVendor = chat.participants.any(
                                    (participant) =>
                                        participant.userId?.id == vendorId,
                                  );
                                  final hasCurrentUser = chat.participants.any(
                                    (participant) =>
                                        participant.userId?.id == currentUserId,
                                  );

                                  if (hasVendor && hasCurrentUser) {
                                    existingChat = chat;
                                    break;
                                  }
                                }
                              } catch (e) {
                                existingChat = null;
                              }

                              if (existingChat != null) {
                                await useCase.call({
                                  'chatId': existingChat.id,
                                  'content':
                                      "I'm interested in this product: ${product.name}",
                                  "productId": product.id,
                                });
                                Get.to(() => ChatMessagesScreen(
                                    chatId: existingChat!.id));
                              } else {
                                final createChatUseCase =
                                    getIt<CreateChatUseCase>();
                                final result = await createChatUseCase.call({
                                  'userId': currentUserId,
                                  'participantId': vendorId,
                                  'productId': product.id,
                                });

                                result.fold(
                                  (failure) {
                                    UIHelper.showGlobalSnackBar(
                                      text: 'Failed to create chat'.tr,
                                      color: Colors.red,
                                    );
                                  },
                                  (chat) {
                                    Get.to(() => ChatMessagesScreen(
                                          chatId: chat.id,
                                          isNewChat: true,
                                        ));
                                  },
                                );
                              }
                            } catch (e) {
                              UIHelper.showGlobalSnackBar(
                                text: 'Error: ${e.toString()}'.tr,
                                color: Colors.red,
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor.primary,
                            foregroundColor: AppColor.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.chat_bubble_outline,
                                size: 14,
                                color: AppColor.white,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Chat'.tr,
                                style: AppFont.font10w400White.copyWith(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
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
