class AdEntity {
  final String id;
  final String title;
  final String image;
  final String linkType;
  final String? linkId;
  final int order;
  final bool isActive;
  final String createdAt;
  final String updatedAt;
  final int v;

  AdEntity({
    required this.id,
    required this.title,
    required this.image,
    required this.linkType,
    this.linkId,
    required this.order,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  factory AdEntity.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return AdEntity(
        id: "",
        title: "",
        image: "",
        linkType: "none",
        linkId: null,
        order: 0,
        isActive: false,
        createdAt: "",
        updatedAt: "",
        v: 0,
      );
    }

    return AdEntity(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? "",
      title: json['title']?.toString() ?? "",
      image: json['image_url'] ?? json['image']?.toString() ?? "",
      linkType: json['linkType']?.toString() ?? "none",
      linkId: json['linkId']?.toString(),
      order: json['order'] is int
          ? json['order']
          : (int.tryParse(json['order']?.toString() ?? '0') ?? 0),
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt']?.toString() ?? "",
      updatedAt: json['updatedAt']?.toString() ?? "",
      v: json['__v'] is int
          ? json['__v']
          : (int.tryParse(json['__v']?.toString() ?? '0') ?? 0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'image': image,
      'linkType': linkType,
      'linkId': linkId,
      'order': order,
      'isActive': isActive,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      '__v': v,
    };
  }
}
