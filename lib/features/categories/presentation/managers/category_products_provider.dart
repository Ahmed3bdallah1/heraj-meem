import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heraj_meem/features/categories/domain/repo/categories_repo.dart';
import 'package:heraj_meem/features/store/data/models/open_store_model.dart';
import 'package:heraj_meem/features/store/domain/repo/stores_repo.dart';
import '../../../../main.dart';
import '../../../ads/data/models/product_model.dart';
import '../../../ads/domain/repo/product_repo.dart';

// final fetchCategoryProductsProvider = FutureProvider.family
//     .autoDispose<ProductPaginatedModel, String>((ref, id) async {
//   final res = await getIt<ProductRepo>().getCategoryProducts(id);
//   return res.fold((l) => throw l, (r) => r);
// });

class AllCategoryProductsNotifier
    extends StateNotifier<AsyncValue<List<ProductModel>>> {
  final String catId;

  AllCategoryProductsNotifier(this._repo, this.catId)
      : super(const AsyncValue.loading()) {
    fetchNextPage();
  }

  final ProductRepo _repo;
  int _page = 1;
  int _totalPages = 1;
  bool _hasMore = true;
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  bool isLastPage() {
    return _page >= _totalPages;
  }

  Future<void> fetchNextPage() async {
    if (_isLoading || !_hasMore) return;

    _isLoading = true;
    try {
      final res = await _repo.getCategoryProducts(catId, _page);
      res.fold(
        (l) => state = AsyncValue.error(l, StackTrace.current),
        (r) {
          final old = state.value ?? [];
          final newList = [...old, ...r.data];
          _totalPages = r.pagination?.totalPages ?? 1;
          state = AsyncValue.data(newList);

          if (r.data.isEmpty) {
            _hasMore = false;
          } else {
            _page++;
          }
        },
      );
    } finally {
      _isLoading = false;
    }
  }
}

final fetchCategoryProductsProvider = StateNotifierProvider.family<
    AllCategoryProductsNotifier,
    AsyncValue<List<ProductModel>>,
    String>((ref, catId) {
  return AllCategoryProductsNotifier(getIt<ProductRepo>(), catId);
});

final fetchCategoryDetailsProvider = FutureProvider.autoDispose
    .family<StoreCategoryDetailsModel, String>((ref, catId) async {
  final res = await getIt<CategoriesRepo>().getCategoryDetails(catId);
  return res.fold((l) => throw l, (r) => r);
});

/// Similar products for admin products: uses store-page/category/{catId} (existing endpoint).
/// Excludes [excludeProductId] from the list.
final similarProductsFromStoreCategoryProvider = FutureProvider.autoDispose
    .family<List<ProductModel>, ({String categoryId, String excludeProductId})>(
        (ref, params) async {
  final res = await getIt<StoresRepo>()
      .getOpenStoreCategoryProducts(params.categoryId, 1, {});
  return res.fold(
    (l) => <ProductModel>[],
    (r) => r.products.where((p) => p.id != params.excludeProductId).toList(),
  );
});
