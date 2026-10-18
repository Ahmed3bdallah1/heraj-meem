import 'package:fpdart/fpdart.dart';
import 'package:heraj/core/errors/failure.dart';
import 'package:heraj/features/products/data/models/product_model.dart';
import 'package:heraj/features/vendor/data/models/vendor_profile_model.dart';

abstract class VendorRepo {
  Future<Either<Failure, VendorProfileModel>> getVendorProfile();
  Future<Either<Failure, ProductPaginatedModel>> getMyProducts({
    String? status,
    int page = 1,
    int limit = 20,
    String? search,
  });
}

