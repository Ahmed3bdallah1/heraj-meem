import 'package:fpdart/fpdart.dart';
import 'package:heraj_meem/core/errors/failure.dart';
import 'package:heraj_meem/features/products/data/models/product_model.dart';
import 'package:heraj_meem/features/vendor/data/models/vendor_profile_model.dart';

abstract class VendorRepo {
  Future<Either<Failure, VendorProfileModel>> getVendorProfile();
  Future<Either<Failure, ProductPaginatedModel>> getMyProducts({
    String? status,
    int page = 1,
    int limit = 20,
    String? search,
  });
}

