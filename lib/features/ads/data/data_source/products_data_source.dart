import 'package:heraj_meem/core/service/webservice/dio_helper.dart';
import 'package:heraj_meem/features/ads/data/models/product_details_model.dart';
import 'package:heraj_meem/features/ads/data/models/product_model.dart';
import 'package:heraj_meem/features/ads/data/models/product_quota_model.dart';
import 'package:heraj_meem/features/ads/data/models/review_model.dart';
import '../../../../config/api_path.dart';

abstract class ProductsDataSource {
  Future<ProductPaginatedModel> getCategoryProducts(
      String categoryId, int page);

  Future<ProductDetailsModel> getProductById(String productId);

  Future<ProductReviewsModel> getProductReviews(String productId);

  Future<ProductPaginatedModel> getAllProducts(Map map);

  Future<ProductPaginatedModel> searchProducts(String query);

  Future<ProductPaginatedModel> getNewOpenStoreProducts();

  Future<Map<String, dynamic>> createProduct(Map<String, dynamic> data);

  Future<Map<String, dynamic>> updateProduct(
      String productId, Map<String, dynamic> data);

  Future<void> reviewHelpful(String reviewId);

  Future<void> addReview(String productId, Map<String, dynamic> body);

  Future<ProductQuotaModel> getMyQuota();
}

class ProductsDataSourceImpl extends ProductsDataSource {
  final ApiService apiService;

  ProductsDataSourceImpl({required this.apiService});

  @override
  Future<ProductPaginatedModel> getAllProducts(Map map) async {
    map.removeWhere((k, v) => v == null || v == "");
    String queryParam =
        map.entries.map((e) => '${e.key}=${e.value.toString()}').join('&');
    final res = await apiService.get(
      url: "${ApiPath.getAds}?$queryParam",
    );
    return ProductPaginatedModel.fromJson(res);
  }

  @override
  Future<ProductPaginatedModel> getCategoryProducts(
      String categoryId, int page) async {
    final res = await apiService.get(
      url: "${ApiPath.getAds}?category=$categoryId&page=$page&sort=newest",
    );
    return ProductPaginatedModel.fromJson(res);
  }

  @override
  Future<ProductDetailsModel> getProductById(String productId) async {
    final res = await apiService.get(
      url: ApiPath.getAd(productId),
      returnDataOnly: true,
    );
    final map = res is Map<String, dynamic>
        ? res
        : Map<String, dynamic>.from(res as Map);
    return ProductDetailsModel.fromAd(map);
  }

  @override
  Future<ProductReviewsModel> getProductReviews(String productId) async {
    final res = await apiService.get(
      url: ApiPath.getProductReviews(productId),
      queryParameters: {"page": 1, "limit": 10},
      returnDataOnly: true,
    );
    return ProductReviewsModel.fromJson(res);
  }

  @override
  Future<ProductPaginatedModel> searchProducts(String query) async {
    final res = await apiService.get(
      url: 'search?q=${Uri.encodeQueryComponent(query)}&page=1&limit=20&sort=newest',
      returnDataOnly: false,
    );
    return ProductPaginatedModel.fromJson(res);
  }

  @override
  Future<ProductPaginatedModel> getNewOpenStoreProducts() async {
    final res = await apiService.get(
      url: "${ApiPath.getAds}?page=1&limit=20&sort=newest",
    );
    return ProductPaginatedModel.fromJson(res);
  }

  @override
  Future<Map<String, dynamic>> createProduct(Map<String, dynamic> data) async {
    final res = await apiService.post(
      url: ApiPath.createProduct,
      requestBody: data,
      returnDataOnly: true,
    );
    return res as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> updateProduct(
      String productId, Map<String, dynamic> data) async {
    final res = await apiService.patch(
      url: ApiPath.updateProduct(productId),
      requestBody: data,
      returnDataOnly: true,
    );
    return res as Map<String, dynamic>;
  }

  @override
  Future<void> reviewHelpful(String reviewId) async {
    await apiService.post(
      url: ApiPath.reviewHelpful(reviewId),
      requestBody: {},
      returnDataOnly: true,
    );
  }

  @override
  Future<void> addReview(String productId, Map<String, dynamic> body) async {
    await apiService.post(
      url: ApiPath.addReview(productId),
      requestBody: body,
      returnDataOnly: true,
    );
  }

  @override
  Future<ProductQuotaModel> getMyQuota() async {
    final res = await apiService.get(
      url: "${ApiPath.getProducts}/my-quota",
      returnDataOnly: true,
    );
    return ProductQuotaModel.fromJson(res);
  }
}
