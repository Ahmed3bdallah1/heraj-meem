import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:heraj_meem/features/products/data/models/product_model.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/repo/stores_repo.dart';
import '../data_source/stores_data_source.dart';
import '../models/open_store_model.dart';
import '../models/store_details_model.dart';
import '../models/store_model.dart';

class StoresRepoImp extends StoresRepo {
  final StoresDataSource storesDataSource;

  StoresRepoImp({required this.storesDataSource});

  @override
  Future<Either<Failure, StorePaginatedModel>> getAllStores(
      Map<String, dynamic> params) async {
    try {
      final stores = await storesDataSource.getAllStores(params);
      return Right(stores);
    } catch (e) {
      if (e is DioException) {
        return Left(ServerFailure.fromDioError(e));
      } else {
        return Left(GeneralError(e));
      }
    }
  }

  @override
  Future<Either<Failure, StoreDetailsModel>> getStoreById(
      String vendorId) async {
    try {
      final store = await storesDataSource.getStoreById(vendorId);
      return Right(store);
    } catch (e) {
      if (e is DioException) {
        return Left(ServerFailure.fromDioError(e));
      } else {
        return Left(GeneralError(e));
      }
    }
  }

  @override
  Future<Either<Failure, ProductPaginatedModel>> getStoreProducts(
      String vendorId,
      {int page = 1,
      int limit = 20}) async {
    try {
      final store = await storesDataSource.getStoreProducts(vendorId,
          page: page, limit: limit);
      return Right(store);
    } catch (e) {
      if (e is DioException) {
        return Left(ServerFailure.fromDioError(e));
      } else {
        return Left(GeneralError(e));
      }
    }
  }

  @override
  Future<Either<Failure, OpenStoreModel>> getStorePage() async {
    try {
      final storePage = await storesDataSource.getStorePage();
      return Right(storePage);
    } catch (e) {
      if (e is DioException) {
        return Left(ServerFailure.fromDioError(e));
      } else {
        return Left(GeneralError(e));
      }
    }
  }

  @override
  Future<Either<Failure, StorePageSection>> getOpenStoreCategoryProducts(
      String catId, int page, Map<String, dynamic> queryParams) async {
    try {
      final store = await storesDataSource.getOpenStoreCategoryProducts(
          catId, page, queryParams);
      return Right(store);
    } catch (e) {
      if (e is DioException) {
        return Left(ServerFailure.fromDioError(e));
      } else {
        return Left(GeneralError(e));
      }
    }
  }

  @override
  Future<Either<Failure, StoreCategoryDetailsModel>> getStoreCategoryDetails(
      String catId) async {
    try {
      final categoryDetails =
          await storesDataSource.getStoreCategoryDetails(catId);
      return Right(categoryDetails);
    } catch (e) {
      if (e is DioException) {
        return Left(ServerFailure.fromDioError(e));
      } else {
        return Left(GeneralError(e));
      }
    }
  }
}
