import 'package:heraj/core/service/webservice/dio_helper.dart';
import 'package:heraj/features/products/data/models/product_model.dart';
import 'package:heraj/features/store/data/models/store_model.dart';
import '../../../../config/api_path.dart';
import '../models/store_details_model.dart';
import '../models/open_store_model.dart';

abstract class StoresDataSource {
  Future<StorePaginatedModel> getAllStores(Map<String, dynamic> params);

  Future<ProductPaginatedModel> getStoreProducts(String vendorId,
      {int page = 1, int limit = 20});

  Future<StorePageSection> getOpenStoreCategoryProducts(
      String catId, int page, Map<String, dynamic> queryParams);

  Future<StoreCategoryDetailsModel> getStoreCategoryDetails(String catId);

  Future<StoreDetailsModel> getStoreById(String vendorId);

  Future<OpenStoreModel> getStorePage();
}

class StoresDataSourceImpl extends StoresDataSource {
  final ApiService apiService;

  StoresDataSourceImpl({required this.apiService});

  @override
  Future<StorePaginatedModel> getAllStores(Map<String, dynamic> params) async {
    params.removeWhere((k, v) => v == null || v == "");
    String queryParam =
        params.entries.map((e) => '${e.key}=${e.value.toString()}').join('&');
    final res = await apiService.get(
      url: "${ApiPath.getVendors}?$queryParam",
    );
    return StorePaginatedModel.fromJson(res);
  }

  @override
  Future<StoreDetailsModel> getStoreById(String vendorId) async {
    final res = await apiService.get(
      url: "${ApiPath.getVendors}/$vendorId",
      returnDataOnly: true,
    );
    return StoreDetailsModel.fromJson(res["vendor"]);
  }

  @override
  Future<ProductPaginatedModel> getStoreProducts(String vendorId,
      {int page = 1, int limit = 20}) async {
    final res = await apiService.get(
        url: ApiPath.getVendorProducts(vendorId, page: page, limit: limit));
    return ProductPaginatedModel.fromJson(res);
  }

  @override
  Future<OpenStoreModel> getStorePage() async {
    final res = await apiService.get(
      url: ApiPath.getStorePage,
      returnDataOnly: true,
    );
    return OpenStoreModel.fromJson(res);
  }

  @override
  Future<StorePageSection> getOpenStoreCategoryProducts(
      String catId, int page, Map<String, dynamic> queryParams) async {
    // Build query parameters
    final params = {...queryParams};
    params['page'] = page.toString();
    params.removeWhere((k, v) => v == null || v == '');

    final queryString =
        params.entries.map((e) => '${e.key}=${e.value}').join('&');

    final res = await apiService.get(
      url: "${ApiPath.getStoreCategoryProducts(catId)}?$queryString",
      returnDataOnly: true,
    );
    return StorePageSection.fromJson(res);
  }

  @override
  Future<StoreCategoryDetailsModel> getStoreCategoryDetails(
      String catId) async {
    final res = await apiService.get(
      url: ApiPath.getStoreCategoryDetails(catId),
    );
    // Extract data from response
    final data = res['data'] ?? res;
    return StoreCategoryDetailsModel.fromJson(data);
  }
}
