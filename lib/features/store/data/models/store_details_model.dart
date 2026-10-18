import 'package:heraj_meem/features/store/data/models/store_model.dart';

class StoreDetailsModel extends StoreModel {
  StoreDetailsModel({
    required super.id,
    required super.userId,
    required super.storeName,
    required super.email,
    required super.phone,
    required super.address,
    super.logo,
    super.banner,
    super.description,
    required super.status,
    super.subscriptionPlan,
    required super.hasSelectedSubscription,
    required super.sliderImages,
    required super.createdAt,
    required super.updatedAt,
    required super.v,
    super.approvedAt,
    super.approvedBy,
    super.subscriptionExpiry,
    required super.hasPremiumBadge,
    super.location,
    required super.stats,
    super.notificationPreferences,
    super.followerCount,
    super.followers,
    super.isPopularSeller,
  });

  factory StoreDetailsModel.fromJson(Map<String, dynamic> json) {
    return StoreDetailsModel(
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
}