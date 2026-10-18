import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/repo/bundles_repo.dart';
import '../data_source/bundles_data_source.dart';
import '../../../products/data/models/product_model.dart';

class BundlesRepoImp extends BundlesRepo {
  final BundlesDataSource bundlesDataSource;

  BundlesRepoImp({required this.bundlesDataSource});

  @override
  Future<Either<Failure, ProductPaginatedModel>> getProductBundles(
      String productId) async {
    try {
      final bundles = await bundlesDataSource.getProductBundles(productId);
      return Right(bundles);
    } catch (e) {
      if (e is DioException) {
        return Left(ServerFailure.fromDioError(e));
      } else {
        return Left(GeneralError(e));
      }
    }
  }

  @override
  Future<Either<Failure, ProductPaginatedModel>> getCartSuggestions(
      List<String> productIds) async {
    try {
      final suggestions = await bundlesDataSource.getCartSuggestions(productIds);
      return Right(suggestions);
    } catch (e) {
      if (e is DioException) {
        return Left(ServerFailure.fromDioError(e));
      } else {
        return Left(GeneralError(e));
      }
    }
  }
}

