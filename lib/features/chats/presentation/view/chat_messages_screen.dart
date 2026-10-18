import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj_meem/config/app_font.dart';
import 'package:heraj_meem/core/service/local_data_manager.dart';
import 'package:heraj_meem/main.dart';
import 'package:heraj_meem/ui/shared_widgets/custom_image_circle.dart';
import 'package:heraj_meem/ui/shared_widgets/loading_widget.dart';
import 'package:heraj_meem/ui/ui.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/entities/chat_entity.dart';
import '../../domain/repo/chats_repo.dart';
import '../../domain/use_case/send_message_use_case.dart';
import '../../../../features/profile/domain/use_cases/upload_file_use_case.dart';
import '../managers/chat_messages_provider.dart';
import '../managers/chat_messages_state_provider.dart';
import '../managers/chats_provider.dart';
import 'widgets/message_bubble.dart';
import 'widgets/product_message_widget.dart';

class ChatMessagesScreen extends ConsumerStatefulWidget {
  final String chatId;
  final bool isNewChat;

  const ChatMessagesScreen({
    super.key,
    required this.chatId,
    this.isNewChat = false,
  });

  @override
  ConsumerState<ChatMessagesScreen> createState() => _ChatMessagesScreenState();
}

class _ChatMessagesScreenState extends ConsumerState<ChatMessagesScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _messageFocusNode = FocusNode();
  final ImagePicker _picker = ImagePicker();
  final int _limit = 50;

  @override
  void initState() {
    super.initState();
    _messageFocusNode.addListener(_onFocusChange);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Don't mark as read if this is a newly created chat
      if (!widget.isNewChat) {
        _markChatAsRead();
      }
      _loadMessages();
    });
  }

  void _markChatAsRead() async {
    try {
      final result = await getIt<ChatsRepo>().markChatAsRead(widget.chatId);
      result.fold(
        (failure) {
          if (kDebugMode) {
            print('Error marking chat as read: ${failure.message}');
          }
        },
        (_) {
          if (mounted) {
            ref.invalidate(fetchChatsProvider);
          }
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error in _markChatAsRead: $e');
      }
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _messageFocusNode.removeListener(_onFocusChange);
    _messageFocusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    ref
        .read(chatMessagesStateProvider(widget.chatId).notifier)
        .setTextFieldFocused(_messageFocusNode.hasFocus);
  }

  void _loadMessages({bool loadMore = false}) {
    final state = ref.read(chatMessagesStateProvider(widget.chatId));
    final stateNotifier =
        ref.read(chatMessagesStateProvider(widget.chatId).notifier);

    if (loadMore && (!state.hasMore || state.isLoadingMore)) return;

    final page = loadMore ? state.currentPage + 1 : 1;

    Future(() {
      if (loadMore) {
        stateNotifier.setLoadingMore(true);
      } else {
        stateNotifier.reset();
      }

      ref
          .read(fetchChatMessagesProvider({
        'chatId': widget.chatId,
        'page': page,
        'limit': _limit,
      }).future)
          .then((result) {
        if (mounted) {
          if (loadMore) {
            stateNotifier.addOlderMessages(result.messages.reversed.toList(),
                hasMore: result.pagination.hasMore);
          } else {
            stateNotifier.setMessages(result.messages.reversed.toList(),
                hasMore: result.pagination.hasMore);
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _scrollToBottom();
            });
          }
        }
      }).catchError((error) {
        if (mounted) {
          stateNotifier.setLoadingMore(false);
        }
      });
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage() async {
    final state = ref.read(chatMessagesStateProvider(widget.chatId));
    final stateNotifier =
        ref.read(chatMessagesStateProvider(widget.chatId).notifier);

    if (_messageController.text.trim().isEmpty && state.selectedImages.isEmpty && !state.isSending) return;

    final content = _messageController.text.trim();
    final imagesToSend = List<File>.from(state.selectedImages);

    _messageController.clear();
    stateNotifier.clearSelectedImages();
    stateNotifier.setSending(true);

    try {
      List<String> uploadedImageUrls = [];

      if (imagesToSend.isNotEmpty) {
        final uploadUseCase = getIt<UploadFileUseCase>();
        for (var imageFile in imagesToSend) {
          final uploadResult = await uploadUseCase.call(imageFile);
          uploadResult.fold(
            (failure) {
              throw Exception('Failed to upload image: ${failure.message}');
            },
            (uploadResponse) {
              uploadedImageUrls.add(uploadResponse.filePath);
            },
          );
        }
      }

      final useCase = getIt<SendMessageUseCase>();
      final result = await useCase.call({
        'chatId': widget.chatId,
        'content': content,
        'attachments': uploadedImageUrls.isNotEmpty ? uploadedImageUrls : null,
      });

      result.fold(
        (failure) {
          UIHelper.showGlobalSnackBar(
            text: 'Failed to send message'.tr,
            color: Colors.red,
          );
        },
        (_) {
          _loadMessages();
        },
      );
    } catch (e) {
      UIHelper.showGlobalSnackBar(
        text: 'Error: ${e.toString()}'.tr,
        color: Colors.red,
      );
    } finally {
      if (mounted) {
        stateNotifier.setSending(false);
      }
    }
  }

  Future<void> _pickImages() async {
    try {
      final pickedFiles = await _picker.pickMultiImage();
      if (pickedFiles.isEmpty) return;

      ref
          .read(chatMessagesStateProvider(widget.chatId).notifier)
          .addSelectedImages(
            pickedFiles.map((file) => File(file.path)).toList(),
          );
    } catch (e) {
      UIHelper.showGlobalSnackBar(
        text: 'Error picking images: ${e.toString()}'.tr,
        color: Colors.red,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = getIt<LocalDataManager>().getUser();
    final currentUserId = currentUser?.id.toString() ?? '';
    final state = ref.watch(chatMessagesStateProvider(widget.chatId));
    final chatsAsync = ref.watch(fetchChatsProvider);

    ChatEntity? chat;
    if (chatsAsync.valueOrNull != null) {
      try {
        chat = chatsAsync.valueOrNull!.firstWhere(
          (c) => c.id == widget.chatId,
        );
      } catch (e) {
        chat = null;
      }
    }
    final otherParticipant = chat?.getOtherParticipant(currentUserId);
    final otherUserInfo = otherParticipant?.userId;
    final displayName = otherUserInfo?.displayName ?? 'Chat'.tr;
    final displayImage = otherUserInfo?.displayImage ?? '';

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 50,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomImageCircle(
              image: displayImage,
              radius: 14,
            ),
            const Gap(10),
            Expanded(
              child: Text(
                displayName,
                style: AppFont.font15W500Black,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: state.messages.isEmpty
                ? const Center(child: LoadingWidget())
                : RefreshIndicator(
                    onRefresh: () async {
                      _loadMessages();
                    },
                    child: ListView.builder(
                      controller: _scrollController,
                      reverse: true,
                      padding: const EdgeInsets.all(16),
                      itemCount: state.messages.length +
                          (state.isLoadingMore ? 1 : 0) +
                          (state.hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == 0 &&
                            state.hasMore &&
                            !state.isLoadingMore) {
                          return Center(
                            child: TextButton(
                              onPressed: () => _loadMessages(loadMore: true),
                              child: Text('Load older messages'.tr),
                            ),
                          );
                        }
                        if (index == 0 && state.isLoadingMore) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: LoadingWidget(),
                            ),
                          );
                        }

                        final messageIndex = state.isLoadingMore
                            ? index - 1
                            : (state.hasMore ? index - 1 : index);
                        final message = state.messages[messageIndex];
                        final isMe = message.senderId.id == currentUserId;

                        bool showTime = true;
                        if (messageIndex > 0) {
                          final newerMessage = state.messages[messageIndex - 1];
                          final isFromSameSender =
                              newerMessage.senderId.id == message.senderId.id;
                          final timeDifference = message.createdAt
                              .difference(newerMessage.createdAt);
                          if (isFromSameSender &&
                              timeDifference.inMinutes < 2 &&
                              timeDifference.inSeconds >= 0) {
                            showTime = false;
                          }
                        }

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: message.type == MessageType.product
                              ? ProductMessageWidget(
                                  message: message,
                                  isMe: isMe,
                                  showTime: showTime,
                                )
                              : MessageBubble(
                                  message: message,
                                  isMe: isMe,
                                  showTime: showTime,
                                ),
                        );
                      },
                    ),
                  ),
          ),
          _buildMessageInput(state),
        ],
      ),
    );
  }

  Widget _buildMessageInput(ChatMessagesState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -2),
            blurRadius: 4,
            color: Colors.black.withAlpha(25),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        right: false,
        left: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (state.selectedImages.isNotEmpty)
              Container(
                height: 100,
                margin: const EdgeInsets.only(bottom: 8),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: state.selectedImages.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              state.selectedImages[index],
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () => ref
                                  .read(chatMessagesStateProvider(widget.chatId)
                                      .notifier)
                                  .removeSelectedImage(index),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.black.withAlpha(150),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                AnimatedOpacity(
                  opacity: state.isTextFieldFocused ? 0.0 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  child: AnimatedSize(
                    duration: const Duration(milliseconds: 200),
                    child: state.isTextFieldFocused
                        ? const SizedBox.shrink()
                        : IconButton(
                            icon: Icon(Icons.image, color: AppColor.primary),
                            onPressed: state.isSending ? null : _pickImages,
                          ),
                  ),
                ),
                Expanded(
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width - 150,
                      minHeight: 40,
                      maxHeight: !state.isTextFieldFocused
                          ? 60
                          : MediaQuery.of(context).size.width / 2,
                    ),
                    child: TextField(
                      controller: _messageController,
                      focusNode: _messageFocusNode,
                      decoration: InputDecoration(
                        hintText: 'Type a message...'.tr,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide:
                              BorderSide(color: AppColor.primary, width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                const Gap(8),
                IconButton(
                  icon: state.isSending
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(Icons.send, color: AppColor.primary),
                  onPressed: state.isSending ? null : _sendMessage,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
