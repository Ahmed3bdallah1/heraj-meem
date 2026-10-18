import 'package:heraj/features/store/data/models/store_model.dart';

class VendorProfileModel {
  final String id;
  final String userId;
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
  final StoreLocation? location;
  final StoreStats stats;
  final List<String> businessDocuments;

  VendorProfileModel({
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
    this.location,
    required this.stats,
    required this.businessDocuments,
  });

  factory VendorProfileModel.fromJson(Map<String, dynamic> json) {
    return VendorProfileModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
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
              ?.map((e) => StoreSliderImage.fromJson(e))
              .toList() ??
          [],
      createdAt: json['createdAt']?.toString() ?? '',
      updatedAt: json['updatedAt']?.toString() ?? '',
      v: json['__v'] is int
          ? json['__v']
          : (int.tryParse(json['__v']?.toString() ?? '0') ?? 0),
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
              rating: 0,
              totalReviews: 0,
            ),
      businessDocuments: (json['businessDocuments'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
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
      'location': location?.toJson(),
      'stats': stats.toJson(),
      'businessDocuments': businessDocuments,
    };
  }
}
