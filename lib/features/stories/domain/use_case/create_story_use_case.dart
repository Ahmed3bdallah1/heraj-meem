import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/use_cases/use_case.dart';
import '../repositories/stories_repo.dart';

class CreateStoryUseCase extends UseCaseParam<void, List<Map<String, dynamic>>> {
  final StoriesRepo storiesRepo;

  CreateStoryUseCase({required this.storiesRepo});

  @override
  Future<Either<Failure, void>> call(List<Map<String, dynamic>> param) async {
    return await storiesRepo.createStory(param);
  }
}

