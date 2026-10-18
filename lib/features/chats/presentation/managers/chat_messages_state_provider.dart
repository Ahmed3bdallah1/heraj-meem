import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/message_entity.dart';

class ChatMessagesState {
  final List<MessageEntity> messages;
  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;
  final bool isSending;
  final List<File> selectedImages;
  final bool isTextFieldFocused;

  ChatMessagesState({
    required this.messages,
    this.currentPage = 1,
    this.hasMore = true,
    this.isLoadingMore = false,
    this.isSending = false,
    this.selectedImages = const [],
    this.isTextFieldFocused = false,
  });

  ChatMessagesState copyWith({
    List<MessageEntity>? messages,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,
    bool? isSending,
    List<File>? selectedImages,
    bool? isTextFieldFocused,
  }) {
    return ChatMessagesState(
      messages: messages ?? this.messages,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isSending: isSending ?? this.isSending,
      selectedImages: selectedImages ?? this.selectedImages,
      isTextFieldFocused: isTextFieldFocused ?? this.isTextFieldFocused,
    );
  }
}

final chatMessagesStateProvider = StateNotifierProvider.autoDispose.family<ChatMessagesStateNotifier, ChatMessagesState, String>((ref, chatId) {
  return ChatMessagesStateNotifier(chatId);
});

class ChatMessagesStateNotifier extends StateNotifier<ChatMessagesState> {
  final String chatId;

  ChatMessagesStateNotifier(this.chatId) : super(ChatMessagesState(messages: []));

  void setMessages(List<MessageEntity> messages, {bool hasMore = true}) {
    state = state.copyWith(
      messages: messages,
      hasMore: hasMore,
      isLoadingMore: false,
    );
  }

  void addOlderMessages(List<MessageEntity> olderMessages, {bool hasMore = true}) {
    state = state.copyWith(
      messages: [...olderMessages, ...state.messages],
      hasMore: hasMore,
      isLoadingMore: false,
      currentPage: state.currentPage + 1,
    );
  }

  void setLoadingMore(bool isLoading) {
    state = state.copyWith(isLoadingMore: isLoading);
  }

  void setSending(bool isSending) {
    state = state.copyWith(isSending: isSending);
  }

  void addSelectedImages(List<File> images) {
    state = state.copyWith(
      selectedImages: [...state.selectedImages, ...images],
    );
  }

  void removeSelectedImage(int index) {
    final newImages = List<File>.from(state.selectedImages);
    newImages.removeAt(index);
    state = state.copyWith(selectedImages: newImages);
  }

  void clearSelectedImages() {
    state = state.copyWith(selectedImages: []);
  }

  void setTextFieldFocused(bool focused) {
    state = state.copyWith(isTextFieldFocused: focused);
  }

  void reset() {
    state = ChatMessagesState(messages: []);
  }
}

