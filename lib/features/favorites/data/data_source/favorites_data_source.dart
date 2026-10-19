import 'package:heraj_meem/features/ads/data/models/product_model.dart';

import '../../../../config/api_path.dart';
import '../../../../core/service/webservice/dio_helper.dart';

abstract class FavoritesDataSource {
  Future<List<ProductModel>> getFavorites();

  Future<bool> addOrDeleteFavorites({required String productId});

  Future<bool> removeFavorite({required String productId});
}

class FavoritesDataSourceImpl implements FavoritesDataSource {
  final ApiService apiClient;

  FavoritesDataSourceImpl({required this.apiClient});

  @override
  Future<List<ProductModel>> getFavorites() async {
    final response =
        await apiClient.get(url: ApiPath.getFavorites, returnDataOnly: true);
    return _favoriteAds(response)
        .map(ProductModel.fromJson)
        .where((ad) => ad.id.isNotEmpty)
        .toList();
  }

  @override
  Future<bool> addOrDeleteFavorites({required String productId}) async {
    await apiClient.post(url: ApiPath.toggleFavorite(productId));
    return true;
  }

  @override
  Future<bool> removeFavorite({required String productId}) async {
    await apiClient.delete(url: ApiPath.removeFavorite(productId));
    return true;
  }
}

List<Map<String, dynamic>> _favoriteAds(dynamic data) {
  final raw = data is List
      ? data
      : data is Map
          ? (data['items'] ?? data['favorites'] ?? data['ads'])
          : null;
  if (raw is! List) return const [];
  return raw.whereType<Map>().map((item) {
    final source = item['ad'] ?? item['product'] ?? item;
    final map = Map<String, dynamic>.from(source as Map);
    map['id'] ??= item['adId'] ?? item['ad_id'] ?? item['id'];
    map['isFavorite'] ??= map['is_favorite'] ?? true;
    return map;
  }).toList();
}
