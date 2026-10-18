import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../main.dart';
import '../../domain/entities/chat_entity.dart';
import '../../domain/use_case/get_chats_use_case.dart';

final fetchChatsProvider = FutureProvider.autoDispose<List<ChatEntity>>((ref) async {
  final useCase = getIt<GetChatsUseCase>();
  final result = await useCase.call();
  return result.fold(
    (failure) => throw failure,
    (chats) => chats,
  );
});

