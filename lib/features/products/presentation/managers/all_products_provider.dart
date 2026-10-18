import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heraj_meem/features/products/data/models/product_model.dart';
import 'package:heraj_meem/features/products/domain/repo/product_repo.dart';
import '../../../../main.dart';
import '../../../search/presentation/managers/search_filter_notifier.dart';

class AllProductsNotifier extends StateNotifier<AsyncValue<List<ProductModel>>> {
  final Map filter;

  AllProductsNotifier(this._repo, this.filter) : super(const AsyncValue.loading()) {
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
      final res = await _repo.getAllProducts({"page": _page, ...filter});
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

final allProductsNotifierProvider = StateNotifierProvider<AllProductsNotifier, AsyncValue<List<ProductModel>>>((ref) {
  final Map filter = ref.watch(searchFilterProvider);
  return AllProductsNotifier(getIt<ProductRepo>(), filter);
});
