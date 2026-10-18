import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/story_entity.dart';
import '../../domain/repositories/stories_repo.dart';
import '../data_source/stories_data_source.dart';

class StoriesRepoImp implements StoriesRepo {
  final StoriesDataSource storiesDataSource;

  StoriesRepoImp({required this.storiesDataSource});

  @override
  Future<Either<Failure, List<StoryEntity>>> getStories() async {
    try {
      final stories = await storiesDataSource.getStories();
      return Right(stories);
    } catch (e) {
      if(e is DioException){
        return Left(ServerFailure.fromDioError(e));
      }
      return Left(GeneralError(e));
    }
  }

  @override
  Future<Either<Failure, void>> viewStory(String storyId) async {
    try {
      await storiesDataSource.viewStory(storyId);
      return const Right(null);
    } catch (e) {
      if(e is DioException){
        return Left(ServerFailure.fromDioError(e));
      }
      return Left(GeneralError(e));
    }
  }

  @override
  Future<Either<Failure, void>> createStory(List<Map<String, dynamic>> media) async {
    try {
      await storiesDataSource.createStory(media);
      return const Right(null);
    } catch (e) {
      if(e is DioException){
        return Left(ServerFailure.fromDioError(e));
      }
      return Left(GeneralError(e));
    }
  }
}

