import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heraj/features/bundles/domain/repo/bundles_repo.dart';
import 'package:heraj/features/products/data/models/product_model.dart';
import 'package:heraj/main.dart';

final fetchProductBundlesProvider = FutureProvider.family
    .autoDispose<List<ProductModel>, String>((ref, productId) async {
  final res = await getIt<BundlesRepo>().getProductBundles(productId);
  return res.fold((l) => throw l, (r) => r.data);
});

final fetchCartSuggestionsProvider = FutureProvider.family
    .autoDispose<List<ProductModel>, List<String>>((ref, productIds) async {
  if (productIds.isEmpty) return [];
  final res = await getIt<BundlesRepo>().getCartSuggestions(productIds);
  return res.fold((l) => throw l, (r) => r.data);
});

