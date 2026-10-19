import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heraj_meem/config/api_path.dart';
import 'package:heraj_meem/core/service/webservice/dio_helper.dart';
import 'package:heraj_meem/features/ads/data/models/product_details_model.dart';
import 'package:heraj_meem/features/ads/data/models/product_model.dart';
import 'package:heraj_meem/features/ads/data/models/product_quota_model.dart';
import 'package:heraj_meem/features/ads/data/models/review_model.dart';
import 'package:heraj_meem/features/ads/domain/repo/product_repo.dart';
import 'package:heraj_meem/main.dart';

final fetchNewOpenStoreProducts = FutureProvider((ref) async {
  final res = await getIt<ProductRepo>().getNewOpenStoreProducts();
  return res.fold((l) => throw l, (r) => r);
});

final fetchProductByIdProvider = FutureProvider.family
    .autoDispose<ProductDetailsModel, String>((ref, id) async {
  final res = await getIt<ProductRepo>().getProductById(id);
  return res.fold((l) => throw l, (r) => r);
});

final fetchMyAdsProvider =
    FutureProvider.autoDispose<List<ProductModel>>((ref) async {
  final data = await getIt<ApiService>().get(
    url: ApiPath.getMyAds,
    returnDataOnly: true,
  );
  final raw = data is List
      ? data
      : data is Map
          ? (data['items'] ?? data['ads'] ?? data['products'])
          : null;
  if (raw is! List) return const [];
  return raw
      .whereType<Map>()
      .map((item) => ProductModel.fromJson(Map<String, dynamic>.from(item)))
      .where((ad) => ad.id.isNotEmpty)
      .toList();
});

final fetchMyAdProvider = FutureProvider.family
    .autoDispose<ProductDetailsModel, String>((ref, id) async {
  final data = await getIt<ApiService>().get(
    url: ApiPath.getMyAd(id),
    returnDataOnly: true,
  );
  final map = data is Map<String, dynamic>
      ? data
      : Map<String, dynamic>.from(data as Map);
  return ProductDetailsModel.fromAd(map);
});

final fetchProductReviewsProvider = FutureProvider.family
    .autoDispose<ProductReviewsModel, String>((ref, id) async {
  final res = await getIt<ProductRepo>().getProductReviews(id);
  return res.fold((l) => throw l, (r) => r);
});

final searchProductsProvider = FutureProvider.family.autoDispose<List<ProductModel>, String>((ref, query) async {
  if (query.isEmpty) return [];
  final res = await getIt<ProductRepo>().searchProducts(query);
  return res.fold((l) => throw l, (r) => r.data);
});

final fetchProductQuotaProvider = FutureProvider.autoDispose<ProductQuotaModel>((ref) async {
  final res = await getIt<ProductRepo>().getMyQuota();
  return res.fold((l) => throw l, (r) => r);
});