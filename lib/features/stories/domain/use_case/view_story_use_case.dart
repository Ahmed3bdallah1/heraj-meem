import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/use_cases/use_case.dart';
import '../repositories/stories_repo.dart';

class ViewStoryUseCase extends UseCaseParam<void, String> {
  final StoriesRepo storiesRepo;

  ViewStoryUseCase(this.storiesRepo);

  @override
  Future<Either<Failure, void>> call(String storyId) {
    return storiesRepo.viewStory(storyId);
  }
}

