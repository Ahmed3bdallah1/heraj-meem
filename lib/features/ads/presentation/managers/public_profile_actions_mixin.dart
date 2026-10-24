import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:heraj_meem/config/app_font.dart';
import 'package:heraj_meem/core/service/local_data_manager.dart';
import 'package:heraj_meem/features/ads/data/models/public_profile_model.dart';
import 'package:heraj_meem/features/ads/presentation/managers/ad_contacted_provider.dart';
import 'package:heraj_meem/features/ads/presentation/view/public_profile_screen.dart';
import 'package:heraj_meem/features/chats/domain/entities/chat_entity.dart';
import 'package:heraj_meem/features/chats/domain/use_case/create_chat_use_case.dart';
import 'package:heraj_meem/features/chats/domain/use_case/send_message_use_case.dart';
import 'package:heraj_meem/features/chats/presentation/managers/chats_provider.dart';
import 'package:heraj_meem/features/chats/presentation/view/chat_messages_screen.dart';
import 'package:heraj_meem/main.dart';
import 'package:heraj_meem/ui/ui.dart';

mixin PublicProfileActionsMixin on ConsumerState<PublicProfileScreen> {
  final chatting = ValueNotifier<bool>(false);

  void disposeProfileActions() {
    chatting.dispose();
  }

  bool isOwnProfile(String profileId) {
    final myId = getIt<LocalDataManager>().getUser()?.id ?? '';
    final ownerId = profileId.isNotEmpty ? profileId : widget.userId;
    return myId.isNotEmpty && myId == ownerId;
  }

  Future<void> callPublisher(PublicProfileModel profile) async {
    final product = widget.product;
    final phone = _fullPhone(
      profile.phone.isNotEmpty
          ? profile.phone
          : product?.sellerPhone ?? product?.sellerId?.phone,
      profile.countryCode.isNotEmpty
          ? profile.countryCode
          : product?.sellerId?.countryCode,
    );
    if (phone == null) {
      UIHelper.showGlobalSnackBar(
        text: 'Phone number not available'.tr,
        color: AppColor.danger,
      );
      return;
    }
    UIHelper.phoneCall(phone);
    final adId = product?.id ?? '';
    if (adId.isNotEmpty) {
      ref.read(adContactedProvider(adId).notifier).state = true;
    }
  }

  Future<void> chatPublisher(PublicProfileModel profile) async {
    if (chatting.value) return;
    final currentUser = getIt<LocalDataManager>().getUser();
    final vendorId = profile.id.isNotEmpty ? profile.id : widget.userId;
    if (currentUser == null || vendorId.isEmpty) {
      UIHelper.showGlobalSnackBar(
        text: 'Unable to start chat'.tr,
        color: AppColor.danger,
      );
      return;
    }

    chatting.value = true;
    try {
      final currentUserId = currentUser.id.toString();
      final product = widget.product;
      ChatEntity? existingChat;
      try {
        final chats = await ref.read(fetchChatsProvider.future);
        for (final chat in chats) {
          final hasVendor = chat.participants.any(
            (participant) => participant.userId?.id == vendorId,
          );
          final hasCurrentUser = chat.participants.any(
            (participant) => participant.userId?.id == currentUserId,
          );
          if (hasVendor && hasCurrentUser) {
            existingChat = chat;
            break;
          }
        }
      } catch (_) {
        existingChat = null;
      }

      if (!mounted) return;
      if (existingChat != null) {
        if (product != null) {
          await getIt<SendMessageUseCase>().call(<String, dynamic>{
            'chatId': existingChat.id,
            'content': "I'm interested in this product: ${product.name}",
            'productId': product.id,
          });
          ref.read(adContactedProvider(product.id).notifier).state = true;
        }
        Get.to(() => ChatMessagesScreen(
              chatId: existingChat!.id,
              peerName: profile.displayName,
              peerImage: profile.avatarUrl,
            ));
        return;
      }

      final result = await getIt<CreateChatUseCase>().call(<String, dynamic>{
        'userId': currentUserId,
        'participantId': vendorId,
        'productId': product?.id,
      });
      if (!mounted) return;
      result.fold(
        (failure) {
          UIHelper.showGlobalSnackBar(
            text: 'Failed to create chat'.tr,
            color: AppColor.danger,
          );
        },
        (chat) {
          if (product != null) {
            ref.read(adContactedProvider(product.id).notifier).state = true;
          }
          Get.to(() => ChatMessagesScreen(
                chatId: chat.id,
                isNewChat: true,
                peerName: profile.displayName,
                peerImage: profile.avatarUrl,
              ));
        },
      );
    } catch (_) {
      if (!mounted) return;
      UIHelper.showGlobalSnackBar(
        text: 'Unable to start chat'.tr,
        color: AppColor.danger,
      );
    } finally {
      if (mounted) chatting.value = false;
    }
  }

  String? _fullPhone(String? phone, String? countryCode) {
    final raw = phone?.trim() ?? '';
    if (raw.isEmpty) return null;
    if (raw.startsWith('+') || raw.startsWith('00')) return raw;
    final code = (countryCode == null || countryCode.trim().isEmpty)
        ? '+966'
        : countryCode.trim().startsWith('+')
            ? countryCode.trim()
            : '+${countryCode.trim()}';
    if (raw.startsWith('0')) return '$code${raw.substring(1)}';
    return '$code$raw';
  }
}
