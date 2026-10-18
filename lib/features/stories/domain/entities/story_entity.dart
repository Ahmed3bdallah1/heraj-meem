class StoryEntity {
  final int id;
  final String userId;
  final String userName;
  final String userImageUrl;
  final List<StoryItemEntity> items;
  final DateTime createdAt;
  final bool isAdmin;

  StoryEntity({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userImageUrl,
    required this.items,
    required this.createdAt,
    this.isAdmin = false,
  });
}

class StoryItemEntity {
  final int id;
  final String storyId; // MongoDB _id for API calls
  final String mediaUrl;
  final StoryMediaType mediaType;
  final String? caption;
  final Duration duration;
  final String? linkType;
  final String? linkId;

  StoryItemEntity({
    required this.id,
    required this.storyId,
    required this.mediaUrl,
    required this.mediaType,
    this.caption,
    this.duration = const Duration(seconds: 5),
    this.linkType,
    this.linkId,
  });
}

enum StoryMediaType {
  image,
  video,
}
