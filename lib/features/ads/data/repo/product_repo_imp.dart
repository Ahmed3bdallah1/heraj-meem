import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/repo/product_repo.dart';
import '../data_source/products_data_source.dart';
import '../models/product_details_model.dart';
import '../models/product_model.dart';
import '../models/product_quota_model.dart';
import '../models/review_model.dart';

class ProductRepoImp extends ProductRepo {
  final ProductsDataSource productsDataSource;

  ProductRepoImp({required this.productsDataSource});

  @override
  Future<Either<Failure, ProductPaginatedModel>> getAllProducts(Map map) async {
    try {
      final products = await productsDataSource.getAllProducts(map);
      return Right(products);
    } catch (e) {
      if (e is DioException) {
        return Left(ServerFailure.fromDioError(e));
      } else {
        return Left(GeneralError(e));
      }
    }
  }

  @override
  Future<Either<Failure, ProductPaginatedModel>> getCategoryProducts(
      String categoryId,int page) async {
    try {
      final products = await productsDataSource.getCategoryProducts(categoryId,page);
      return Right(products);
    } catch (e) {
      if (e is DioException) {
        return Left(ServerFailure.fromDioError(e));
      } else {
        return Left(GeneralError(e));
      }
    }
  }

  @override
  Future<Either<Failure, ProductPaginatedModel>> getNewOpenStoreProducts() async {
    try {
      final products = await productsDataSource.getNewOpenStoreProducts();
      return Right(products);
    } catch (e) {
      if (e is DioException) {
        return Left(ServerFailure.fromDioError(e));
      } else {
        return Left(GeneralError(e));
      }
    }
  }

  @override
  Future<Either<Failure, ProductDetailsModel>> getProductById(
      String productId) async {
    try {
      final products = await productsDataSource.getProductById(productId);
      return Right(products);
    } catch (e) {
      if (e is DioException) {
        return Left(ServerFailure.fromDioError(e));
      } else {
        return Left(GeneralError(e));
      }
    }
  }

  @override
  Future<Either<Failure, ProductReviewsModel>> getProductReviews(
      String productId) async {
    try {
      final res = await productsDataSource.getProductReviews(productId);
      return Right(res);
    } catch (e) {
      if (e is DioException) {
        return Left(ServerFailure.fromDioError(e));
      } else {
        return Left(GeneralError(e));
      }
    }
  }

  @override
  Future<Either<Failure, ProductPaginatedModel>> searchProducts(
      String query) async {
    try {
      final products = await productsDataSource.searchProducts(query);
      return Right(products);
    } catch (e) {
      if (e is DioException) {
        return Left(ServerFailure.fromDioError(e));
      } else {
        return Left(GeneralError(e));
      }
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> createProduct(
      Map<String, dynamic> data) async {
    try {
      final result = await productsDataSource.createProduct(data);
      return Right(result);
    } catch (e) {
      if (e is DioException) {
        return Left(ServerFailure.fromDioError(e));
      } else {
        return Left(GeneralError(e));
      }
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> updateProduct(
      String productId, Map<String, dynamic> data) async {
    try {
      final result = await productsDataSource.updateProduct(productId, data);
      return Right(result);
    } catch (e) {
      if (e is DioException) {
        return Left(ServerFailure.fromDioError(e));
      } else {
        return Left(GeneralError(e));
      }
    }
  }

  @override
  Future<Either<Failure, void>> reviewHelpful(String reviewId) async {
    try {
      await productsDataSource.reviewHelpful(reviewId);
      return const Right(null);
    } catch (e) {
      if (e is DioException) {
        return Left(ServerFailure.fromDioError(e));
      } else {
        return Left(GeneralError(e));
      }
    }
  }

  @override
  Future<Either<Failure, void>> addReview(
      String productId, int rating, String comment, List<String> images) async {
    try {
      final body = {
        "rating": rating,
        "comment": comment,
        "images": images,
      };
      await productsDataSource.addReview(productId, body);
      return const Right(null);
    } catch (e) {
      if (e is DioException) {
        return Left(ServerFailure.fromDioError(e));
      } else {
        return Left(GeneralError(e));
      }
    }
  }

  @override
  Future<Either<Failure, ProductQuotaModel>> getMyQuota() async {
    try {
      final quota = await productsDataSource.getMyQuota();
      return Right(quota);
    } catch (e) {
      if (e is DioException) {
        return Left(ServerFailure.fromDioError(e));
      } else {
        return Left(GeneralError(e));
      }
    }
  }
}
