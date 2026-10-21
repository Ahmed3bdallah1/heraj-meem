class CreateAdRequest {
  final String categoryId;
  final String cityId;
  final String title;
  final String description;
  final num price;
  final bool showPhone;
  final List<String> imagePaths;
  final List<Map<String, String>> attributes;

  const CreateAdRequest({
    required this.categoryId,
    required this.cityId,
    required this.title,
    required this.description,
    required this.price,
    required this.showPhone,
    this.imagePaths = const [],
    this.attributes = const [],
  });

  factory CreateAdRequest.fromJson(Map<String, dynamic> json) {
    final images = json['imagePaths'] ?? json['images'];
    return CreateAdRequest(
      categoryId: json['categoryId']?.toString() ?? '',
      cityId: json['cityId']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      price: json['price'] is num
          ? json['price'] as num
          : num.tryParse(json['price']?.toString() ?? '') ?? 0,
      showPhone: json['showPhone'] == true || json['showPhone'] == 'true',
      imagePaths: images is List
          ? images.map((item) => item.toString()).toList()
          : const [],
      attributes: _attributeList(json['attributes']),
    );
  }

  Map<String, dynamic> toJson() => {
        'categoryId': categoryId,
        'cityId': cityId,
        'title': title,
        'description': description,
        'price': price,
        'showPhone': showPhone,
        'images': imagePaths,
        'attributes': attributes,
      };

  CreateAdRequest copyWith({
    List<String>? imagePaths,
    List<Map<String, String>>? attributes,
  }) {
    return CreateAdRequest(
      categoryId: categoryId,
      cityId: cityId,
      title: title,
      description: description,
      price: price,
      showPhone: showPhone,
      imagePaths: imagePaths ?? this.imagePaths,
      attributes: attributes ?? this.attributes,
    );
  }
}

List<Map<String, String>> _attributeList(dynamic raw) {
  if (raw is List) {
    return raw.whereType<Map>().map((item) {
      return item.map(
        (key, value) => MapEntry(key.toString(), value.toString()),
      );
    }).toList();
  }
  if (raw is Map) {
    return raw.entries
        .map((entry) => {entry.key.toString(): entry.value.toString()})
        .toList();
  }
  return const [];
}
