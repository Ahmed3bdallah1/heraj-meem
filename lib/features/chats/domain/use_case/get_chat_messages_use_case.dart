import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/use_cases/use_case.dart';
import '../../data/models/messages_paginated_model.dart';
import '../repo/chats_repo.dart';

class GetChatMessagesUseCase extends UseCaseParam<MessagesPaginatedModel, Map<String, dynamic>> {
  final ChatsRepo chatsRepo;

  GetChatMessagesUseCase(this.chatsRepo);

  @override
  Future<Either<Failure, MessagesPaginatedModel>> call(Map<String, dynamic> params) {
    return chatsRepo.getChatMessages(
      params['chatId'] as String,
      page: params['page'] as int? ?? 1,
      limit: params['limit'] as int? ?? 50,
    );
  }
}

