import '../../../store/data/models/open_store_model.dart';

class CategoryModel {
  final String id;
  final String name;
  final String nameTr;
  final String nameAr;
  final String slug;
  final String? image;
  final String? icon;
  final ParentCategory? parentId;
  final int level;
  final int order;
  final bool isActive;
  final String createdAt;
  final String updatedAt;
  final int v;
  final List<CategoryModel> children;

  CategoryModel({
    required this.id,
    required this.name,
    required this.nameTr,
    required this.nameAr,
    required this.slug,
    this.image,
    this.icon,
    this.parentId,
    required this.level,
    required this.order,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
    this.children = const [],
  });

  factory CategoryModel.fromOffer(OfferItem offer) {
    return CategoryModel(
      id: offer.link,
      name: offer.title,
      nameTr: offer.titleTr,
      nameAr: offer.titleAr,
      slug: '',
      image: offer.image,
      icon: offer.image,
      v: offer.v,
      isActive: true,
      order: offer.order,
      level: 0,
      createdAt: '',
      updatedAt: '',
    );
  }


  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      nameTr: json['nameTr']?.toString() ?? '',
      nameAr: json['nameAr']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      image: json['image']?.toString(),
      icon: json['icon']?.toString(),
      parentId:
          json['parentId'] != null && json['parentId'] is Map<String, dynamic>
              ? ParentCategory.fromJson(json['parentId'])
              : null,
      level: json['level'] is int
          ? json['level']
          : (int.tryParse(json['level']?.toString() ?? '0') ?? 0),
      order: json['order'] is int
          ? json['order']
          : (int.tryParse(json['order']?.toString() ?? '0') ?? 0),
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt']?.toString() ?? '',
      updatedAt: json['updatedAt']?.toString() ?? '',
      v: json['__v'] is int
          ? json['__v']
          : (int.tryParse(json['__v']?.toString() ?? '0') ?? 0),
      children: (json['children'] as List?)
              ?.map((item) => CategoryModel.fromJson(
                  item is Map<String, dynamic> ? item : {}))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "name": name,
      "nameTr": nameTr,
      "nameAr": nameAr,
      "slug": slug,
      "image": image,
      "icon": icon,
      "parentId": parentId?.toJson(),
      "level": level,
      "order": order,
      "isActive": isActive,
      "createdAt": createdAt,
      "updatedAt": updatedAt,
      "__v": v,
      "children": children.map((item) => item.toJson()).toList(),
    };
  }
}

class ParentCategory {
  final String id;
  final String name;
  final String slug;
  final int level;

  ParentCategory({
    required this.id,
    required this.name,
    required this.slug,
    required this.level,
  });

  factory ParentCategory.fromJson(Map<String, dynamic> json) {
    return ParentCategory(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      level: json['level'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "name": name,
      "slug": slug,
      "level": level,
    };
  }
}
