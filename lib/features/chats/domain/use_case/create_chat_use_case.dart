import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/use_cases/use_case.dart';
import '../entities/chat_entity.dart';
import '../repo/chats_repo.dart';

class CreateChatUseCase extends UseCaseParam<ChatEntity, Map<String, dynamic>> {
  final ChatsRepo chatsRepo;

  CreateChatUseCase(this.chatsRepo);

  @override
  Future<Either<Failure, ChatEntity>> call(Map<String, dynamic> params) {
    return chatsRepo.createChat(
      userId: params['userId'] as String,
      participantId: params['participantId'] as String,
      productId: params['productId'] as String?,
    );
  }
}

