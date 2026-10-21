import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../entities/rate_vendor_request.dart';

abstract class RateVendorRepo {
  Future<Either<Failure, bool>> rateVendor(RateVendorRequest request);
}
