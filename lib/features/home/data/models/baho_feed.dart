import 'package:heraj_meem/config/api_path.dart';
import 'package:heraj_meem/features/categories/data/models/main_category_model.dart';

String bahoMediaUrl(String? path) {
  if (path == null || path.isEmpty) return '';
  if (path.startsWith('http')) return path;
  final normalized = path.startsWith('/') ? path : '/$path';
  return '${ApiPath.serverUrl}$normalized';
}

class BahoCategory {
  final String id;
  final String slug;
  final String nameAr;
  final String nameEn;
  final String? imageUrl;
  final List<BahoCategory> children;

  const BahoCategory({
    required this.id,
    required this.slug,
    required this.nameAr,
    required this.nameEn,
    this.imageUrl,
    this.children = const [],
  });

  factory BahoCategory.fromJson(Map<String, dynamic> json) {
    final rawChildren = json['children'];
    return BahoCategory(
      id: json['id']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      nameAr: json['nameAr']?.toString() ?? '',
      nameEn: json['nameEn']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString(),
      children: rawChildren is List
          ? rawChildren
              .whereType<Map>()
              .map((item) =>
                  BahoCategory.fromJson(Map<String, dynamic>.from(item)))
              .toList()
          : const [],
    );
  }

  String nameFor(String languageCode) =>
      languageCode == 'ar' ? nameAr : (nameEn.isEmpty ? nameAr : nameEn);

  CategoryModel toCategoryModel() {
    final photo = bahoMediaUrl(imageUrl);
    return CategoryModel(
      id: slug.isNotEmpty ? slug : id,
      name: nameEn.isEmpty ? nameAr : nameEn,
      nameTr: nameEn,
      nameAr: nameAr,
      slug: slug,
      image: photo.isEmpty ? null : photo,
      level: 0,
      order: 0,
      isActive: true,
      createdAt: '',
      updatedAt: '',
      v: 0,
      children: children.map((child) => child.toCategoryModel()).toList(),
    );
  }

  List<BahoCategory> get gridChildren {
    if (children.isEmpty) return const [];
    final withImages = children
        .where((child) => child.imageUrl != null && child.imageUrl!.isNotEmpty)
        .toList();
    return withImages.isNotEmpty ? withImages : children;
  }
}

class BahoAd {
  final String id;
  final String title;
  final String price;
  final String currency;
  final String? imageUrl;
  final String cityName;
  final String categoryName;
  final bool isFeatured;

  const BahoAd({
    required this.id,
    required this.title,
    required this.price,
    required this.currency,
    this.imageUrl,
    required this.cityName,
    required this.categoryName,
    required this.isFeatured,
  });

  bool get hasListedPrice {
    final value = num.tryParse(price.replaceAll(',', '').trim());
    return value != null && value > 0;
  }

  String get formattedPrice {
    final value = num.tryParse(price.replaceAll(',', ''));
    if (value == null || value <= 0) return '';
    final whole = value.truncate().toString();
    final grouped = whole.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => ',',
    );
    return grouped;
  }

  factory BahoAd.fromJson(Map<String, dynamic> json) {
    final media = json['media'];
    String? image;
    if (media is List && media.isNotEmpty && media.first is Map) {
      final first = Map<String, dynamic>.from(media.first as Map);
      image = bahoMediaUrl(first['thumbUrl']?.toString() ?? first['url']?.toString());
    }
    final city = json['city'] is Map
        ? Map<String, dynamic>.from(json['city'] as Map)
        : null;
    final category = json['category'] is Map
        ? Map<String, dynamic>.from(json['category'] as Map)
        : null;
    return BahoAd(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      price: json['price']?.toString() ?? '',
      currency: json['currency']?.toString() ?? 'SAR',
      imageUrl: image,
      cityName: city?['nameAr']?.toString() ?? '',
      categoryName: category?['nameAr']?.toString() ?? '',
      isFeatured: json['isFeatured'] == true,
    );
  }
}

class BahoCity {
  final String id;
  final String regionId;
  final String nameAr;
  final String nameEn;
  final String slug;

  const BahoCity({
    required this.id,
    required this.regionId,
    required this.nameAr,
    required this.nameEn,
    required this.slug,
  });

  factory BahoCity.fromJson(Map<String, dynamic> json) {
    return BahoCity(
      id: json['id']?.toString() ?? '',
      regionId: json['regionId']?.toString() ?? '',
      nameAr: json['nameAr']?.toString() ?? '',
      nameEn: json['nameEn']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
    );
  }
}

class BahoRegion {
  final String id;
  final String nameAr;
  final String nameEn;
  final String slug;
  final List<BahoCity> cities;

  const BahoRegion({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.slug,
    required this.cities,
  });

  factory BahoRegion.fromJson(Map<String, dynamic> json) {
    final rawCities = json['cities'];
    return BahoRegion(
      id: json['id']?.toString() ?? '',
      nameAr: json['nameAr']?.toString() ?? '',
      nameEn: json['nameEn']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      cities: rawCities is List
          ? rawCities
              .whereType<Map>()
              .map((item) => BahoCity.fromJson(Map<String, dynamic>.from(item)))
              .toList()
          : const [],
    );
  }
}

class BahoDistrict {
  final String id;
  final String nameAr;
  final String nameEn;

  const BahoDistrict({
    required this.id,
    required this.nameAr,
    required this.nameEn,
  });

  factory BahoDistrict.fromJson(Map<String, dynamic> json) {
    return BahoDistrict(
      id: json['id']?.toString() ?? '',
      nameAr: json['nameAr']?.toString() ?? json['name']?.toString() ?? '',
      nameEn: json['nameEn']?.toString() ?? '',
    );
  }
}

class BahoPlace {
  final String regionId;
  final String regionName;
  final String cityId;
  final String cityName;
  final String citySlug;

  const BahoPlace({
    required this.regionId,
    required this.regionName,
    required this.cityId,
    required this.cityName,
    required this.citySlug,
  });
}
