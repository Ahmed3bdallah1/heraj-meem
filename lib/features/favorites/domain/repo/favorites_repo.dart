import 'package:fpdart/fpdart.dart';
import 'package:heraj_meem/features/products/data/models/product_model.dart';
import '../../../../core/errors/failure.dart';

abstract class FavoritesRepo {
  Future<Either<Failure, List<ProductModel>>> getFavorites();

  Future<Either<Failure, bool>> addOrDeleteFavorite({required String productId});
}
