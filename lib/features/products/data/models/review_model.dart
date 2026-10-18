import 'package:heraj/features/products/data/models/product_model.dart';

class ProductReview {
  final String id;
  final String userId;
  final String productId;
  final String userName;
  final String userImage;
  final int rating;
  final String comment;
  final List<String> images;
  final bool isVerifiedPurchase;
  final int helpfulCount;
  final DateTime createdAt;

  ProductReview({
    required this.id,
    required this.userId,
    required this.productId,
    required this.userName,
    required this.userImage,
    required this.rating,
    required this.comment,
    required this.images,
    required this.isVerifiedPurchase,
    required this.helpfulCount,
    required this.createdAt,
  });

  factory ProductReview.fromJson(Map<String, dynamic> json) {
    final user = json['userId'] as Map<String, dynamic>?;
    final profile = user?['profile'] as Map<String, dynamic>?;

    return ProductReview(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      userId: user?['_id']?.toString() ?? user?['id']?.toString() ?? '',
      productId: json['productId']?.toString() ?? '',
      userName: profile?['name']?.toString() ?? 'User',
      userImage: profile?["avatar"]?.toString() ?? "",
      rating: json['rating'] is int
          ? json['rating']
          : (int.tryParse(json['rating']?.toString() ?? '0') ?? 0),
      comment: json['comment']?.toString() ?? '',
      images: (json['images'] as List?)?.map((e) => e.toString()).toList() ??
          <String>[],
      isVerifiedPurchase: json['isVerifiedPurchase'] ?? false,
      helpfulCount: json['helpfulCount'] is int
          ? json['helpfulCount']
          : (int.tryParse(json['helpfulCount']?.toString() ?? '0') ?? 0),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}

class RatingDistribution {
  final Map<int, int> distribution;

  RatingDistribution(this.distribution);

  factory RatingDistribution.fromJson(Map<String, dynamic> json) {
    final map = <int, int>{};
    json.forEach((key, value) {
      final k = int.tryParse(key) ?? 0;
      final v =
          value is int ? value : (int.tryParse(value?.toString() ?? '0') ?? 0);
      map[k] = v;
    });
    return RatingDistribution(map);
  }
}

class ProductReviewsModel {
  final List<ProductReview> reviews;
  final RatingDistribution ratingDistribution;
  final Pagination pagination;

  ProductReviewsModel({
    required this.reviews,
    required this.ratingDistribution,
    required this.pagination,
  });

  factory ProductReviewsModel.fromJson(Map<String, dynamic> json) {
    final reviewsList = (json['reviews'] as List?)
            ?.map((e) => ProductReview.fromJson(e))
            .toList() ??
        <ProductReview>[];

    final ratingDist = json['ratingDistribution'] != null
        ? RatingDistribution.fromJson(
            json['ratingDistribution'] as Map<String, dynamic>)
        : RatingDistribution({});

    final pagination = json['pagination'] != null
        ? Pagination.fromJson(json['pagination'] as Map<String, dynamic>)
        : Pagination(
            page: 1, limit: 10, total: 0, totalPages: 1, hasMore: false);

    return ProductReviewsModel(
      reviews: reviewsList,
      ratingDistribution: ratingDist,
      pagination: pagination,
    );
  }
}
