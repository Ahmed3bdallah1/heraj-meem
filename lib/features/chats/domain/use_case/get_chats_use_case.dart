import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/use_cases/use_case.dart';
import '../entities/chat_entity.dart';
import '../repo/chats_repo.dart';

class GetChatsUseCase extends UseCaseNoParam<List<ChatEntity>> {
  final ChatsRepo chatsRepo;

  GetChatsUseCase(this.chatsRepo);

  @override
  Future<Either<Failure, List<ChatEntity>>> call() {
    return chatsRepo.getChats();
  }
}

