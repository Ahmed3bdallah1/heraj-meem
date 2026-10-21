import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj_meem/config/app_font.dart';
import 'package:heraj_meem/features/ads/data/models/product_details_model.dart';
import 'package:heraj_meem/features/ads/data/models/product_model.dart';
import 'package:heraj_meem/features/ads/presentation/managers/ad_contacted_provider.dart';
import 'package:heraj_meem/features/ads/presentation/managers/products_managers.dart';
import 'package:heraj_meem/features/ads/presentation/managers/publish_ad_flow.dart';
import 'package:heraj_meem/features/ads/presentation/view/add_ad_screen.dart';
import 'package:heraj_meem/features/ads/presentation/view/widgets/publisher_section.dart';
import 'package:heraj_meem/features/ads/presentation/view/widgets/product_image_carousel.dart';
import 'package:heraj_meem/features/ads/presentation/view/widgets/product_info_section.dart';
import 'package:heraj_meem/features/ads/presentation/view/widgets/product_info_cards_section.dart';
import 'package:heraj_meem/features/ads/presentation/view/widgets/product_description_section.dart';
import 'package:heraj_meem/features/ads/presentation/view/widgets/product_specifications_section.dart';
import 'package:heraj_meem/features/ads/presentation/view/widgets/rate_vendor_section.dart';
import 'package:heraj_meem/helper/riverpod.dart';
import 'package:heraj_meem/ui/shared_widgets/custom_filled_button.dart';
import 'package:heraj_meem/ui/shared_widgets/custom_outlined_button.dart';
import 'package:heraj_meem/ui/shared_widgets/shimmer_effect.dart';
import '../../../../main.dart';
import '../../../../ui/ui.dart';
import '../../../../core/service/local_data_manager.dart';
import '../../../chats/domain/use_case/create_chat_use_case.dart';
import '../../../chats/domain/entities/chat_entity.dart';
import '../../../chats/domain/use_case/send_message_use_case.dart';
import '../../../chats/presentation/view/chat_messages_screen.dart';
import '../../../chats/presentation/managers/chats_provider.dart';

class AdDetailsScreen extends ConsumerWidget {
  final String productId;
  final bool isReviewEnabled;
  final bool mine;

  const AdDetailsScreen({
    super.key,
    required this.productId,
    this.isReviewEnabled = false,
    this.mine = false,
  });

  Widget _buildBottomBar(
      BuildContext context, WidgetRef ref, ProductDetailsModel product) {

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
        child: _isMyAd(product)
            ? _ownerActions(context, ref, product)
            : Row(
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
                  final phone = product.sellerPhone ?? product.sellerId?.phone;
                  if (phone != null && phone.isNotEmpty) {
                    final countryCode = product.sellerId?.countryCode ?? '+966';
                    final fullPhone =
                        phone.startsWith('+') || phone.startsWith('00')
                            ? phone
                            : phone.startsWith('0')
                                ? '$countryCode${phone.substring(1)}'
                                : '$countryCode$phone';
                    UIHelper.phoneCall(fullPhone);
                    _markContacted(ref, product.id);
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
                      final chats = await ref.read(fetchChatsProvider.future);
                      for (final chat in chats) {
                        final hasVendor = chat.participants.any(
                          (participant) => participant.userId?.id == vendorId,
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
                      _markContacted(ref, product.id);
                      Get.to(() => ChatMessagesScreen(
                            chatId: existingChat!.id,
                            peerName: product.sellerId?.profile?.name,
                            peerImage: product.sellerId?.profile?.avatar,
                          ));
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
                          _markContacted(ref, product.id);
                          Get.to(() => ChatMessagesScreen(
                                chatId: chat.id,
                                isNewChat: true,
                                peerName: product.sellerId?.profile?.name,
                                peerImage: product.sellerId?.profile?.avatar,
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
        ));
  }

  Widget _ownerActions(
    BuildContext context,
    WidgetRef ref,
    ProductDetailsModel product,
  ) {
    final edit = CustomOutlinedButton(
      text: 'Edit'.tr,
      textColor: AppColor.primary,
      radius: 12,
      widget: Icon(Icons.edit_outlined, color: AppColor.primary, size: 20),
      onPressed: () => Get.to(() => AddAdScreen(ad: product)),
    );
    if (product.status.toUpperCase() != 'DRAFT') {
      return CustomFilledButton(
        text: 'Edit'.tr,
        color: AppColor.primary,
        radius: 12,
        widget: const Icon(
          Icons.edit_outlined,
          color: Colors.white,
          size: 20,
        ),
        onPressed: () => Get.to(() => AddAdScreen(ad: product)),
      );
    }
    return Row(
      children: [
        Expanded(child: edit),
        const Gap(6),
        Expanded(
          child: CustomFilledButton(
            text: 'Publish'.tr,
            color: AppColor.primary,
            radius: 12,
            widget: const Icon(
              Icons.campaign_outlined,
              color: Colors.white,
              size: 20,
            ),
            onPressed: () => confirmPublishAd(context, ref, product.id),
          ),
        ),
      ],
    );
  }

  void _markContacted(WidgetRef ref, String adId) {
    ref.read(adContactedProvider(adId).notifier).state = true;
  }

  bool _isMyAd(ProductDetailsModel product) {
    final myId = getIt<LocalDataManager>().getUser()?.id ?? '';
    final ownerId = product.sellerId?.id ?? '';
    return myId.isNotEmpty && ownerId.isNotEmpty && myId == ownerId;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailsProvider = mine
        ? fetchMyAdProvider(productId)
        : fetchProductByIdProvider(productId);
    final provider = ref.watch(detailsProvider);
    final contacted = ref.watch(adContactedProvider(productId));
    final hasProvider = provider.valueOrNull;

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
      ),
      bottomNavigationBar: hasProvider == null
          ? null
          : _buildBottomBar(context, ref, hasProvider),
      body: provider.customWhen(
        ref: ref,
        refreshable: detailsProvider.future,
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
          isMine: _isMyAd(product),
          showRate: contacted &&
              !_isMyAd(product) &&
              (product.sellerId?.id ?? '').isNotEmpty,
        ),
      ),
    );
  }
}

class _ProductDetailsBody extends StatelessWidget {
  final ProductDetailsModel product;
  final bool isReviewEnabled;
  final bool isMine;
  final bool showRate;

  const _ProductDetailsBody({
    required this.product,
    required this.isReviewEnabled,
    required this.isMine,
    required this.showRate,
  });

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
            isMine: isMine,
          ),
          ProductInfoSection(product: product),
          PublisherSection(product: product),
          if (showRate)
            RateVendorSection(
              adId: product.id,
              revieweeId: product.sellerId?.id ?? '',
            ),
          ProductInfoCardsSection(product: product),
          ProductSpecificationsSection(product: product),
          ProductDescriptionSection(product: product),
          const Gap(20),
        ],
      ),
    );
  }
}
