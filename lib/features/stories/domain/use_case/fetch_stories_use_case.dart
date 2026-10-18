import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../entities/story_entity.dart';
import '../repositories/stories_repo.dart';

class FetchStoriesUseCase {
  final StoriesRepo storiesRepo;

  FetchStoriesUseCase({required this.storiesRepo});

  Future<Either<Failure, List<StoryEntity>>> call() async {
    return await storiesRepo.getStories();
  }
}

