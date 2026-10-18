import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heraj_meem/features/store/domain/repo/stores_repo.dart';
import '../../../../main.dart';
import '../../../products/data/models/product_model.dart';
import '../../data/models/open_store_model.dart';
import '../../data/models/store_details_model.dart';
import '../../data/models/store_model.dart';
import '../../domain/use_case/fetch_stores_use_case.dart';

final storesFilterProvider = StateNotifierProvider.autoDispose<
    StoresFilterNotifier, Map<String, dynamic>>((ref) {
  return StoresFilterNotifier();
});

class StoresFilterNotifier extends StateNotifier<Map<String, dynamic>> {
  StoresFilterNotifier()
      : super({
          'page': 1,
          'limit': 20,
        });

  void updatePage(int page) {
    state = {...state, 'page': page};
  }

  void updateLimit(int limit) {
    state = {...state, 'limit': limit};
  }

  void updateSearch(String? search) {
    if (search == null || search.isEmpty) {
      final newState = {...state};
      newState.remove('search');
      state = newState;
    } else {
      state = {...state, 'search': search};
    }
  }

  void reset() {
    state = {'page': 1, 'limit': 20};
  }
}

class StoresNotifier extends StateNotifier<AsyncValue<StorePaginatedModel>> {
  final Map<String, dynamic> filter;

  StoresNotifier(this._useCase, this.filter)
      : super(const AsyncValue.loading()) {
    fetchStores();
  }

  final FetchStoresUseCase _useCase;

  Future<void> fetchStores() async {
    state = const AsyncValue.loading();
    try {
      final res = await _useCase.call(filter);
      res.fold(
        (l) => state = AsyncValue.error(l, StackTrace.current),
        (r) => state = AsyncValue.data(r),
      );
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> refresh() async {
    await fetchStores();
  }
}

final storesNotifierProvider = StateNotifierProvider.autoDispose<StoresNotifier,
    AsyncValue<StorePaginatedModel>>((ref) {
  final filter = ref.watch(storesFilterProvider);
  return StoresNotifier(getIt<FetchStoresUseCase>(), filter);
});

final fetchStoresFutureProvider = FutureProvider.autoDispose
    .family<StorePaginatedModel, Map<String, dynamic>>((ref, params) async {
  final res = await getIt<FetchStoresUseCase>().call(params);
  return res.fold((l) => throw l, (r) => r);
});

final fetchStoreProductsProvider = FutureProvider.autoDispose
    .family<ProductPaginatedModel, String>((ref, vendorId) async {
  final res =
      await getIt<StoresRepo>().getStoreProducts(vendorId, page: 1, limit: 20);
  return res.fold((l) => throw l, (r) => r);
});

final fetchStoreDiscountedProductsProvider = FutureProvider.autoDispose
    .family<ProductPaginatedModel, String>((ref, vendorId) async {
  final res =
      await getIt<StoresRepo>().getStoreProducts(vendorId, page: 1, limit: 20);
  return res.fold(
    (l) => throw l,
    (r) {
      final discountedProducts = r.data.where((product) {
        final before =
            double.tryParse(product.beforePrice?.toString() ?? '0') ?? 0;
        final after =
            double.tryParse(product.afterPrice?.toString() ?? '0') ?? 0;
        return before > 0 && after > 0 && before > after;
      }).toList();
      return ProductPaginatedModel(
        success: r.success,
        data: discountedProducts,
        pagination: r.pagination,
      );
    },
  );
});
