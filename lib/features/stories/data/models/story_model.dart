import '../../domain/entities/story_entity.dart';

class StoryModel extends StoryEntity {
  StoryModel({
    required super.id,
    required super.userId,
    required super.userName,
    required super.userImageUrl,
    required super.items,
    required super.createdAt,
    super.isAdmin = false,
  });

  factory StoryModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return StoryModel(
        id: 0,
        userId: '',
        userName: '',
        userImageUrl: '',
        items: [],
        createdAt: DateTime.now(),
        isAdmin: false,
      );
    }

    // Handle new API structure (from home-data endpoint)
    if (json['vendorId'] != null) {
      final vendorId = json['vendorId']?.toString() ?? '';
      final vendorName = json['vendorName']?.toString() ??
          (json['vendorNameTr']?.toString() ??
              (json['vendorNameAr']?.toString() ?? ''));

      // Get stories array or use media array
      final storiesList = json['stories'] as List? ?? [];
      final mediaList = json['media'] as List? ?? [];

      // If stories array exists, use it; otherwise use media array
      final itemsList = storiesList.isNotEmpty ? storiesList : mediaList;

      // Get thumbnail or first media URL
      String thumbnail = json['thumbnail']?.toString() ?? '';
      if (thumbnail.isEmpty) {
        // Try to get from stories array first (vendor stories)
        if (storiesList.isNotEmpty) {
          final firstStory = storiesList[0];
          if (firstStory is Map<String, dynamic>) {
            // Check if media is an object (vendor stories)
            if (firstStory['media'] is Map<String, dynamic>) {
              thumbnail = firstStory['media']['url']?.toString() ?? '';
            }
            // Check if media is an array (admin stories)
            else if (firstStory['media'] is List && (firstStory['media'] as List).isNotEmpty) {
              final firstMedia = (firstStory['media'] as List)[0];
              if (firstMedia is Map) {
                thumbnail = firstMedia['url']?.toString() ?? '';
              }
            }
          }
        }
        // Fallback to mediaList
        if (thumbnail.isEmpty && mediaList.isNotEmpty) {
          final firstMedia = mediaList[0];
          if (firstMedia is Map) {
            thumbnail = firstMedia['url']?.toString() ?? '';
          }
        }
      }

      return StoryModel(
        id: () {
          final idStr = json['_id']?.toString() ?? '0';
          if (idStr.length >= 8) {
            return int.tryParse(idStr.substring(0, 8)) ?? 0;
          }
          return int.tryParse(idStr) ?? 0;
        }(),
        userId: vendorId,
        userName: vendorName,
        userImageUrl: thumbnail,
        isAdmin: json["isAdmin"] ?? false,
        items: itemsList
            .map((e) {
              if (e is Map<String, dynamic>) {
                // Handle story item with media array (admin stories)
                if (e['media'] != null && e['media'] is List) {
                  final storyId = e['_id']?.toString() ?? '';
                  return (e['media'] as List).map((media) {
                    return StoryItemModel.fromJson({
                      'id': media['_id'] ?? media['id'] ?? 0,
                      'story_id': storyId, // Use the story item's _id
                      'media_url': media['url'] ?? '',
                      'media_type': media['type'] ?? 'image',
                      'duration': media['duration'] ?? e['duration'] ?? 5,
                      'link_type': media['linkType'] ?? media['link_type'],
                      'link_id': media['linkId'] ?? media['link_id'],
                    });
                  }).toList();
                } 
                // Handle story item with media object (vendor stories)
                else if (e['media'] != null && e['media'] is Map<String, dynamic>) {
                  final media = e['media'] as Map<String, dynamic>;
                  return [
                    StoryItemModel.fromJson({
                      'id': e['_id'] ?? e['id'] ?? 0,
                      'story_id': e['_id']?.toString() ?? '', // Use the story item's _id
                      'media_url': media['url'] ?? '',
                      'media_type': media['type'] ?? 'image',
                      'duration': e['duration'] ?? media['duration'] ?? 5,
                      'link_type': media['linkType'] ?? media['link_type'],
                      'link_id': media['linkId'] ?? media['link_id'],
                    })
                  ];
                }
                // Handle direct media item (fallback)
                else {
                  return [
                    StoryItemModel.fromJson({
                      'id': e['_id'] ?? e['id'] ?? 0,
                      'story_id': e['_id']?.toString() ?? '',
                      'media_url': e['url'] ?? '',
                      'media_type': e['type'] ?? 'image',
                      'duration': e['duration'] ?? 5,
                    })
                  ];
                }
              }
              return <StoryItemModel>[];
            })
            .expand((list) => list)
            .toList(),
        createdAt: json['createdAt'] != null
            ? (DateTime.tryParse(json['createdAt']) ?? DateTime.now())
            : DateTime.now(),
      );
    }

    // Handle old API structure
    return StoryModel(
      id: json['id'] ?? 0,
      userId: json['user_id']?.toString() ?? '',
      userName: json['user_name']?.toString() ?? '',
      userImageUrl: json['user_image_url']?.toString() ?? '',
      items: (json['items'] as List<dynamic>?)
              ?.map((e) {
                final itemJson = e as Map<String, dynamic>?;
                if (itemJson != null) {
                  // Add story_id if not present
                  itemJson['story_id'] ??= itemJson['_id']?.toString() ?? '';
                }
                return StoryItemModel.fromJson(itemJson);
              })
              .toList() ??
          [],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at']) ?? DateTime.now()
          : DateTime.now(),
      isAdmin: json['isAdmin'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'user_name': userName,
      'user_image_url': userImageUrl,
      'items': items.map((e) => (e as StoryItemModel).toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class StoryItemModel extends StoryItemEntity {
  StoryItemModel({
    required super.id,
    required super.storyId,
    required super.mediaUrl,
    required super.mediaType,
    super.caption,
    super.duration,
    super.linkType,
    super.linkId,
  });

  factory StoryItemModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return StoryItemModel(
        id: 0,
        storyId: '',
        mediaUrl: '',
        mediaType: StoryMediaType.image,
      );
    }

    return StoryItemModel(
      id: json['id'] is int
          ? json['id']
          : (int.tryParse(
                  json['id']?.toString() ?? json['_id']?.toString() ?? '0') ??
              0),
      storyId: json['story_id']?.toString() ?? json['_id']?.toString() ?? '',
      mediaUrl: json['media_url']?.toString() ?? json['url']?.toString() ?? '',
      mediaType: (json['media_type']?.toString() ??
                  json['type']?.toString() ??
                  'image') ==
              'video'
          ? StoryMediaType.video
          : StoryMediaType.image,
      caption: json['caption']?.toString(),
      duration: json['duration'] != null
          ? Duration(
              seconds: json['duration'] is int
                  ? json['duration']
                  : (int.tryParse(json['duration']?.toString() ?? '5') ?? 5))
          : const Duration(seconds: 5),
      linkType: json['link_type']?.toString() ?? json['linkType']?.toString(),
      linkId: json['link_id']?.toString() ?? json['linkId']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'media_url': mediaUrl,
      'media_type': mediaType == StoryMediaType.video ? 'video' : 'image',
      'caption': caption,
      'duration': duration.inSeconds,
    };
  }
}
