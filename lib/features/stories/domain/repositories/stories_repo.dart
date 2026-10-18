import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../entities/story_entity.dart';

abstract class StoriesRepo {
  Future<Either<Failure, List<StoryEntity>>> getStories();
  Future<Either<Failure, void>> viewStory(String storyId);
  Future<Either<Failure, void>> createStory(List<Map<String, dynamic>> media);
}

