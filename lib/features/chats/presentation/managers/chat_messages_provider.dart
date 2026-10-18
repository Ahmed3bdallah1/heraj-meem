import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../main.dart';
import '../../data/models/messages_paginated_model.dart';
import '../../domain/use_case/get_chat_messages_use_case.dart';

final fetchChatMessagesProvider = FutureProvider.autoDispose.family<MessagesPaginatedModel, Map<String, dynamic>>((ref, params) async {
  final useCase = getIt<GetChatMessagesUseCase>();
  final result = await useCase.call(params);
  return result.fold(
    (failure) => throw failure,
    (messages) => messages,
  );
});

