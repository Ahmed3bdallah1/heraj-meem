import 'package:fpdart/fpdart.dart';
import 'package:heraj_meem/core/errors/failure.dart';
import 'package:heraj_meem/core/use_cases/use_case.dart';
import 'package:heraj_meem/features/vendor/data/models/vendor_profile_model.dart';
import '../repo/vendor_repo.dart';

class GetVendorProfileUseCase extends UseCaseNoParam<VendorProfileModel> {
  final VendorRepo vendorRepo;

  GetVendorProfileUseCase(this.vendorRepo);

  @override
  Future<Either<Failure, VendorProfileModel>> call([void param]) {
    return vendorRepo.getVendorProfile();
  }
}

