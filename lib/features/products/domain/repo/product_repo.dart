import 'package:fpdart/fpdart.dart';
import 'package:heraj_meem/core/errors/failure.dart';
import '../../data/models/product_details_model.dart';
import '../../data/models/product_model.dart';
import '../../data/models/product_quota_model.dart';
import '../../data/models/review_model.dart';

abstract class ProductRepo {
  Future<Either<Failure, ProductPaginatedModel>> getCategoryProducts(
      String categoryId,int page);

  Future<Either<Failure, ProductDetailsModel>> getProductById(String productId);

  Future<Either<Failure, ProductPaginatedModel>> getAllProducts(Map map);

  Future<Either<Failure, ProductPaginatedModel>> getNewOpenStoreProducts();

  Future<Either<Failure, ProductReviewsModel>> getProductReviews(
      String productId);

  Future<Either<Failure, ProductPaginatedModel>> searchProducts(String query);

  Future<Either<Failure, Map<String, dynamic>>> createProduct(
      Map<String, dynamic> data);

  Future<Either<Failure, Map<String, dynamic>>> updateProduct(
      String productId, Map<String, dynamic> data);

  Future<Either<Failure, void>> reviewHelpful(String reviewId);
  
  Future<Either<Failure, void>> addReview(String productId, int rating, String comment, List<String> images);

  Future<Either<Failure, ProductQuotaModel>> getMyQuota();
}
