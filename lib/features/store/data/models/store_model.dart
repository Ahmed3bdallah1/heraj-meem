import 'package:heraj_meem/features/ads/data/models/product_model.dart';

class StoreUserId {
  final String id;
  final String? phone;
  final String? countryCode;

  StoreUserId({
    required this.id,
    this.phone,
    this.countryCode,
  });

  factory StoreUserId.fromJson(Map<String, dynamic> json) {
    return StoreUserId(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      phone: json['phone']?.toString(),
      countryCode: json['countryCode']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'phone': phone,
      'countryCode': countryCode,
    };
  }
}

class NotificationPreferences {
  final QuietHours quietHours;
  final bool browserNotifications;
  final String emailDigest;
  final bool soundEnabled;
  final double soundVolume;

  NotificationPreferences({
    required this.quietHours,
    required this.browserNotifications,
    required this.emailDigest,
    required this.soundEnabled,
    required this.soundVolume,
  });

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) {
    return NotificationPreferences(
      quietHours: json['quietHours'] != null
          ? QuietHours.fromJson(json['quietHours'])
          : QuietHours(enabled: false, start: '22:00', end: '08:00'),
      browserNotifications: json['browserNotifications'] ?? true,
      emailDigest: json['emailDigest']?.toString() ?? 'none',
      soundEnabled: json['soundEnabled'] ?? true,
      soundVolume: json['soundVolume'] is int
          ? (json['soundVolume'] as int).toDouble()
          : (json['soundVolume'] as num?)?.toDouble() ?? 0.7,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'quietHours': quietHours.toJson(),
      'browserNotifications': browserNotifications,
      'emailDigest': emailDigest,
      'soundEnabled': soundEnabled,
      'soundVolume': soundVolume,
    };
  }
}

class QuietHours {
  final bool enabled;
  final String start;
  final String end;

  QuietHours({
    required this.enabled,
    required this.start,
    required this.end,
  });

  factory QuietHours.fromJson(Map<String, dynamic> json) {
    return QuietHours(
      enabled: json['enabled'] ?? false,
      start: json['start']?.toString() ?? '22:00',
      end: json['end']?.toString() ?? '08:00',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'start': start,
      'end': end,
    };
  }
}

class StoreSliderImage {
  final String id;
  final String title;
  final String? titleAr;
  final String? titleTr;
  final String image;
  final String linkType;
  final String? linkId;
  final int order;
  final bool isActive;
  final String createdAt;
  final String updatedAt;
  final int v;

  StoreSliderImage({
    required this.id,
    required this.title,
    this.titleAr,
    this.titleTr,
    required this.image,
    required this.linkType,
    this.linkId,
    required this.order,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  factory StoreSliderImage.fromJson(Map<String, dynamic> json) {
    return StoreSliderImage(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      titleAr: json['titleAr']?.toString(),
      titleTr: json['titleTr']?.toString(),
      image: json['image']?.toString() ?? json['url']?.toString() ?? '',
      linkType: json['linkType']?.toString() ?? 'none',
      linkId: json['linkId']?.toString(),
      order: json['order'] is int
          ? json['order']
          : (int.tryParse(json['order']?.toString() ?? '0') ?? 0),
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt']?.toString() ?? '',
      updatedAt: json['updatedAt']?.toString() ?? '',
      v: json['__v'] is int
          ? json['__v']
          : (int.tryParse(json['__v']?.toString() ?? '0') ?? 0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'titleAr': titleAr,
      'titleTr': titleTr,
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

class StorePaginatedModel {
  final bool success;
  final List<StoreModel> data;
  final Pagination? pagination;

  StorePaginatedModel({
    required this.success,
    required this.data,
    this.pagination,
  });

  factory StorePaginatedModel.fromJson(Map<String, dynamic> json) {
    return StorePaginatedModel(
      success: json['success'] ?? true,
      data: (json['data'] as List?)
              ?.map((item) => StoreModel.fromJson(item))
              .toList() ??
          [],
      pagination: json['pagination'] != null
          ? Pagination.fromJson(json['pagination'])
          : null,
    );
  }
}

class StoreModel {
  final String id;
  final StoreUserId userId;
  final String storeName;
  final String email;
  final String phone;
  final String address;
  final String? logo;
  final String? banner;
  final String? description;
  final String status;
  final String? subscriptionPlan;
  final bool hasSelectedSubscription;
  final List<StoreSliderImage> sliderImages;
  final String createdAt;
  final String updatedAt;
  final int v;
  final String? approvedAt;
  final String? approvedBy;
  final String? subscriptionExpiry;
  final bool hasPremiumBadge;
  final StoreLocation? location;
  final StoreStats stats;
  final NotificationPreferences? notificationPreferences;
  final int followerCount;
  final List<String> followers;
  final bool isPopularSeller;

  StoreModel({
    required this.id,
    required this.userId,
    required this.storeName,
    required this.email,
    required this.phone,
    required this.address,
    this.logo,
    this.banner,
    this.description,
    required this.status,
    this.subscriptionPlan,
    required this.hasSelectedSubscription,
    required this.sliderImages,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
    this.approvedAt,
    this.approvedBy,
    this.subscriptionExpiry,
    required this.hasPremiumBadge,
    this.location,
    required this.stats,
    this.notificationPreferences,
    this.followerCount = 0,
    this.followers = const [],
    this.isPopularSeller = false,
  });

  factory StoreModel.fromJson(Map<String, dynamic> json) {
    return StoreModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      userId: json['userId'] != null
          ? (json['userId'] is Map<String, dynamic>
              ? StoreUserId.fromJson(json['userId'])
              : StoreUserId(id: json['userId']?.toString() ?? ''))
          : StoreUserId(id: ''),
      storeName: json['storeName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      logo: json['logo']?.toString(),
      banner: json['banner']?.toString(),
      description: json['description']?.toString(),
      status: json['status']?.toString() ?? '',
      subscriptionPlan: json['subscriptionPlan']?.toString(),
      hasSelectedSubscription: json['hasSelectedSubscription'] ?? false,
      sliderImages: (json['sliderImages'] as List?)
              ?.map((e) =>
                  StoreSliderImage.fromJson(e is Map<String, dynamic> ? e : {}))
              .toList() ??
          [],
      createdAt: json['createdAt']?.toString() ?? '',
      updatedAt: json['updatedAt']?.toString() ?? '',
      v: json['__v'] is int
          ? json['__v']
          : (int.tryParse(json['__v']?.toString() ?? '0') ?? 0),
      approvedAt: json['approvedAt']?.toString(),
      approvedBy: json['approvedBy']?.toString(),
      subscriptionExpiry: json['subscriptionExpiry']?.toString(),
      hasPremiumBadge: json['hasPremiumBadge'] ?? false,
      location: json['location'] != null
          ? StoreLocation.fromJson(json['location'])
          : null,
      stats: json['stats'] != null
          ? StoreStats.fromJson(json['stats'])
          : StoreStats(
              totalSales: 0,
              totalOrders: 0,
              totalProducts: 0,
              totalViews: 0,
              rating: 0.0,
              totalReviews: 0,
            ),
      notificationPreferences: json['notificationPreferences'] != null
          ? NotificationPreferences.fromJson(json['notificationPreferences'])
          : null,
      followerCount: json['followerCount'] is int
          ? json['followerCount']
          : (int.tryParse(json['followerCount']?.toString() ?? '0') ?? 0),
      followers: (json['followers'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      isPopularSeller: json['isPopularSeller'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId.toJson(),
      'storeName': storeName,
      'email': email,
      'phone': phone,
      'address': address,
      'logo': logo,
      'banner': banner,
      'description': description,
      'status': status,
      'subscriptionPlan': subscriptionPlan,
      'hasSelectedSubscription': hasSelectedSubscription,
      'sliderImages': sliderImages.map((e) => e.toJson()).toList(),
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      '__v': v,
      'approvedAt': approvedAt,
      'approvedBy': approvedBy,
      'subscriptionExpiry': subscriptionExpiry,
      'hasPremiumBadge': hasPremiumBadge,
      'location': location?.toJson(),
      'stats': stats.toJson(),
      'notificationPreferences': notificationPreferences?.toJson(),
      'followerCount': followerCount,
      'followers': followers,
      'isPopularSeller': isPopularSeller,
    };
  }
}

class StoreLocation {
  final String type;
  final List<double>? coordinates;

  StoreLocation({
    required this.type,
    this.coordinates,
  });

  factory StoreLocation.fromJson(Map<String, dynamic> json) {
    return StoreLocation(
      type: json['type']?.toString() ?? 'Point',
      coordinates: json['coordinates'] != null
          ? (json['coordinates'] as List?)
              ?.map((e) => (e is num ? e.toDouble() : 0.0))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'coordinates': coordinates,
    };
  }
}

class StoreStats {
  final int totalSales;
  final int totalOrders;
  final int totalProducts;
  final int totalViews;
  final double rating;
  final int totalReviews;

  StoreStats({
    required this.totalSales,
    required this.totalOrders,
    required this.totalProducts,
    required this.totalViews,
    required this.rating,
    required this.totalReviews,
  });

  factory StoreStats.fromJson(Map<String, dynamic> json) {
    return StoreStats(
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
          ? json['rating'].toDouble()
          : (json['rating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: json['totalReviews'] is int
          ? json['totalReviews']
          : (int.tryParse(json['totalReviews']?.toString() ?? '0') ?? 0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalSales': totalSales,
      'totalOrders': totalOrders,
      'totalProducts': totalProducts,
      'totalViews': totalViews,
      'rating': rating,
      'totalReviews': totalReviews,
    };
  }
}
