
class SubCategory {
  final int id;
  final String name;
  final String? description;
  final String? image;
  final MainCategoryInfo? mainCategory;

  SubCategory({
    required this.id,
    required this.name,
    this.description,
    this.image,
    this.mainCategory,
  });

  factory SubCategory.fromJson(Map<String, dynamic> json) {
    return SubCategory(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
      image: json['image'],
      mainCategory: json['main_category'] != null
          ? MainCategoryInfo.fromJson(json['main_category'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "description": description,
      "image": image,
      "main_category": mainCategory?.toJson(),
    };
  }
}

class MainCategoryInfo {
  final int id;
  final String name;

  MainCategoryInfo({
    required this.id,
    required this.name,
  });

  factory MainCategoryInfo.fromJson(Map<String, dynamic> json) {
    return MainCategoryInfo(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
    };
  }
}