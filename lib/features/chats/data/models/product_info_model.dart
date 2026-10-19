import '../../domain/entities/product_info_entity.dart';
import '../../domain/entities/user_info_entity.dart';

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
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      price: _price(json['price']),
      images: _images(json),
      category: _category(json['category']),
    );
  }

  static double _price(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static List<String> _images(Map<String, dynamic> json) {
    final images = json['images'];
    if (images is List && images.isNotEmpty) {
      return images
          .map((item) => item is Map ? item['url']?.toString() : item.toString())
          .map(chatMediaUrl)
          .where((url) => url.isNotEmpty)
          .toList();
    }
    final media = json['media'];
    if (media is List) {
      return media
          .whereType<Map>()
          .map((item) => chatMediaUrl(item['url']?.toString()))
          .where((url) => url.isNotEmpty)
          .toList();
    }
    return [];
  }

  static String _category(dynamic value) {
    if (value is Map) {
      return value['nameAr']?.toString() ??
          value['name']?.toString() ??
          value['nameEn']?.toString() ??
          '';
    }
    return value?.toString() ?? '';
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

