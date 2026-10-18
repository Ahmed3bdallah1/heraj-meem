import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj_meem/config/app_font.dart';
import 'package:heraj_meem/features/products/data/models/product_details_model.dart';
import 'package:heraj_meem/features/products/data/models/product_model.dart';
import 'package:heraj_meem/features/products/presentation/managers/products_managers.dart';
import 'package:heraj_meem/features/products/presentation/view/widgets/product_image_carousel.dart';
import 'package:heraj_meem/features/products/presentation/view/widgets/product_info_section.dart';
import 'package:heraj_meem/features/products/presentation/view/widgets/product_info_cards_section.dart';
import 'package:heraj_meem/features/products/presentation/view/widgets/product_description_section.dart';
import 'package:heraj_meem/features/products/presentation/view/widgets/product_specifications_section.dart';
import 'package:heraj_meem/features/products/presentation/view/widgets/reviews_section.dart';
import 'package:heraj_meem/features/products/presentation/view/widgets/similar_products_section.dart';
import 'package:heraj_meem/features/bundles/presentation/view/widgets/bundle_products_section.dart';
import 'package:heraj_meem/helper/riverpod.dart';
import 'package:heraj_meem/ui/shared_widgets/custom_filled_button.dart';
import 'package:heraj_meem/ui/shared_widgets/custom_outlined_button.dart';
import 'package:heraj_meem/ui/shared_widgets/shimmer_effect.dart';
import '../../../../main.dart';
import '../../../../ui/ui.dart';
import '../../../../core/service/local_data_manager.dart';
import '../../../cart/domain/use_cases/cart_use_case.dart';
import '../../../cart/presentation/manager/fetch_cart_provider.dart';
import '../../../cart/presentation/view/cart_items_screen.dart';
import '../../../chats/domain/use_case/create_chat_use_case.dart';
import '../../../chats/domain/entities/chat_entity.dart';
import '../../../chats/domain/use_case/send_message_use_case.dart';
import '../../../chats/presentation/view/chat_messages_screen.dart';
import '../../../chats/presentation/managers/chats_provider.dart';

class ProductDetailsScreen extends ConsumerWidget {
  final String productId;
  final bool isReviewEnabled;

  const ProductDetailsScreen(
      {super.key, required this.productId, this.isReviewEnabled = false});

  Widget _buildBottomBar(
      BuildContext context, WidgetRef ref, ProductDetailsModel product) {
    final isVendor = product.productType.toLowerCase() == 'vendor' ||
        product.productType.toLowerCase() == 'customer';

    return Container(
      padding: const EdgeInsets.all(12)
          .copyWith(bottom: MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColor.primary.withAlpha(20),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: isVendor
          ? Row(
              children: [
                Expanded(
                  child: CustomOutlinedButton(
                    text: 'Call'.tr,
                    color: AppColor.primary,
                    textColor: AppColor.primary,
                    radius: 12,
                    widget: Icon(
                      Icons.phone_outlined,
                      color: AppColor.primary,
                      size: 20,
                    ),
                    onPressed: () {
                      final phone =
                          product.sellerPhone ?? product.sellerId?.phone;
                      if (phone != null && phone.isNotEmpty) {
                        final countryCode =
                            product.sellerId?.countryCode ?? '+90';
                        final fullPhone = phone.startsWith('00')
                            ? phone.substring(2)
                            : phone.startsWith('0')
                                ? "+$countryCode${phone.substring(1)}"
                                : "+$countryCode$phone";
                        UIHelper.phoneCall(fullPhone);
                      } else {
                        UIHelper.showGlobalSnackBar(
                          text: 'Phone number not available'.tr,
                          color: AppColor.danger,
                        );
                      }
                    },
                  ),
                ),
                const Gap(6),
                Expanded(
                  child: CustomFilledButton(
                    text: 'Chat'.tr,
                    color: AppColor.primary,
                    radius: 12,
                    widget: Icon(
                      Icons.chat_bubble_outline,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: () async {
                      final currentUser = getIt<LocalDataManager>().getUser();
                      if (currentUser == null || product.sellerId == null) {
                        UIHelper.showGlobalSnackBar(
                          text: 'Unable to start chat'.tr,
                          color: Colors.red,
                        );
                        return;
                      }

                      try {
                        final currentUserId = currentUser.id.toString();
                        final vendorId = product.sellerId!.id.toString();

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
                          final useCase = getIt<SendMessageUseCase>();
                          await useCase.call({
                            'chatId': existingChat.id,
                            'content':
                                "I'm interested in this product: ${product.name}",
                            "productId": product.id,
                          });
                          Get.to(() =>
                              ChatMessagesScreen(chatId: existingChat!.id));
                        } else {
                          final createChatUseCase = getIt<CreateChatUseCase>();
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
                  ),
                ),
              ],
            )
          : CustomFilledButton(
              text: ref.watch(isInCartProductProvider(productId.toString()))
                  ? "Go to cart".tr
                  : "Add to Cart".tr,
              onPressed: () async {
                if (ref.watch(isInCartProductProvider(productId.toString()))) {
                  Get.to(() => CartItemsScreen2());
                } else {
                  final res = await getIt<AddToCartItemsUseCase>()
                      .call(productId.toString());
                  res.fold(
                    (l) => UIHelper.showGlobalSnackBar(
                        text: l.message, color: AppColor.danger),
                    (r) {
                      UIHelper.showGlobalSnackBar(
                          text: 'Product added to cart successfully'.tr,
                          color: AppColor.green);
                    },
                  );
                  ref.invalidate(fetchCartProvider);
                }
              },
              color: AppColor.primary,
              height: 55,
              isExpanded: true,
            ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.watch(fetchProductByIdProvider(productId));
    final hasProvider =
        ref.watch(fetchProductByIdProvider(productId)).valueOrNull;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "product details".tr,
          style: AppFont.font16W700Black,
        ),
        actions: [
          if (kDebugMode)
            IconButton(
              icon: const Icon(Icons.bug_report, color: Colors.orange),
              tooltip: 'Test error screen',
              onPressed: () => Get.to(() => const _ErrorScreenTestPage()),
            ),
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined, color: Colors.black),
            onPressed: () => Get.to(() => const CartItemsScreen2()),
          ),
        ],
      ),
      bottomNavigationBar: hasProvider == null
          ? null
          : _buildBottomBar(context, ref, hasProvider),
      body: provider.customWhen(
        ref: ref,
        refreshable: fetchProductByIdProvider(productId).future,
        loading: () => SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShimmerEffect(
                enable: true,
                child: Container(
                  height: 300,
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const Gap(24),
              ...List.generate(
                  3,
                  (index) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: ShimmerEffect(
                          enable: true,
                          child: Container(
                            height: index == 0 ? 30 : 20,
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      )),
              const Gap(24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ShimmerEffect(
                  enable: true,
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const Gap(32),
            ],
          ),
        ),
        data: (product) => _ProductDetailsBody(
          product: product,
          isReviewEnabled: isReviewEnabled,
        ),
      ),
    );
  }
}

class _ErrorScreenTestPage extends StatelessWidget {
  const _ErrorScreenTestPage();

  @override
  Widget build(BuildContext context) {
    throw FlutterError('Test: triggering global error screen (Lottie)');
  }
}

class _ProductDetailsBody extends StatelessWidget {
  final ProductDetailsModel product;
  final bool isReviewEnabled;

  const _ProductDetailsBody(
      {required this.product, required this.isReviewEnabled});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          ProductImageCarousel(
            images: product.images,
            productModel: ProductModel.fromDetailsModel(product),
            badges: product.badges,
          ),
          ProductInfoSection(product: product),
          ProductInfoCardsSection(product: product),
          ProductSpecificationsSection(product: product),
          ProductDescriptionSection(product: product),
          BundleProductsSection(productId: product.id),
          ReviewsSection(
            productId: product.id,
            isReviewEnabled: isReviewEnabled,
          ),
          SimilarProductsSection(
            categoryId: product.adminCategory?.id ?? product.categoryId ?? "",
            productType: product.productType,
            productId: product.id,
          ),
          const Gap(20),
        ],
      ),
    );
  }
}
