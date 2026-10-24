import 'package:heraj_meem/config/api_path.dart';
import 'package:heraj_meem/core/service/webservice/dio_helper.dart';
import 'package:heraj_meem/features/search/domain/entities/search_ads_page.dart';

abstract class BahoSearchDataSource {
  Future<SearchAdsPage> searchAds(SearchAdsParam param);
}

class BahoSearchDataSourceImpl extends BahoSearchDataSource {
  BahoSearchDataSourceImpl({required this.api});

  final ApiService api;

  @override
  Future<SearchAdsPage> searchAds(SearchAdsParam param) async {
    final query = param.toJson().entries
        .map((entry) =>
            '${entry.key}=${Uri.encodeQueryComponent(entry.value.toString())}')
        .join('&');
    final data = await api.get(
      url: '${ApiPath.searchAds}?$query',
      returnDataOnly: true,
    );
    if (data is! Map) return const SearchAdsPage(items: [], hasMore: false);
    return SearchAdsPage.fromJson(Map<String, dynamic>.from(data));
  }
}
