import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heraj_meem/features/products/data/models/product_model.dart';
import 'package:heraj_meem/features/store/domain/repo/stores_repo.dart';
import '../../../../main.dart';
import '../../data/models/open_store_model.dart';
import '../../domain/use_case/fetch_stores_use_case.dart';

final fetchStorePageProvider =
    FutureProvider.autoDispose<OpenStoreModel>((ref) async {
  final res = await getIt<FetchStorePageUseCase>().call();
  return res.fold((l) => throw l, (r) => r);
});

final fetchStoreCategoryDetailsProvider = FutureProvider.autoDispose
    .family<StoreCategoryDetailsModel, String>((ref, catId) async {
  final res = await getIt<StoresRepo>().getStoreCategoryDetails(catId);
  return res.fold((l) => throw l, (r) => r);
});

final fetchCatProductsNotifierProvider = StateNotifierProvider.family<
    ProductsNotifier, AsyncValue<List<ProductModel>>, String>((ref, catId) {
  return ProductsNotifier(getIt<StoresRepo>(), catId);
});

class ProductsNotifier extends StateNotifier<AsyncValue<List<ProductModel>>> {
  final String catId;

  ProductsNotifier(this._repo, this.catId) : super(const AsyncValue.loading()) {
    fetchNextPage();
  }

  final StoresRepo _repo;
  int _page = 1;
  int _totalPages = 1;
  bool _hasMore = true;
  bool _isLoading = false;
  Map<String, dynamic> _filters = {};

  bool get isLoading => _isLoading;

  bool isLastPage() {
    return _page >= _totalPages;
  }

  void applyFilters(Map<String, dynamic> filters) {
    _filters = filters;
    _page = 1;
    _hasMore = true;
    state = const AsyncValue.loading();
    fetchNextPage();
  }

  Future<void> fetchNextPage() async {
    if (_isLoading || !_hasMore) return;
    _isLoading = true;
    try {
      final res = await _repo.getOpenStoreCategoryProducts(catId, _page, _filters);
      res.fold(
        (l) => state = AsyncValue.error(l, StackTrace.current),
        (r) {
          final old = _page == 1 ? <ProductModel>[] : (state.value ?? []);
          final newList = [...old, ...r.products];
          _totalPages = r.pagination?.totalPages ?? 0;
          state = AsyncValue.data(newList);

          if (r.products.isEmpty) {
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
