import 'package:fpdart/fpdart.dart';
import 'package:heraj_meem/core/errors/failure.dart';
import 'package:heraj_meem/core/use_cases/use_case.dart';
import 'package:heraj_meem/features/products/data/models/product_model.dart';
import '../repo/vendor_repo.dart';

class GetMyProductsParams {
  final String? status;
  final int page;
  final int limit;
  final String? search;

  GetMyProductsParams({
    this.status,
    this.page = 1,
    this.limit = 20,
    this.search,
  });
}

class GetMyProductsUseCase extends UseCaseParam<ProductPaginatedModel, GetMyProductsParams> {
  final VendorRepo vendorRepo;

  GetMyProductsUseCase(this.vendorRepo);

  @override
  Future<Either<Failure, ProductPaginatedModel>> call(
      GetMyProductsParams params) {
    return vendorRepo.getMyProducts(
      status: params.status,
      page: params.page,
      limit: params.limit,
      search: params.search,
    );
  }
}

