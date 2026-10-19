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

final bahoAdsProvider =
    FutureProvider.autoDispose<List<ProductModel>>((ref) async {
  final place = ref.watch(bahoPlaceProvider);
  final photosOnly = ref.watch(photosOnlyProvider);
  final category = ref.watch(homeCategorySlugProvider);
  final query = ref.watch(homeSearchQueryProvider).trim();
  final api = getIt<ApiService>();

  final params = <String, String>{
    'page': '1',
    'limit': '20',
    'sort': 'newest',
    if (place != null && place.citySlug.isNotEmpty) 'city': place.citySlug,
    if (photosOnly) 'hasMedia': 'true',
    if (category != null && category.isNotEmpty) 'category': category,
    if (query.isNotEmpty) 'q': query,
  };
  final queryString = params.entries
      .map((entry) => '${entry.key}=${Uri.encodeQueryComponent(entry.value)}')
      .join('&');
  final path = query.isNotEmpty ? 'search?$queryString' : '${ApiPath.getAds}?$queryString';
  final data = await api.get(url: path, returnDataOnly: true);
  final items = data is Map ? data['items'] : null;
  if (items is! List) return const [];
  return items
      .whereType<Map>()
      .map((item) => ProductModel.fromJson(Map<String, dynamic>.from(item)))
      .where((ad) => ad.id.isNotEmpty)
      .toList();
});

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
    url: '${ApiPath.searchSuggestions}?q=${Uri.encodeQueryComponent(query)}&limit=8',
    returnDataOnly: true,
  );
  final raw = data is Map && data['ads'] is List
      ? data['ads'] as List
      : data is List
          ? data
          : const [];
  return raw.map((item) {
    if (item is String) return item;
    if (item is Map) {
      return item['title']?.toString() ??
          item['name']?.toString() ??
          item['nameAr']?.toString() ??
          '';
    }
    return '';
  }).where((item) => item.isNotEmpty).toList();
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
