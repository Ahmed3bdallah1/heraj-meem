import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heraj/features/products/data/models/product_details_model.dart';
import 'package:heraj/features/products/data/models/product_model.dart';
import 'package:heraj/features/products/data/models/product_quota_model.dart';
import 'package:heraj/features/products/data/models/review_model.dart';
import 'package:heraj/features/products/domain/repo/product_repo.dart';
import 'package:heraj/main.dart';

final fetchNewOpenStoreProducts = FutureProvider((ref) async {
  final res = await getIt<ProductRepo>().getNewOpenStoreProducts();
  return res.fold((l) => throw l, (r) => r);
});

final fetchProductByIdProvider = FutureProvider.family
    .autoDispose<ProductDetailsModel, String>((ref, id) async {
  final res = await getIt<ProductRepo>().getProductById(id);
  return res.fold((l) => throw l, (r) => r);
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