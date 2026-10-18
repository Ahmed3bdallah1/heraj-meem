import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:heraj/features/products/data/models/product_model.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/repo/favorites_repo.dart';
import '../data_source/favorites_data_source.dart';

class FavoritesRepoImp extends FavoritesRepo {
  final FavoritesDataSource favoritesDataSource;

  FavoritesRepoImp({required this.favoritesDataSource});

  @override
  Future<Either<Failure, bool>> addOrDeleteFavorite(
      {required String productId}) async {
    try {
      final result = await favoritesDataSource.addOrDeleteFavorites(productId: productId);
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
  Future<Either<Failure, List<ProductModel>>> getFavorites() async {
    try {
      final result = await favoritesDataSource.getFavorites();
      return Right(result);
    } catch (e) {
      if (e is DioException) {
        return Left(ServerFailure.fromDioError(e));
      } else {
        return Left(GeneralError(e));
      }
    }
  }
}
