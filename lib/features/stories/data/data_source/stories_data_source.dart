import '../../../../config/api_path.dart';
import '../../../../core/service/webservice/dio_helper.dart';
import '../../domain/entities/story_entity.dart';
import '../models/story_model.dart';

abstract class StoriesDataSource {
  Future<List<StoryEntity>> getStories();
  Future<void> viewStory(String storyId);
  Future<void> createStory(List<Map<String, dynamic>> media);
}

class StoriesDataSourceImpl extends StoriesDataSource {
  final ApiService apiService;

  StoriesDataSourceImpl({required this.apiService});

  @override
  Future<void> viewStory(String storyId) async {
    await apiService.post(
      url: ApiPath.viewStory(storyId),
      returnDataOnly: false,
    );
  }

  @override
  Future<void> createStory(List<Map<String, dynamic>> media) async {
    await apiService.post(
      url: ApiPath.createStory,
      requestBody: {'media': media},
      returnDataOnly: false,
    );
  }

  @override
  Future<List<StoryEntity>> getStories() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Return dummy stories with combination of images and videos
    return [
      StoryModel(
        id: 1,
        userId: '1',
        userName: 'John Doe',
        userImageUrl: 'https://i.pravatar.cc/150?img=1',
        items: [
          StoryItemModel(
            id: 1,
            storyId: '1',
            mediaUrl: 'https://picsum.photos/400/800?random=1',
            mediaType: StoryMediaType.image,
            caption: 'Beautiful sunset today! 🌅',
          ),
          StoryItemModel(
            id: 2,
            storyId: '2',
            mediaUrl:
                'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
            mediaType: StoryMediaType.video,
            caption: 'Check out this amazing video!',
            duration: const Duration(seconds: 10),
          ),
          StoryItemModel(
            id: 3,
            storyId: '3',
            mediaUrl: 'https://picsum.photos/400/800?random=2',
            mediaType: StoryMediaType.image,
            caption: 'New product launch coming soon!',
          ),
        ],
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      StoryModel(
        id: 2,
        userId: '2',
        userName: 'Jane Smith',
        userImageUrl: 'https://i.pravatar.cc/150?img=2',
        items: [
          StoryItemModel(
            id: 4,
            storyId: '4',
            mediaUrl:
                'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
            mediaType: StoryMediaType.video,
            caption: 'Amazing wildlife video!',
            duration: const Duration(seconds: 15),
          ),
          StoryItemModel(
            id: 5,
            storyId: '5',
            mediaUrl: 'https://picsum.photos/400/800?random=3',
            mediaType: StoryMediaType.image,
            caption: 'Check out our latest collection!',
          ),
        ],
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      StoryModel(
        id: 3,
        userId: '3',
        userName: 'Mike Johnson',
        userImageUrl: 'https://i.pravatar.cc/150?img=3',
        items: [
          StoryItemModel(
            id: 6,
            storyId: '6',
            mediaUrl: 'https://picsum.photos/400/800?random=4',
            mediaType: StoryMediaType.image,
            caption: 'Special offer this week! 🎉',
          ),
          StoryItemModel(
            id: 7,
            storyId: '7',
            mediaUrl:
                'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
            mediaType: StoryMediaType.video,
            caption: 'Watch this exciting video!',
            duration: const Duration(seconds: 12),
          ),
          StoryItemModel(
            id: 8,
            storyId: '8',
            mediaUrl: 'https://picsum.photos/400/800?random=5',
            mediaType: StoryMediaType.image,
            caption: 'Don\'t miss out!',
          ),
        ],
        createdAt: DateTime.now().subtract(const Duration(hours: 8)),
      ),
      StoryModel(
        id: 4,
        userId: '4',
        userName: 'Sarah Williams',
        userImageUrl: 'https://i.pravatar.cc/150?img=4',
        items: [
          StoryItemModel(
            id: 9,
            storyId: '9',
            mediaUrl: 'https://picsum.photos/400/800?random=6',
            mediaType: StoryMediaType.image,
            caption: 'New arrivals in store!',
          ),
          StoryItemModel(
            id: 10,
            storyId: '10',
            mediaUrl:
                'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
            mediaType: StoryMediaType.video,
            caption: 'Amazing travel video!',
            duration: const Duration(seconds: 8),
          ),
        ],
        createdAt: DateTime.now().subtract(const Duration(hours: 12)),
      ),
      StoryModel(
        id: 5,
        userId: '5',
        userName: 'David Brown',
        userImageUrl: 'https://i.pravatar.cc/150?img=5',
        items: [
          StoryItemModel(
            id: 11,
            storyId: '11',
            mediaUrl: 'https://picsum.photos/400/800?random=7',
            mediaType: StoryMediaType.image,
            caption: 'Limited time offer! ⏰',
          ),
          StoryItemModel(
            id: 12,
            storyId: '12',
            mediaUrl:
                'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4',
            mediaType: StoryMediaType.video,
            caption: 'Fun times ahead!',
            duration: const Duration(seconds: 10),
          ),
          StoryItemModel(
            id: 13,
            storyId: '13',
            mediaUrl: 'https://picsum.photos/400/800?random=8',
            mediaType: StoryMediaType.image,
            caption: 'Shop now and save!',
          ),
        ],
        createdAt: DateTime.now().subtract(const Duration(hours: 15)),
      ),
    ];
  }
}
