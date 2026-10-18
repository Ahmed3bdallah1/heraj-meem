import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/use_cases/use_case.dart';
import '../repo/chats_repo.dart';

class SendMessageUseCase extends UseCaseParam<void, Map<String, dynamic>> {
  final ChatsRepo chatsRepo;

  SendMessageUseCase(this.chatsRepo);

  @override
  Future<Either<Failure, void>> call(Map<String, dynamic> params) {
    return chatsRepo.sendMessage(
      params['chatId'] as String,
      params['content'] as String,
      attachments: params['attachments'] as List<String>?,
      productId: params['productId'] as String?,
    );
  }
}

