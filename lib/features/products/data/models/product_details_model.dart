import 'package:heraj_meem/core/service/local_data_manager.dart';

class ProductDetailsModel {
  final String id;
  final String name;
  final String sku;
  final double price;
  final double compareAtPrice;
  final String description;
  final bool isFeatured;
  final List<String> images;
  final AdminCategory? adminCategory;
  final List<BadgeModel> badges;
  final String status;
  final int stock;
  final bool isFeaturedDeal;
  final int views;
  final String? approvedAt;
  final String? approvedBy;
  final List<PriceHistory> priceHistory;
  final String createdAt;
  final String updatedAt;
  final int v;
  final DeliveryInfo? deliveryInfo;
  final Warranty? warranty;
  final Location? location;
  final Rating rating;
  final String productType;
  final String? titleTr;
  final String? titleAr;
  final String? descriptionTr;
  final String? descriptionAr;
  final List<dynamic> variants;
  final List<dynamic> variantCombinations;
  final List<Specification> specifications;
  final bool isFavorite;
  final SellerInfo? sellerId;
  final String? sellerPhone;
  final VendorInfo? vendorId;
  final Map<String, dynamic>? categorySpecificFields;
  final String? condition;

  /// Category id for vendor/customer products (when adminCategory is null). Parsed from category or categoryId.
  final String? categoryId;

  ProductDetailsModel({
    required this.id,
    required this.name,
    required this.sku,
    required this.price,
    required this.compareAtPrice,
    required this.description,
    required this.isFeatured,
    required this.images,
    this.adminCategory,
    required this.badges,
    required this.status,
    required this.stock,
    required this.isFeaturedDeal,
    required this.views,
    this.approvedAt,
    this.approvedBy,
    required this.priceHistory,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
    this.deliveryInfo,
    this.warranty,
    this.location,
    required this.rating,
    required this.productType,
    this.titleTr,
    this.titleAr,
    this.descriptionTr,
    this.descriptionAr,
    required this.variants,
    required this.variantCombinations,
    required this.specifications,
    this.isFavorite = false,
    this.sellerId,
    this.sellerPhone,
    this.vendorId,
    this.categorySpecificFields,
    this.condition,
    this.categoryId,
  });

  factory ProductDetailsModel.fromJson(Map<String, dynamic> json) {
    final images =
        (json['images'] as List?)?.map((e) => e.toString()).toList() ??
            <String>[];

    return ProductDetailsModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['title'] ?? json['name'] ?? '',
      sku: json['sku']?.toString() ?? '',
      price: (json['price'] is int
              ? (json['price'] as int).toDouble()
              : (json['price'] as num?)?.toDouble()) ??
          0.0,
      compareAtPrice: (json['compareAtPrice'] is int
              ? (json['compareAtPrice'] as int).toDouble()
              : (json['compareAtPrice'] as num?)?.toDouble()) ??
          0.0,
      description: json['description'] ?? '',
      isFeatured: json['featured'] ?? json['is_featured'] ?? false,
      images: images,
      adminCategory: json['adminCategory'] != null &&
              json['adminCategory'] is Map<String, dynamic>
          ? AdminCategory.fromJson(json['adminCategory'])
          : null,
      badges: (json['badges'] as List?)
              ?.map((e) => BadgeModel.fromJson(e))
              .toList() ??
          [],
      status: json['status']?.toString() ?? '',
      stock: json['stock'] is int
          ? json['stock']
          : (int.tryParse(json['stock']?.toString() ?? '0') ?? 0),
      isFeaturedDeal: json['isFeaturedDeal'] ?? false,
      views: json['views'] is int
          ? json['views']
          : (int.tryParse(json['views']?.toString() ?? '0') ?? 0),
      approvedAt: json['approvedAt']?.toString(),
      approvedBy: json['approvedBy']?.toString(),
      priceHistory: (json['priceHistory'] as List?)
              ?.map((e) => PriceHistory.fromJson(e))
              .toList() ??
          [],
      createdAt: json['createdAt']?.toString() ?? '',
      updatedAt: json['updatedAt']?.toString() ?? '',
      v: json['__v'] is int
          ? json['__v']
          : (int.tryParse(json['__v']?.toString() ?? '0') ?? 0),
      deliveryInfo: json['deliveryInfo'] != null
          ? DeliveryInfo.fromJson(json['deliveryInfo'])
          : null,
      warranty:
          json['warranty'] != null ? Warranty.fromJson(json['warranty']) : null,
      location:
          json['location'] != null ? Location.fromJson(json['location']) : null,
      rating: json['rating'] != null
          ? Rating.fromJson(json['rating'])
          : Rating(average: 0, count: 0),
      productType: json['productType']?.toString() ?? '',
      titleTr: json['titleTr'] ?? json['title'] ?? json['name'] ?? '',
      titleAr: json['titleAr'] ?? json['title'] ?? json['name'] ?? '',
      descriptionTr: json['descriptionTr'] ?? json['description'] ?? '',
      descriptionAr: json['descriptionAr'] ?? json['description'] ?? '',
      variants: json['variants'] as List? ?? [],
      variantCombinations: json['variantCombinations'] as List? ?? [],
      specifications: (json['specifications'] as List?)
              ?.map((e) =>
                  Specification.fromJson(e is Map<String, dynamic> ? e : {}))
              .toList() ??
          [],
      isFavorite: json['is_favorite'] ?? false,
      sellerId:
          json['sellerId'] != null && json['sellerId'] is Map<String, dynamic>
              ? SellerInfo.fromJson(json['sellerId'])
              : null,
      sellerPhone: json['sellerPhone']?.toString(),
      vendorId:
          json['vendorId'] != null && json['vendorId'] is Map<String, dynamic>
              ? VendorInfo.fromJson(json['vendorId'])
              : null,
      categorySpecificFields:
          json['categorySpecificFields'] as Map<String, dynamic>?,
      condition: json['condition']?.toString(),
      categoryId: _parseCategoryId(json),
    );
  }

  static String? _parseCategoryId(Map<String, dynamic> json) {
    final cat = json['category'];
    if (cat == null) return json['categoryId']?.toString();
    if (cat is String) return cat.isNotEmpty ? cat : null;
    if (cat is Map) return cat['_id']?.toString() ?? cat['id']?.toString();
    return json['categoryId']?.toString();
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "id": id,
      "name": name,
      "sku": sku,
      "price": price,
      "compareAtPrice": compareAtPrice,
      "description": description,
      "is_featured": isFeatured,
      "featured": isFeatured,
      "images": images,
      "adminCategory": adminCategory?.toJson(),
      "badges": badges.map((e) => e.toJson()).toList(),
      "status": status,
      "stock": stock,
      "isFeaturedDeal": isFeaturedDeal,
      "views": views,
      "approvedAt": approvedAt,
      "approvedBy": approvedBy,
      "priceHistory": priceHistory.map((e) => e.toJson()).toList(),
      "createdAt": createdAt,
      "updatedAt": updatedAt,
      "__v": v,
      "deliveryInfo": deliveryInfo?.toJson(),
      "warranty": warranty?.toJson(),
      "location": location?.toJson(),
      "rating": rating.toJson(),
      "productType": productType,
      "titleTr": titleTr,
      "titleAr": titleAr,
      "descriptionTr": descriptionTr,
      "descriptionAr": descriptionAr,
      "variants": variants,
      "variantCombinations": variantCombinations,
      "specifications": specifications.map((e) => e.toJson()).toList(),
      "is_favorite": isFavorite,
      "sellerId": sellerId?.toJson(),
      "sellerPhone": sellerPhone,
      "vendorId": vendorId?.toJson(),
      "categorySpecificFields": categorySpecificFields,
      "condition": condition,
      "categoryId": categoryId,
    };
  }
}

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
              ? (json['freeShippingThreshold'] as int).toDouble()
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
  final String? formattedAddress;

  Location({
    this.city,
    this.district,
    this.neighborhood,
    this.street,
    this.formattedAddress,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      city: json['city']?.toString(),
      district: json['district']?.toString(),
      neighborhood: json['neighborhood']?.toString(),
      street: json['street']?.toString(),
      formattedAddress: json['formattedAddress']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "city": city,
      "district": district,
      "neighborhood": neighborhood,
      "street": street,
      "formattedAddress": formattedAddress,
    };
  }
}

class Rating {
  final double average;
  final int count;

  Rating({required this.average, required this.count});

  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      average: json['average'] is int
          ? (json['average'] as int).toDouble()
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
          ? (json['price'] as int).toDouble()
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

class AdminCategory {
  final String id;
  final String name;
  final String? nameAr;
  final String? nameTr;
  final String? image;
  final String slug;

  AdminCategory({
    required this.id,
    required this.name,
    this.nameAr,
    this.nameTr,
    this.image,
    required this.slug,
  });

  factory AdminCategory.fromJson(Map<String, dynamic> json) {
    return AdminCategory(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      nameAr: json['nameAr']?.toString(),
      nameTr: json['nameTr']?.toString(),
      image: json['image']?.toString(),
      slug: json['slug']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "name": name,
      "nameAr": nameAr,
      "nameTr": nameTr,
      "image": image,
      "slug": slug,
    };
  }
}

class BadgeModel {
  final String id;
  final String text;
  final String? textAr;
  final String? textTr;
  final String? backgroundColor;
  final String? textColor;
  final String? borderColor;
  final String? icon;
  final String? animationType;
  final bool isActive;
  final int order;

  BadgeModel({
    required this.id,
    required this.text,
    this.textAr,
    this.textTr,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.icon,
    this.animationType,
    required this.isActive,
    required this.order,
  });

  factory BadgeModel.fromJson(Map<String, dynamic> json) {
    return BadgeModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      text: json['text']?.toString() ?? '',
      textAr: json['textAr']?.toString(),
      textTr: json['textTr']?.toString(),
      backgroundColor: json['backgroundColor']?.toString(),
      textColor: json['textColor']?.toString(),
      borderColor: json['borderColor']?.toString(),
      icon: json['icon']?.toString(),
      animationType: json['animationType']?.toString(),
      isActive: json['isActive'] ?? false,
      order: json['order'] is int
          ? json['order']
          : (int.tryParse(json['order']?.toString() ?? '0') ?? 0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "text": text,
      "textAr": textAr,
      "textTr": textTr,
      "backgroundColor": backgroundColor,
      "textColor": textColor,
      "borderColor": borderColor,
      "icon": icon,
      "animationType": animationType,
      "isActive": isActive,
      "order": order,
    };
  }
}

class Specification {
  final String key;
  final String? keyAr;
  final String? keyTr;
  final String value;
  final String? valueAr;
  final String? valueTr;
  final String id;

  Specification({
    required this.key,
    this.keyAr,
    this.keyTr,
    required this.value,
    this.valueAr,
    this.valueTr,
    required this.id,
  });

  factory Specification.fromJson(Map<String, dynamic> json) {
    return Specification(
      key: json['key']?.toString() ?? '',
      keyAr: json['keyAr']?.toString(),
      keyTr: json['keyTr']?.toString(),
      value: json['value']?.toString() ?? '',
      valueAr: json['valueAr']?.toString(),
      valueTr: json['valueTr']?.toString(),
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "key": key,
      "keyAr": keyAr,
      "keyTr": keyTr,
      "value": value,
      "valueAr": valueAr,
      "valueTr": valueTr,
      "_id": id,
    };
  }
}

class SellerInfo {
  final String id;
  final String? phone;
  final String? countryCode;
  final SellerProfile? profile;

  SellerInfo({
    required this.id,
    this.phone,
    this.countryCode,
    this.profile,
  });

  factory SellerInfo.fromJson(Map<String, dynamic> json) {
    return SellerInfo(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      phone: json['phone']?.toString(),
      countryCode: json['countryCode']?.toString(),
      profile:
          json['profile'] != null && json['profile'] is Map<String, dynamic>
              ? SellerProfile.fromJson(json['profile'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "phone": phone,
      "countryCode": countryCode,
      "profile": profile?.toJson(),
    };
  }
}

class SellerProfile {
  final String? name;
  final String? email;
  final String? avatar;

  SellerProfile({
    this.name,
    this.email,
    this.avatar,
  });

  factory SellerProfile.fromJson(Map<String, dynamic> json) {
    return SellerProfile(
      name: json['name']?.toString(),
      email: json['email']?.toString(),
      avatar: json['avatar']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "email": email,
      "avatar": avatar,
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
      stats: json['stats'] != null && json['stats'] is Map<String, dynamic>
          ? VendorStats.fromJson(json['stats'])
          : null,
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
      totalSales: json['totalSales'] is int
          ? json['totalSales']
          : (int.tryParse(json['totalSales']?.toString() ?? '0') ?? 0),
      totalOrders: json['totalOrders'] is int
          ? json['totalOrders']
          : (int.tryParse(json['totalOrders']?.toString() ?? '0') ?? 0),
      totalProducts: json['totalProducts'] is int
          ? json['totalProducts']
          : (int.tryParse(json['totalProducts']?.toString() ?? '0') ?? 0),
      totalViews: json['totalViews'] is int
          ? json['totalViews']
          : (int.tryParse(json['totalViews']?.toString() ?? '0') ?? 0),
      rating: json['rating'] is int
          ? (json['rating'] as int).toDouble()
          : (json['rating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: json['totalReviews'] is int
          ? json['totalReviews']
          : (int.tryParse(json['totalReviews']?.toString() ?? '0') ?? 0),
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
