import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heraj_meem/config/api_path.dart';
import 'package:heraj_meem/core/service/webservice/dio_helper.dart';
import 'package:heraj_meem/features/ads/data/models/product_model.dart';
import 'package:heraj_meem/features/categories/data/models/main_category_model.dart';
import 'package:heraj_meem/features/home/data/models/baho_feed.dart';
import 'package:heraj_meem/main.dart';

final bahoPlaceProvider = StateProvider<BahoPlace?>((ref) => null);
final photosOnlyProvider = StateProvider<bool>((ref) => false);
final homeCategorySlugProvider = StateProvider<String?>((ref) => null);
final homeSearchQueryProvider = StateProvider<String>((ref) => '');

final bahoCategoriesProvider =
    FutureProvider.autoDispose<List<BahoCategory>>((ref) async {
  final api = getIt<ApiService>();
  final data = await api.get(
    url: ApiPath.getCategories,
    returnDataOnly: true,
  );
  final list = data is List ? data : const [];
  return list
      .whereType<Map>()
      .map((item) => BahoCategory.fromJson(Map<String, dynamic>.from(item)))
      .where((item) => item.id.isNotEmpty)
      .toList();
});

final bahoCategoryModelsProvider =
    FutureProvider.autoDispose<List<CategoryModel>>((ref) async {
  final items = await ref.watch(bahoCategoriesProvider.future);
  return items.map((item) => item.toCategoryModel()).toList();
});

final bahoFeaturedAdsProvider =
    FutureProvider.autoDispose<List<BahoAd>>((ref) async {
  final api = getIt<ApiService>();
  final data = await api.get(
    url: '${ApiPath.getAds}?page=1&limit=20&sort=newest',
    returnDataOnly: true,
  );
  final items = data is Map ? data['items'] : null;
  if (items is! List) return const [];
  return items
      .whereType<Map>()
      .map((item) => BahoAd.fromJson(Map<String, dynamic>.from(item)))
      .where((ad) => ad.isFeatured)
      .toList();
});

class BahoAdsNotifier extends AutoDisposeAsyncNotifier<List<ProductModel>> {
  static const _limit = 20;

  int _nextPage = 1;
  bool _hasMore = false;
  bool _loadingMore = false;
  int _generation = 0;
  BahoPlace? _place;
  bool _photosOnly = false;
  String? _category;
  String _query = '';

  bool isLastPage() => !_hasMore;

  @override
  Future<List<ProductModel>> build() async {
    _generation++;
    _nextPage = 1;
    _hasMore = false;
    _loadingMore = false;
    _place = ref.watch(bahoPlaceProvider);
    _photosOnly = ref.watch(photosOnlyProvider);
    _category = ref.watch(homeCategorySlugProvider);
    _query = ref.watch(homeSearchQueryProvider).trim();
    final page = await _load(1);
    _hasMore = page.hasMore && page.items.isNotEmpty;
    _nextPage = 2;
    return page.items;
  }

  Future<void> fetchNextPage() async {
    if (_loadingMore || !_hasMore) return;
    _loadingMore = true;
    final generation = _generation;
    try {
      final page = await _load(_nextPage);
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

  Future<_AdsPage> _load(int page) {
    return _fetchAdsPage(
      page: page,
      limit: _limit,
      place: _place,
      photosOnly: _photosOnly,
      category: _category,
      query: _query,
    );
  }
}

final bahoAdsProvider =
    AsyncNotifierProvider.autoDispose<BahoAdsNotifier, List<ProductModel>>(
  BahoAdsNotifier.new,
);

class _AdsPage {
  const _AdsPage({required this.items, required this.hasMore});

  final List<ProductModel> items;
  final bool hasMore;
}

Future<_AdsPage> _fetchAdsPage({
  required int page,
  required int limit,
  required BahoPlace? place,
  required bool photosOnly,
  required String? category,
  required String query,
}) async {
  final params = <String, String>{
    'page': '$page',
    'limit': '$limit',
    'sort': 'newest',
    if (place != null && place.citySlug.isNotEmpty) 'city': place.citySlug,
    if (photosOnly) 'hasMedia': 'true',
    if (category != null && category.isNotEmpty) 'category': category,
    if (query.isNotEmpty) 'q': query,
  };
  final queryString = params.entries
      .map((entry) => '${entry.key}=${Uri.encodeQueryComponent(entry.value)}')
      .join('&');
  final path = query.isNotEmpty
      ? 'search?$queryString'
      : '${ApiPath.getAds}?$queryString';
  final data = await getIt<ApiService>().get(url: path, returnDataOnly: true);
  if (data is! Map) return const _AdsPage(items: [], hasMore: false);
  final rawItems = data['items'];
  final items = rawItems is List
      ? rawItems
          .whereType<Map>()
          .map((item) => ProductModel.fromJson(Map<String, dynamic>.from(item)))
          .where((ad) => ad.id.isNotEmpty)
          .toList()
      : <ProductModel>[];
  final total = data['total'] is num ? (data['total'] as num).toInt() : 0;
  final pageNumber = data['page'] is num ? (data['page'] as num).toInt() : page;
  final pageLimit =
      data['limit'] is num ? (data['limit'] as num).toInt() : limit;
  final hasMore = data['hasMore'] == true ||
      (data['hasMore'] == null && total > 0 && pageNumber * pageLimit < total);
  return _AdsPage(items: items, hasMore: hasMore);
}

final bahoRegionsProvider =
    FutureProvider.autoDispose<List<BahoRegion>>((ref) async {
  final api = getIt<ApiService>();
  final data = await api.get(url: ApiPath.getRegions, returnDataOnly: true);
  final list = data is List ? data : const [];
  return list
      .whereType<Map>()
      .map((item) => BahoRegion.fromJson(Map<String, dynamic>.from(item)))
      .toList();
});

final bahoCitiesProvider = FutureProvider.autoDispose
    .family<List<BahoCity>, String>((ref, regionId) async {
  final api = getIt<ApiService>();
  final data = await api.get(
    url: '${ApiPath.getCities}?regionId=$regionId',
    returnDataOnly: true,
  );
  final list = data is List
      ? data
      : data is Map && data['cities'] is List
          ? data['cities'] as List
          : const [];
  return list
      .whereType<Map>()
      .map((item) => BahoCity.fromJson(Map<String, dynamic>.from(item)))
      .toList();
});

final bahoDistrictsProvider = FutureProvider.autoDispose
    .family<List<BahoDistrict>, String>((ref, cityId) async {
  final api = getIt<ApiService>();
  final data = await api.get(
    url: ApiPath.getCityDistricts(cityId),
    returnDataOnly: true,
  );
  final list = data is List
      ? data
      : data is Map && data['districts'] is List
          ? data['districts'] as List
          : const [];
  return list
      .whereType<Map>()
      .map((item) => BahoDistrict.fromJson(Map<String, dynamic>.from(item)))
      .toList();
});

Future<List<String>> fetchSearchSuggestions(String query) async {
  if (query.trim().isEmpty) return const [];
  final api = getIt<ApiService>();
  final data = await api.get(
    url:
        '${ApiPath.searchSuggestions}?q=${Uri.encodeQueryComponent(query)}&limit=8',
    returnDataOnly: true,
  );
  final raw = data is Map && data['ads'] is List
      ? data['ads'] as List
      : data is List
          ? data
          : const [];
  return raw
      .map((item) {
        if (item is String) return item;
        if (item is Map) {
          return item['title']?.toString() ??
              item['name']?.toString() ??
              item['nameAr']?.toString() ??
              '';
        }
        return '';
      })
      .where((item) => item.isNotEmpty)
      .toList();
}

Future<void> saveUserPlace(BahoPlace place) async {
  final api = getIt<ApiService>();
  await api.patch(
    url: ApiPath.updateUserMe,
    requestBody: {
      'cityId': place.cityId,
      'regionId': place.regionId,
    },
    returnDataOnly: false,
  );
}
