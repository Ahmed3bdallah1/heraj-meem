import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heraj_meem/features/ads/data/models/product_model.dart';
import 'package:heraj_meem/features/search/domain/entities/search_ads_page.dart';
import 'package:heraj_meem/features/search/domain/use_case/search_ads_use_case.dart';
import 'package:heraj_meem/main.dart';

class BahoSearchNotifier
    extends AutoDisposeFamilyAsyncNotifier<List<ProductModel>, String> {
  static const _limit = 20;

  String _query = '';
  int _nextPage = 1;
  bool _hasMore = false;
  bool _loadingMore = false;
  int _generation = 0;

  bool isLastPage() => !_hasMore;

  @override
  Future<List<ProductModel>> build(String query) {
    _query = query.trim();
    return _loadFirst();
  }

  Future<void> search(String query) async {
    _query = query.trim();
    final generation = ++_generation;
    _nextPage = 1;
    _hasMore = false;
    _loadingMore = false;
    state = const AsyncLoading();
    try {
      if (_query.isEmpty) {
        if (generation != _generation) return;
        state = const AsyncData([]);
        return;
      }
      final page = await _fetch(1);
      if (generation != _generation) return;
      _hasMore = page.hasMore && page.items.isNotEmpty;
      _nextPage = 2;
      state = AsyncData(page.items);
    } catch (error, stack) {
      if (generation != _generation) return;
      state = AsyncError(error, stack);
    }
  }

  Future<void> fetchNextPage() async {
    if (_loadingMore || !_hasMore || _query.isEmpty) return;
    _loadingMore = true;
    final generation = _generation;
    try {
      final page = await _fetch(_nextPage);
      if (generation != _generation) return;
      final current = state.value ?? const <ProductModel>[];
      final seen = current.map((item) => item.id).toSet();
      final fresh = page.items.where((item) => seen.add(item.id)).toList();
      if (fresh.isEmpty) {
        _hasMore = false;
        return;
      }
      _hasMore = page.hasMore;
      _nextPage++;
      state = AsyncData([...current, ...fresh]);
    } finally {
      if (generation == _generation) _loadingMore = false;
    }
  }

  Future<List<ProductModel>> _loadFirst() async {
    _generation++;
    _nextPage = 1;
    _hasMore = false;
    _loadingMore = false;
    if (_query.isEmpty) return const [];
    final page = await _fetch(1);
    _hasMore = page.hasMore && page.items.isNotEmpty;
    _nextPage = 2;
    return page.items;
  }

  Future<SearchAdsPage> _fetch(int page) async {
    final result = await getIt<SearchAdsUseCase>().call(
      SearchAdsParam(query: _query, page: page, limit: _limit),
    );
    return result.fold((failure) => throw failure, (page) => page);
  }
}

final bahoSearchProvider = AsyncNotifierProvider.autoDispose
    .family<BahoSearchNotifier, List<ProductModel>, String>(
  BahoSearchNotifier.new,
);
