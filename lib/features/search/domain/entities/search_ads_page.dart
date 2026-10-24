import 'package:heraj_meem/features/ads/data/models/product_model.dart';

class SearchAdsParam {
  const SearchAdsParam({
    required this.query,
    this.page = 1,
    this.limit = 20,
  });

  final String query;
  final int page;
  final int limit;

  factory SearchAdsParam.fromJson(Map<String, dynamic> json) {
    return SearchAdsParam(
      query: json['q']?.toString() ?? '',
      page: json['page'] is num ? (json['page'] as num).toInt() : 1,
      limit: json['limit'] is num ? (json['limit'] as num).toInt() : 20,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'q': query,
      'page': page,
      'limit': limit,
      'sort': 'newest',
    };
  }
}

class SearchAdsPage {
  const SearchAdsPage({
    required this.items,
    required this.hasMore,
  });

  final List<ProductModel> items;
  final bool hasMore;

  factory SearchAdsPage.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    final items = rawItems is List
        ? rawItems
            .whereType<Map>()
            .map((item) =>
                ProductModel.fromJson(Map<String, dynamic>.from(item)))
            .where((ad) => ad.id.isNotEmpty)
            .toList()
        : <ProductModel>[];
    final total = json['total'] is num ? (json['total'] as num).toInt() : 0;
    final page = json['page'] is num ? (json['page'] as num).toInt() : 1;
    final limit = json['limit'] is num ? (json['limit'] as num).toInt() : 20;
    final hasMore = json['hasMore'] == true ||
        (json['hasMore'] == null && total > 0 && page * limit < total);
    return SearchAdsPage(items: items, hasMore: hasMore);
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
      'hasMore': hasMore,
    };
  }
}
