class CreateAdRequest {
  final String categoryId;
  final String cityId;
  final String title;
  final String description;
  final num price;
  final bool showPhone;
  final List<String> mediaIds;
  final Map<String, dynamic> attributes;

  const CreateAdRequest({
    required this.categoryId,
    required this.cityId,
    required this.title,
    required this.description,
    required this.price,
    required this.showPhone,
    this.mediaIds = const [],
    this.attributes = const {},
  });

  factory CreateAdRequest.fromJson(Map<String, dynamic> json) {
    final media = json['mediaIds'];
    return CreateAdRequest(
      categoryId: json['categoryId']?.toString() ?? '',
      cityId: json['cityId']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      price: json['price'] is num
          ? json['price'] as num
          : num.tryParse(json['price']?.toString() ?? '') ?? 0,
      showPhone: json['showPhone'] != false,
      mediaIds: media is List
          ? media.map((item) => item.toString()).toList()
          : const [],
      attributes: json['attributes'] is Map
          ? Map<String, dynamic>.from(json['attributes'] as Map)
          : const {},
    );
  }

  Map<String, dynamic> toJson() => {
        'categoryId': categoryId,
        'cityId': cityId,
        'title': title,
        'description': description,
        'price': price,
        'showPhone': showPhone,
        'mediaIds': mediaIds,
        'attributes': attributes,
      };

  CreateAdRequest copyWith({List<String>? mediaIds}) {
    return CreateAdRequest(
      categoryId: categoryId,
      cityId: cityId,
      title: title,
      description: description,
      price: price,
      showPhone: showPhone,
      mediaIds: mediaIds ?? this.mediaIds,
      attributes: attributes,
    );
  }
}
