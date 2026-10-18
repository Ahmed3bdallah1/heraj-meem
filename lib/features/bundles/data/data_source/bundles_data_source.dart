import 'package:heraj_meem/core/service/webservice/dio_helper.dart';
import 'package:heraj_meem/features/products/data/models/product_model.dart';
import '../../../../config/api_path.dart';

abstract class BundlesDataSource {
  Future<ProductPaginatedModel> getProductBundles(String productId);
  Future<ProductPaginatedModel> getCartSuggestions(List<String> productIds);
}

class BundlesDataSourceImpl extends BundlesDataSource {
  final ApiService apiService;

  BundlesDataSourceImpl({required this.apiService});

  @override
  Future<ProductPaginatedModel> getProductBundles(String productId) async {
    final res = await apiService.get(
      url: ApiPath.getProductBundles(productId),
      returnDataOnly: true,
    );
    if (res['bundles'] != null && res['bundles'] is List) {
      final bundlesList = (res['bundles'] as List)
          .map((e) {
            try {
              return ProductModel.fromJson(
                  e is Map<String, dynamic> ? e : {});
            } catch (e) {
              return null;
            }
          })
          .whereType<ProductModel>()
          .toList();
      
      return ProductPaginatedModel(
        success: true,
        data: bundlesList,
        pagination: Pagination(
          page: 1,
          limit: bundlesList.length,
          total: bundlesList.length,
          totalPages: 1,
          hasMore: false,
        ),
      );
    }
    return ProductPaginatedModel(
      success: true,
      data: [],
      pagination: Pagination(
        page: 1,
        limit: 0,
        total: 0,
        totalPages: 0,
        hasMore: false,
      ),
    );
  }

  @override
  Future<ProductPaginatedModel> getCartSuggestions(List<String> productIds) async {
    final res = await apiService.post(
      url: ApiPath.getCartSuggestions,
      requestBody: {
        'productIds': productIds,
      },
      returnDataOnly: true,
    );
    if (res['bundles'] != null && res['bundles'] is List) {
      final bundlesList = (res['bundles'] as List)
          .map((e) {
            try {
              return ProductModel.fromJson(
                  e is Map<String, dynamic> ? e : {});
            } catch (e) {
              return null;
            }
          })
          .whereType<ProductModel>()
          .toList();
      
      return ProductPaginatedModel(
        success: true,
        data: bundlesList,
        pagination: Pagination(
          page: 1,
          limit: bundlesList.length,
          total: bundlesList.length,
          totalPages: 1,
          hasMore: false,
        ),
      );
    }
    return ProductPaginatedModel(
      success: true,
      data: [],
      pagination: Pagination(
        page: 1,
        limit: 0,
        total: 0,
        totalPages: 0,
        hasMore: false,
      ),
    );
  }
}

