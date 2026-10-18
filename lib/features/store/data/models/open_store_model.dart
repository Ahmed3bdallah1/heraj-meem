import 'package:heraj/features/products/data/models/product_model.dart';

import '../../../categories/data/models/main_category_model.dart';
import '../../../home/domain/entities/ad_entity.dart';

class BannerItem {
  final String id;
  final String? image;
  final String? imageAr;
  final String? imageMobile;
  final String linkType;
  final String? linkId;
  final String position;
  final CategoryModel? associatedCategoryId;
  final int order;
  final bool isActive;
  final String createdAt;
  final String updatedAt;
  final int v;

  BannerItem({
    required this.id,
    this.image,
    this.imageAr,
    this.imageMobile,
    required this.linkType,
    this.linkId,
    required this.position,
    this.associatedCategoryId,
    required this.order,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  factory BannerItem.fromJson(Map<String, dynamic> json) {
    return BannerItem(
      id: json['_id']?.toString() ?? '',
      image: json['image']?.toString(),
      imageAr: json['imageAr']?.toString(),
      imageMobile: json['imageMobile']?.toString(),
      linkType: json['linkType']?.toString() ?? 'none',
      linkId: json['linkId']?.toString(),
      position: json['position']?.toString() ?? '',
      associatedCategoryId: json['associatedCategoryId'] != null &&
              json['associatedCategoryId'] is Map<String, dynamic>
          ? CategoryModel.fromJson(json['associatedCategoryId'])
          : null,
      order: json['order'] is int
          ? json['order']
          : (json['order'] as num?)?.toInt() ?? 0,
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt']?.toString() ?? '',
      updatedAt: json['updatedAt']?.toString() ?? '',
      v: json['__v'] is int ? json['__v'] : (json['__v'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'image': image,
      'imageAr': imageAr,
      'imageMobile': imageMobile,
      'linkType': linkType,
      'linkId': linkId,
      'position': position,
      'associatedCategoryId': associatedCategoryId?.toJson(),
      'order': order,
      'isActive': isActive,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      '__v': v,
    };
  }
}

class StorePageBanners {
  final List<BannerItem> top;
  final List<BannerItem> middle;
  final List<BannerItem> bottom;

  StorePageBanners({
    required this.top,
    required this.middle,
    required this.bottom,
  });

  factory StorePageBanners.fromJson(Map<String, dynamic> json) {
    return StorePageBanners(
      top: (json['top'] as List?)
              ?.map((item) =>
                  BannerItem.fromJson(item is Map<String, dynamic> ? item : {}))
              .toList() ??
          [],
      middle: (json['middle'] as List?)
              ?.map((item) =>
                  BannerItem.fromJson(item is Map<String, dynamic> ? item : {}))
              .toList() ??
          [],
      bottom: (json['bottom'] as List?)
              ?.map((item) =>
                  BannerItem.fromJson(item is Map<String, dynamic> ? item : {}))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'top': top.map((item) => item.toJson()).toList(),
      'middle': middle.map((item) => item.toJson()).toList(),
      'bottom': bottom.map((item) => item.toJson()).toList(),
    };
  }
}

class StorePageSection {
  final CategoryModel? category;
  final List<ProductModel> products;
  final BannerItem? banner;
  final Pagination? pagination;

  StorePageSection({
    this.category,
    this.products = const [],
    this.banner,
    this.pagination,
  });

  factory StorePageSection.fromJson(Map<String, dynamic> json) {
    return StorePageSection(
      category:
          json['category'] != null && json['category'] is Map<String, dynamic>
              ? CategoryModel.fromJson(json['category'])
              : null,
      products: json['products'] != null
          ? (json['products'] as List?)
                  ?.map((item) => ProductModel.fromJson(
                      item is Map<String, dynamic> ? item : {}))
                  .toList() ??
              []
          : [],
      banner: json['banner'] != null && json['banner'] is Map<String, dynamic>
          ? BannerItem.fromJson(json['banner'])
          : null,
      pagination: json['pagination'] != null &&
              json['pagination'] is Map<String, dynamic>
          ? Pagination.fromJson(json['pagination'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category?.toJson(),
      'products': products.map((item) => item.toJson()).toList(),
      'banner': banner?.toJson(),
      'pagination': pagination?.toJson(),
    };
  }
}

class OfferItem {
  final String id;
  final String? image;
  final String title;
  final String titleTr;
  final String titleAr;
  final String link;
  final String linkType;
  final bool isNew;
  final bool isActive;
  final int order;
  final String createdAt;
  final String updatedAt;
  final int v;

  OfferItem({
    required this.id,
    this.image,
    required this.title,
    required this.titleTr,
    required this.titleAr,
    required this.link,
    required this.linkType,
    required this.isNew,
    required this.isActive,
    required this.order,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  factory OfferItem.fromJson(Map<String, dynamic> json) {
    // Extract ID from URL if link is a full URL
    String extractedLink = '';
    final rawLink = json['link']?.toString() ?? '';
    if (rawLink.isNotEmpty) {
      if (rawLink.contains('/')) {
        // Extract the last segment after the last slash
        extractedLink = rawLink.split('/').last;
      } else {
        extractedLink = rawLink;
      }
    }

    return OfferItem(
      id: json['_id']?.toString() ?? '',
      image: json['image']?.toString(),
      title: json['title']?.toString() ?? '',
      titleTr: json['titleTr']?.toString() ?? '',
      titleAr: json['titleAr']?.toString() ?? '',
      link: extractedLink,
      linkType: json['linkType']?.toString() ?? 'category',
      isNew: json['isNew'] ?? false,
      isActive: json['isActive'] ?? true,
      order: json['order'] is int
          ? json['order']
          : (json['order'] as num?)?.toInt() ?? 0,
      createdAt: json['createdAt']?.toString() ?? '',
      updatedAt: json['updatedAt']?.toString() ?? '',
      v: json['__v'] is int ? json['__v'] : (json['__v'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'image': image,
      'title': title,
      'titleTr': titleTr,
      'titleAr': titleAr,
      'link': link,
      'linkType': linkType,
      'isNew': isNew,
      'isActive': isActive,
      'order': order,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      '__v': v,
    };
  }
}

class OpenStoreModel {
  final List<AdEntity> sliders;
  final List<CategoryModel> categories;
  final List<StorePageSection> sections;
  final StorePageBanners? banners;
  final StorePagination? pagination;
  final List<OfferItem> offers;

  OpenStoreModel({
    required this.sliders,
    required this.categories,
    required this.sections,
    this.banners,
    this.pagination,
    this.offers = const [],
  });

  factory OpenStoreModel.fromJson(Map<String, dynamic> json) {
    return OpenStoreModel(
      sliders: (json['sliders'] as List?)
              ?.map((item) =>
                  AdEntity.fromJson(item is Map<String, dynamic> ? item : {}))
              .toList() ??
          [],
      categories: (json['categories'] as List?)
              ?.map((item) => CategoryModel.fromJson(
                  item is Map<String, dynamic> ? item : {}))
              .toList() ??
          [],
      sections: (json['sections'] as List?)
              ?.map((item) => StorePageSection.fromJson(
                  item is Map<String, dynamic> ? item : {}))
              .toList() ??
          [],
      banners: json['banners'] != null
          ? StorePageBanners.fromJson(json['banners'])
          : null,
      pagination: json['pagination'] != null
          ? StorePagination.fromJson(json['pagination'])
          : null,
      offers: (json['offers'] as List?)
              ?.map((item) =>
                  OfferItem.fromJson(item is Map<String, dynamic> ? item : {}))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sliders': sliders.map((item) => item.toJson()).toList(),
      'categories': categories.map((item) => item.toJson()).toList(),
      'sections': sections.map((item) => item.toJson()).toList(),
      'banners': banners?.toJson(),
      'pagination': pagination?.toJson(),
      'offers': offers.map((item) => item.toJson()).toList(),
    };
  }
}

class StorePagination {
  final int page;
  final int limit;
  final int totalCategories;
  final bool hasMore;

  StorePagination({
    required this.page,
    required this.limit,
    required this.totalCategories,
    required this.hasMore,
  });

  factory StorePagination.fromJson(Map<String, dynamic> json) {
    return StorePagination(
      page: json['page'] is int
          ? json['page']
          : (int.tryParse(json['page']?.toString() ?? '0') ?? 0),
      limit: json['limit'] is int
          ? json['limit']
          : (int.tryParse(json['limit']?.toString() ?? '0') ?? 0),
      totalCategories: json['totalCategories'] is int
          ? json['totalCategories']
          : (int.tryParse(json['totalCategories']?.toString() ?? '0') ?? 0),
      hasMore: json['hasMore'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'limit': limit,
      'totalCategories': totalCategories,
      'hasMore': hasMore,
    };
  }
}

class BreadcrumbItem {
  final String id;
  final String name;
  final String nameAr;
  final String nameTr;
  final String slug;

  BreadcrumbItem({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.nameTr,
    required this.slug,
  });

  factory BreadcrumbItem.fromJson(Map<String, dynamic> json) {
    return BreadcrumbItem(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      nameAr: json['nameAr']?.toString() ?? '',
      nameTr: json['nameTr']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'nameAr': nameAr,
      'nameTr': nameTr,
      'slug': slug,
    };
  }
}

class StoreCategoryDetailsModel {
  final CategoryModel category;
  final List<CategoryModel> children;
  final List<BreadcrumbItem> breadcrumb;

  StoreCategoryDetailsModel({
    required this.category,
    required this.children,
    required this.breadcrumb,
  });

  factory StoreCategoryDetailsModel.fromJson(Map<String, dynamic> json) {
    return StoreCategoryDetailsModel(
      category: CategoryModel.fromJson(
          json['category'] is Map<String, dynamic> ? json['category'] : {}),
      children: (json['children'] as List?)
              ?.map((item) => CategoryModel.fromJson(item))
              .toList() ??
          [],
      breadcrumb: (json['breadcrumb'] as List?)
              ?.map((item) => BreadcrumbItem.fromJson(
                  item is Map<String, dynamic> ? item : {}))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category.toJson(),
      'children': children.map((item) => item.toJson()).toList(),
      'breadcrumb': breadcrumb.map((item) => item.toJson()).toList(),
    };
  }
}
