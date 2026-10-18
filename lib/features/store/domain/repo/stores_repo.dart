import 'package:fpdart/fpdart.dart';
import 'package:heraj_meem/core/errors/failure.dart';
import 'package:heraj_meem/features/products/data/models/product_model.dart';
import '../../data/models/open_store_model.dart';
import '../../data/models/store_details_model.dart';
import '../../data/models/store_model.dart';

abstract class StoresRepo {
  Future<Either<Failure, StorePaginatedModel>> getAllStores(
      Map<String, dynamic> params);

  Future<Either<Failure, StoreDetailsModel>> getStoreById(String vendorId);

  Future<Either<Failure, ProductPaginatedModel>> getStoreProducts(
      String vendorId,
      {int page = 1,
      int limit = 20});

  Future<Either<Failure, OpenStoreModel>> getStorePage();

  Future<Either<Failure, StorePageSection>> getOpenStoreCategoryProducts(
      String catId, int page, Map<String, dynamic> queryParams);

  Future<Either<Failure, StoreCategoryDetailsModel>> getStoreCategoryDetails(
      String catId);
}
