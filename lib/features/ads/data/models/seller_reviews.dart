import 'package:heraj_meem/config/api_path.dart';

class SellerReview {
  const SellerReview({
    required this.id,
    required this.reviewerName,
    required this.avatarUrl,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  final String id;
  final String reviewerName;
  final String avatarUrl;
  final int rating;
  final String comment;
  final String createdAt;

  factory SellerReview.fromJson(Map<String, dynamic> json) {
    final reviewer = json['reviewer'] is Map
        ? Map<String, dynamic>.from(json['reviewer'] as Map)
        : json['user'] is Map
            ? Map<String, dynamic>.from(json['user'] as Map)
            : null;
    final profile = reviewer?['profile'] is Map
        ? Map<String, dynamic>.from(reviewer!['profile'] as Map)
        : null;
    final rating = json['rating'] ?? json['stars'] ?? json['score'];
    return SellerReview(
      id: json['id']?.toString() ?? '',
      reviewerName: profile?['displayName']?.toString() ??
          profile?['name']?.toString() ??
          reviewer?['displayName']?.toString() ??
          reviewer?['name']?.toString() ??
          json['reviewerName']?.toString() ??
          '',
      avatarUrl: _mediaUrl(
        profile?['avatarUrl']?.toString() ??
            profile?['avatar']?.toString() ??
            reviewer?['avatarUrl']?.toString() ??
            '',
      ),
      rating: rating is num
          ? rating.round().clamp(0, 5)
          : int.tryParse(rating?.toString() ?? '') ?? 0,
      comment: json['comment']?.toString() ?? json['text']?.toString() ?? '',
      createdAt: json['createdAt']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reviewerName': reviewerName,
      'avatarUrl': avatarUrl,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt,
    };
  }

  static String _mediaUrl(String raw) {
    if (raw.isEmpty || raw.startsWith('http')) return raw;
    return '${ApiPath.serverUrl}${raw.startsWith('/') ? raw : '/$raw'}';
  }
}

class SellerReviews {
  const SellerReviews({
    required this.items,
    required this.average,
    required this.total,
  });

  final List<SellerReview> items;
  final double average;
  final int total;

  factory SellerReviews.fromData(dynamic data) {
    if (data is List) {
      final items = _items(data);
      return SellerReviews(
        items: items,
        average: _average(items),
        total: items.length,
      );
    }
    if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      final raw = map['items'] ?? map['reviews'] ?? map['data'];
      final items = raw is List ? _items(raw) : const <SellerReview>[];
      final totalRaw = map['total'] ?? map['count'] ?? map['reviewCount'];
      final averageRaw =
          map['average'] ?? map['avg'] ?? map['score'] ?? map['rating'];
      return SellerReviews(
        items: items,
        average: averageRaw is num ? averageRaw.toDouble() : _average(items),
        total: totalRaw is num ? totalRaw.toInt() : items.length,
      );
    }
    return const SellerReviews(items: [], average: 0, total: 0);
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
      'average': average,
      'total': total,
    };
  }

  static List<SellerReview> _items(List<dynamic> raw) {
    return raw
        .whereType<Map>()
        .map((item) => SellerReview.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  static double _average(List<SellerReview> items) {
    if (items.isEmpty) return 0;
    final sum = items.fold<int>(0, (total, item) => total + item.rating);
    return sum / items.length;
  }
}
