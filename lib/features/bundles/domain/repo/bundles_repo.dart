import 'package:fpdart/fpdart.dart';
import 'package:heraj_meem/core/errors/failure.dart';
import '../../../products/data/models/product_model.dart';

abstract class BundlesRepo {
  Future<Either<Failure, ProductPaginatedModel>> getProductBundles(
      String productId);
  Future<Either<Failure, ProductPaginatedModel>> getCartSuggestions(
      List<String> productIds);
}

