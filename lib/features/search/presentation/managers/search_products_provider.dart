import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heraj_meem/features/products/data/models/product_model.dart';
import 'package:heraj_meem/features/products/domain/repo/product_repo.dart';
import 'package:heraj_meem/features/search/presentation/managers/search_filter_notifier.dart';
import '../../../../main.dart';

class SearchProductsNotifier extends StateNotifier<AsyncValue<List<ProductModel>>> {
  final Map<String, dynamic> filter;

  SearchProductsNotifier(this._repo, this.filter)
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
      final res = await _repo.getAllProducts({...filter,"page": _page});
      res.fold(
        (l) => state = AsyncValue.error(l, StackTrace.current),
        (r) {
          final old = state.value ?? [];
          final newList = [...old, ...r.data];
          _totalPages = r.meta?.lastPage ?? 1;
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

final searchProductNotifierProvider = StateNotifierProvider<SearchProductsNotifier, AsyncValue<List<ProductModel>>>((ref) {
  final attributes = ref.watch(searchFilterProvider);
  return SearchProductsNotifier(getIt<ProductRepo>(), attributes);
});
