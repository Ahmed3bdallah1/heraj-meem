import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:heraj_meem/core/errors/failure.dart';
import 'package:heraj_meem/features/products/data/models/product_model.dart';
import 'package:heraj_meem/features/vendor/data/data_source/vendor_data_source.dart';
import 'package:heraj_meem/features/vendor/data/models/vendor_profile_model.dart';
import '../../domain/repo/vendor_repo.dart';

class VendorRepoImp implements VendorRepo {
  final VendorDataSource vendorDataSource;

  VendorRepoImp({required this.vendorDataSource});

  @override
  Future<Either<Failure, VendorProfileModel>> getVendorProfile() async {
    try {
      final profile = await vendorDataSource.getVendorProfile();
      return Right(profile);
    } catch (e) {
      if (e is DioException) {
        return Left(ServerFailure.fromDioError(e));
      } else {
        return Left(GeneralError(e));
      }
    }
  }

  @override
  Future<Either<Failure, ProductPaginatedModel>> getMyProducts({
    String? status,
    int page = 1,
    int limit = 20,
    String? search,
  }) async {
    try {
      final products = await vendorDataSource.getMyProducts(
        status: status,
        page: page,
        limit: limit,
        search: search,
      );
      return Right(products);
    } catch (e) {
      if (e is DioException) {
        return Left(ServerFailure.fromDioError(e));
      } else {
        return Left(GeneralError(e));
      }
    }
  }
}

