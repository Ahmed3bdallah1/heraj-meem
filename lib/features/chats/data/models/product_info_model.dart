import '../../domain/entities/product_info_entity.dart';

class ProductInfoModel extends ProductInfoEntity {
  ProductInfoModel({
    required super.id,
    required super.title,
    required super.price,
    required super.images,
    required super.category,
  });

  factory ProductInfoModel.fromJson(Map<String, dynamic> json) {
    return ProductInfoModel(
      id: json['_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      category: json['category']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'price': price,
      'images': images,
      'category': category,
    };
  }
}

