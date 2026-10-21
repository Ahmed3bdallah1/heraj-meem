import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../../domain/entities/rate_vendor_request.dart';
import '../../domain/repo/rate_vendor_repo.dart';
import '../data_source/rate_vendor_data_source.dart';

class RateVendorRepoImp extends RateVendorRepo {
  final RateVendorDataSource dataSource;

  RateVendorRepoImp({required this.dataSource});

  @override
  Future<Either<Failure, bool>> rateVendor(RateVendorRequest request) async {
    try {
      await dataSource.rateVendor(request);
      return const Right(true);
    } catch (error) {
      if (error is DioException) return Left(ServerFailure.fromDioError(error));
      return Left(GeneralError(error));
    }
  }
}
