import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/use_cases/use_case.dart';
import '../entities/rate_vendor_request.dart';
import '../repo/rate_vendor_repo.dart';

class RateVendorUseCase extends UseCaseParam<bool, RateVendorRequest> {
  final RateVendorRepo repo;

  RateVendorUseCase(this.repo);

  @override
  Future<Either<Failure, bool>> call(RateVendorRequest param) {
    return repo.rateVendor(param);
  }
}
