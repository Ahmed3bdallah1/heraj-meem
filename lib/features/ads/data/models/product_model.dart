import 'package:heraj_meem/config/api_path.dart';
import 'package:heraj_meem/features/ads/data/models/product_details_model.dart';

class ProductPaginatedModel {
  final bool success;
  final List<ProductModel> data;
  final Pagination? pagination;
  final Meta? meta;

  ProductPaginatedModel({
    required this.success,
    required this.data,
    this.pagination,
    this.meta,
  });

  factory ProductPaginatedModel.fromJson(Map<String, dynamic> json) {
    List<ProductModel> productsList = [];
    Pagination? paginationData;

    final dataValue = json['data'];
    if (dataValue is List) {
      productsList = dataValue
          .map((item) {
            try {
              return ProductModel.fromJson(
                  item is Map<String, dynamic> ? item : {});
            } catch (e) {
              // Skip products that fail to parse
              return null;
            }
          })
          .whereType<ProductModel>()
          .toList();
      paginationData = json['pagination'] != null &&
              json['pagination'] is Map<String, dynamic>
          ? Pagination.fromJson(json['pagination'])
          : null;
    } else if (dataValue is Map<String, dynamic>) {
      final rawList = dataValue['items'] ?? dataValue['products'];
      productsList = (rawList as List?)
              ?.map((item) {
                try {
                  return ProductModel.fromJson(
                      item is Map<String, dynamic> ? item : {});
                } catch (e) {
                  // Skip products that fail to parse
                  return null;
                }
              })
              .whereType<ProductModel>()
              .toList() ??
          [];
      paginationData = dataValue['pagination'] != null &&
              dataValue['pagination'] is Map<String, dynamic>
          ? Pagination.fromJson(dataValue['pagination'])
          : null;
    }

    return ProductPaginatedModel(
      success: json['success'] ?? true,
      data: productsList,
      pagination: paginationData,
      meta: json['meta'] != null && json['meta'] is Map<String, dynamic>
          ? Meta.fromJson(json['meta'])
          : null,
    );
  }
}

class ProductModel {
  final String id;
  final String name;
  final String sku;
  final String? afterPrice;
  final String? beforePrice;
  final String? description;
  final bool isFeatured;
  final String? thumbImage;
  final Category? category;
  final bool isFavorite;
  final String? averageRating;
  final DeliveryInfo? deliveryInfo;
  final Warranty? warranty;
  final Location? location;
  final Rating? rating;
  final String productType;
  final String? titleTr;
  final String? titleAr;
  final String? descriptionTr;
  final String? descriptionAr;
  final double? price;

  bool get hasListedPrice => price != null && price! > 0;
  final double? compareAtPrice;
  final List<String> images;
  final String? adminCategory;
  final List<String> badges;
  final String status;
  final int stock;
  final List<dynamic> variants;
  final List<dynamic> variantCombinations;
  final bool isFeaturedDeal;
  final int views;
  final String? approvedAt;
  final String? approvedBy;
  final List<dynamic> specifications;
  final List<PriceHistory> priceHistory;
  final String createdAt;
  final String updatedAt;
  final int v;
  final String? sellerId;
  final String? sellerPhone;
  final VendorInfo? vendorId;
  final String? condition;
  final Map<String, dynamic>? categorySpecificFields;

  ProductModel({
    required this.id,
    required this.name,
    required this.sku,
    this.afterPrice,
    this.beforePrice,
    this.description,
    required this.isFeatured,
    this.thumbImage,
    this.category,
    required this.isFavorite,
    this.averageRating,
    this.deliveryInfo,
    this.warranty,
    this.location,
    this.rating,
    required this.productType,
    this.titleTr,
    this.titleAr,
    this.descriptionTr,
    this.descriptionAr,
    this.price,
    this.compareAtPrice,
    required this.images,
    this.adminCategory,
    required this.badges,
    required this.status,
    required this.stock,
    required this.variants,
    required this.variantCombinations,
    required this.isFeaturedDeal,
    required this.views,
    this.approvedAt,
    this.approvedBy,
    required this.specifications,
    required this.priceHistory,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
    this.sellerId,
    this.sellerPhone,
    this.vendorId,
    this.condition,
    this.categorySpecificFields,
  });

  static Location? _locationFromAd(Map<String, dynamic> json) {
    if (json['location'] is Map) {
      return Location.fromJson(Map<String, dynamic>.from(json['location'] as Map));
    }
    if (json['city'] is! Map) return null;
    final city = Map<String, dynamic>.from(json['city'] as Map);
    final district = json['district'] is Map
        ? Map<String, dynamic>.from(json['district'] as Map)
        : null;
    final cityName = city['nameAr']?.toString() ?? city['nameEn']?.toString();
    final districtName =
        district?['nameAr']?.toString() ?? district?['nameEn']?.toString();
    return Location(
      city: cityName,
      district: districtName,
      neighborhood: [districtName, cityName]
          .whereType<String>()
          .where((part) => part.isNotEmpty)
          .join(' · '),
    );
  }

  static String? _sellerId(Map<String, dynamic> json, Map<String, dynamic>? user) {
    final raw = json['sellerId'];
    if (raw is String && raw.isNotEmpty) return raw;
    if (raw is Map) {
      return raw['id']?.toString() ?? raw['_id']?.toString();
    }
    return user?['id']?.toString();
  }

  static String? _sellerPhone(
      Map<String, dynamic> json, Map<String, dynamic>? user) {
    final phone = json['sellerPhone']?.toString();
    if (phone != null && phone.isNotEmpty) return phone;
    if (json['showPhone'] == false) return null;
    return user?['phone']?.toString();
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final id = json['_id']?.toString() ?? json['id']?.toString() ?? '';

    final price = json['price'] ?? json['after_price'];
    final priceNumber = price is num
        ? price.toDouble()
        : double.tryParse(price?.toString().replaceAll(',', '') ?? '');
    final listedPrice = priceNumber != null && priceNumber > 0
        ? priceNumber
        : null;
    final comparePrice = json['compareAtPrice'];
    final afterPrice = listedPrice?.toString();
    final beforePrice = comparePrice != null
        ? comparePrice.toString()
        : (json['before_price']?.toString() ?? '0.0');

    final imagesList = json['images'] as List?;
    final images = imagesList?.map((e) => e.toString()).toList() ?? [];
    if (images.isEmpty && json['media'] is List) {
      for (final item in (json['media'] as List).whereType<Map>()) {
        final raw = item['url']?.toString() ?? item['thumbUrl']?.toString() ?? '';
        if (raw.isEmpty) continue;
        images.add(raw.startsWith('http')
            ? raw
            : '${ApiPath.serverUrl}${raw.startsWith('/') ? raw : '/$raw'}');
      }
    }
    final thumbImage =
        images.isNotEmpty ? images[0] : (json['thumb_image']?.toString() ?? '');

    final ratingObj = json['rating'];
    final ratingModel = ratingObj != null && ratingObj is Map<String, dynamic>
        ? Rating.fromJson(ratingObj)
        : null;
    final averageRating = ratingModel?.average.toString() ??
        (json['average_rating']?.toString() ?? '0.0');

    final deliveryInfo = json['deliveryInfo'] != null &&
            json['deliveryInfo'] is Map<String, dynamic>
        ? DeliveryInfo.fromJson(json['deliveryInfo'])
        : null;
    final warranty =
        json['warranty'] != null && json['warranty'] is Map<String, dynamic>
            ? Warranty.fromJson(json['warranty'])
            : null;
    final user = json['user'] is Map
        ? Map<String, dynamic>.from(json['user'] as Map)
        : null;
    final location = _locationFromAd(json);
    final vendorId =
        json['vendorId'] != null && json['vendorId'] is Map<String, dynamic>
            ? VendorInfo.fromJson(json['vendorId'])
            : null;
    final priceHistoryList = json['priceHistory'] as List?;
    final priceHistory = priceHistoryList != null
        ? priceHistoryList
            .where((e) => e is Map<String, dynamic>)
            .map((e) => PriceHistory.fromJson(e as Map<String, dynamic>))
            .toList()
        : <PriceHistory>[];

    return ProductModel(
      id: id,
      name: json["title"] ?? json["name"] ?? "",
      sku: json['sku']?.toString() ?? '',
      afterPrice: afterPrice,
      beforePrice: beforePrice,
      description: json["description"],
      isFeatured: json['featured'] ?? json['is_featured'] ?? json['isFeatured'] ?? false,
      thumbImage: thumbImage,
      category:
          json['category'] != null && json['category'] is Map<String, dynamic>
              ? Category.fromJson(json['category'])
              : null,
      isFavorite: json['isFavorite'] ?? json['is_favorite'] ?? false,
      averageRating: averageRating,
      deliveryInfo: deliveryInfo,
      warranty: warranty,
      location: location,
      rating: ratingModel,
      productType: json['productType']?.toString() ?? '',
      titleTr: json['titleTr'] ?? json["title"] ?? json["name"] ?? "",
      titleAr: json['titleAr'] ?? json["title"] ?? json["name"] ?? "",
      descriptionTr: json['descriptionTr'],
      descriptionAr: json['descriptionAr'],
      price: listedPrice,
      compareAtPrice: comparePrice is int
          ? comparePrice.toDouble()
          : (comparePrice as num?)?.toDouble(),
      images: images,
      adminCategory: json['adminCategory'] != null
          ? (json['adminCategory'] is Map<String, dynamic>
              ? (json['adminCategory']['name']?.toString() ??
                  json['adminCategory']['slug']?.toString())
              : json['adminCategory']?.toString())
          : null,
      badges: (json['badges'] as List?)
              ?.map((e) {
                if (e is Map<String, dynamic>) {
                  return e['text']?.toString() ?? '';
                }
                return e.toString();
              })
              .where((text) => text.isNotEmpty)
              .toList() ??
          [],
      status: json['status']?.toString() ?? '',
      stock: json['stock'] is int
          ? json['stock']
          : (int.tryParse(json['stock']?.toString() ?? '0') ?? 0),
      variants: json['variants'] as List? ?? [],
      variantCombinations: json['variantCombinations'] as List? ?? [],
      isFeaturedDeal: json['isFeaturedDeal'] ?? false,
      views: json['views'] is int
          ? json['views']
          : (int.tryParse(json['views']?.toString() ?? '0') ?? 0),
      approvedAt: json['approvedAt']?.toString(),
      approvedBy: json['approvedBy']?.toString(),
      specifications: json['specifications'] as List? ?? [],
      priceHistory: priceHistory,
      createdAt: json['createdAt']?.toString() ?? '',
      updatedAt: json['updatedAt']?.toString() ?? '',
      v: json['__v'] is int
          ? json['__v']
          : (int.tryParse(json['__v']?.toString() ?? '0') ?? 0),
      sellerId: _sellerId(json, user),
      sellerPhone: _sellerPhone(json, user),
      vendorId: vendorId,
      condition: json['condition']?.toString(),
      categorySpecificFields:
          json['categorySpecificFields'] as Map<String, dynamic>?,
    );
  }

  factory ProductModel.fromDetailsModel(ProductDetailsModel model) {
    return ProductModel(
      id: model.id,
      name: model.name,
      sku: model.sku,
      afterPrice: model.price.toString(),
      beforePrice: model.compareAtPrice.toString(),
      description: model.description,
      isFeatured: model.isFeatured,
      thumbImage: model.images.isNotEmpty ? model.images.first : '',
      category: null,
      isFavorite: model.isFavorite,
      averageRating: model.rating.average.toString(),
      productType: model.productType,
      images: model.images,
      badges: model.badges.map((e) => e.text).toList(),
      status: model.status,
      stock: model.stock,
      variants: model.variants,
      variantCombinations: model.variantCombinations,
      isFeaturedDeal: model.isFeaturedDeal,
      views: model.views,
      specifications: model.specifications,
      priceHistory: model.priceHistory
          .map(
            (e) => PriceHistory(
              price: e.price,
              date: e.date,
              reason: e.reason,
              id: e.id,
            ),
          )
          .toList(),
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      v: model.v,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "id": id,
      "name": name,
      "title": name,
      "titleTr": titleTr,
      "titleAr": titleAr,
      "sku": sku,
      "after_price": afterPrice,
      "before_price": beforePrice,
      "price": price,
      "compareAtPrice": compareAtPrice,
      "description": description,
      "descriptionTr": descriptionTr,
      "descriptionAr": descriptionAr,
      "is_featured": isFeatured,
      "featured": isFeatured,
      "thumb_image": thumbImage,
      "images": images,
      "category": category?.toJson(),
      "is_favorite": isFavorite,
      "average_rating": averageRating,
      "deliveryInfo": deliveryInfo?.toJson(),
      "warranty": warranty?.toJson(),
      "location": location?.toJson(),
      "rating": rating?.toJson(),
      "productType": productType,
      "adminCategory": adminCategory,
      "badges": badges,
      "status": status,
      "stock": stock,
      "variants": variants,
      "variantCombinations": variantCombinations,
      "isFeaturedDeal": isFeaturedDeal,
      "views": views,
      "approvedAt": approvedAt,
      "approvedBy": approvedBy,
      "specifications": specifications,
      "priceHistory": priceHistory.map((e) => e.toJson()).toList(),
      "createdAt": createdAt,
      "updatedAt": updatedAt,
      "__v": v,
      "sellerId": sellerId,
      "sellerPhone": sellerPhone,
      "vendorId": vendorId?.toJson(),
      "condition": condition,
      "categorySpecificFields": categorySpecificFields,
    };
  }
}

// Helper classes for nested objects
class DeliveryInfo {
  final int estimatedDays;
  final bool freeShipping;
  final bool isInTurkey;
  final double? freeShippingThreshold;

  DeliveryInfo({
    required this.estimatedDays,
    required this.freeShipping,
    required this.isInTurkey,
    this.freeShippingThreshold,
  });

  factory DeliveryInfo.fromJson(Map<String, dynamic> json) {
    return DeliveryInfo(
      estimatedDays: json['estimatedDays'] ?? 0,
      freeShipping: json['freeShipping'] ?? false,
      isInTurkey: json['isInTurkey'] ?? false,
      freeShippingThreshold: json['freeShippingThreshold'] != null
          ? (json['freeShippingThreshold'] is int
              ? json['freeShippingThreshold'].toDouble()
              : (json['freeShippingThreshold'] as num?)?.toDouble())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "estimatedDays": estimatedDays,
      "freeShipping": freeShipping,
      "isInTurkey": isInTurkey,
      "freeShippingThreshold": freeShippingThreshold,
    };
  }
}

class Warranty {
  final bool hasWarranty;
  final String? duration;
  final String? durationAr;
  final String? durationTr;
  final String? description;

  Warranty({
    required this.hasWarranty,
    this.duration,
    this.durationAr,
    this.durationTr,
    this.description,
  });

  factory Warranty.fromJson(Map<String, dynamic> json) {
    return Warranty(
      hasWarranty: json['hasWarranty'] ?? false,
      duration: json['duration']?.toString(),
      durationAr: json['durationAr']?.toString(),
      durationTr: json['durationTr']?.toString(),
      description: json['description']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "hasWarranty": hasWarranty,
      "duration": duration,
      "durationAr": durationAr,
      "durationTr": durationTr,
      "description": description,
    };
  }
}

class Location {
  final String? city;
  final String? district;
  final String? neighborhood;
  final String? street;

  Location({
    this.city,
    this.district,
    this.neighborhood,
    this.street,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      city: json['city']?.toString(),
      district: json['district']?.toString(),
      neighborhood: json['neighborhood']?.toString(),
      street: json['street']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "city": city,
      "district": district,
      "neighborhood": neighborhood,
      "street": street,
    };
  }
}

class Rating {
  final double average;
  final int count;

  Rating({
    required this.average,
    required this.count,
  });

  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      average: json['average'] is int
          ? json['average'].toDouble()
          : (json['average'] as num?)?.toDouble() ?? 0.0,
      count: json['count'] is int
          ? json['count']
          : (int.tryParse(json['count']?.toString() ?? '0') ?? 0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "average": average,
      "count": count,
    };
  }
}

class PriceHistory {
  final double price;
  final String date;
  final String reason;
  final String id;

  PriceHistory({
    required this.price,
    required this.date,
    required this.reason,
    required this.id,
  });

  factory PriceHistory.fromJson(Map<String, dynamic> json) {
    return PriceHistory(
      price: json['price'] is int
          ? json['price'].toDouble()
          : (json['price'] as num?)?.toDouble() ?? 0.0,
      date: json['date']?.toString() ?? '',
      reason: json['reason']?.toString() ?? '',
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "price": price,
      "date": date,
      "reason": reason,
      "_id": id,
    };
  }
}

class VendorInfo {
  final String id;
  final String storeName;
  final String? logo;
  final VendorStats? stats;

  VendorInfo({
    required this.id,
    required this.storeName,
    this.logo,
    this.stats,
  });

  factory VendorInfo.fromJson(Map<String, dynamic> json) {
    return VendorInfo(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      storeName: json['storeName']?.toString() ?? '',
      logo: json['logo']?.toString(),
      stats: json['stats'] != null ? VendorStats.fromJson(json['stats']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "storeName": storeName,
      "logo": logo,
      "stats": stats?.toJson(),
    };
  }
}

class VendorStats {
  final int totalSales;
  final int totalOrders;
  final int totalProducts;
  final int totalViews;
  final double rating;
  final int totalReviews;

  VendorStats({
    required this.totalSales,
    required this.totalOrders,
    required this.totalProducts,
    required this.totalViews,
    required this.rating,
    required this.totalReviews,
  });

  factory VendorStats.fromJson(Map<String, dynamic> json) {
    return VendorStats(
      totalSales: json['totalSales'] ?? 0,
      totalOrders: json['totalOrders'] ?? 0,
      totalProducts: json['totalProducts'] ?? 0,
      totalViews: json['totalViews'] ?? 0,
      rating: json['rating'] is int
          ? json['rating'].toDouble()
          : (json['rating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: json['totalReviews'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "totalSales": totalSales,
      "totalOrders": totalOrders,
      "totalProducts": totalProducts,
      "totalViews": totalViews,
      "rating": rating,
      "totalReviews": totalReviews,
    };
  }
}

class Meta {
  final int currentPage;
  final int from;
  final int lastPage;
  final int perPage;
  final int to;
  final int total;

  Meta({
    required this.currentPage,
    required this.from,
    required this.lastPage,
    required this.perPage,
    required this.to,
    required this.total,
  });

  factory Meta.fromJson(Map<String, dynamic> json) {
    return Meta(
      currentPage: json['current_page'] ?? 0,
      from: json['from'] ?? 0,
      lastPage: json['last_page'] ?? 0,
      perPage: json['per_page'] ?? 0,
      to: json['to'] ?? 0,
      total: json['total'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "current_page": currentPage,
      "from": from,
      "last_page": lastPage,
      "per_page": perPage,
      "to": to,
      "total": total,
    };
  }
}

class Category {
  final int id;
  final String name;

  Category({
    required this.id,
    required this.name,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    // Handle both old format (id) and new format (_id)
    final idValue = json['_id'] != null
        ? int.tryParse(json['_id'].toString()) ?? 0
        : (json['id'] is int
            ? json['id']
            : int.tryParse(json['id']?.toString() ?? '0') ?? 0);

    return Category(
      id: idValue,
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

class Pagination {
  final int page;
  final int limit;
  final int total;
  final int totalPages;
  final bool hasMore;

  Pagination({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
    required this.hasMore,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      page: json['page'] ?? 0,
      limit: json['limit'] ?? 0,
      total: json['total'] ?? 0,
      totalPages: json['totalPages'] ?? json['pages'] ?? 0,
      hasMore: json['hasMore'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "page": page,
      "limit": limit,
      "total": total,
      "totalPages": totalPages,
      "hasMore": hasMore,
    };
  }
}
