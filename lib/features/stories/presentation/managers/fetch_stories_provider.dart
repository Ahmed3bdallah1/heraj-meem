import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../main.dart';
import '../../domain/entities/story_entity.dart';
import '../../domain/use_case/fetch_stories_use_case.dart';

final fetchStoriesProvider =
    FutureProvider.autoDispose<List<StoryEntity>>((ref) async {
  final stories = await getIt<FetchStoriesUseCase>().call();

  return stories.fold((l) {
    throw l;
  }, (r) {
    return r;
  });
});

