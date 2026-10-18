import 'package:dio/dio.dart';
import 'package:heraj_meem/features/home/data/data_source/partners_and_testmonial_data_source.dart';
import 'package:heraj_meem/features/home/domain/entities/partners.dart';
import 'package:heraj_meem/features/home/domain/entities/testimonials.dart';
import 'package:heraj_meem/features/home/domain/repositories/partner_repo.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';

class PartnerRepoImp extends PartnerRepo {
  final PartnersAndTestimonialDataSource partnerDataSource;

  PartnerRepoImp({required this.partnerDataSource});

  @override
  Future<Either<Failure, List<Partner>>> getPartners() async {
    try {
      final res = await partnerDataSource.getPartners();
      return Right(res);
    } catch (e) {
      if (e is DioException) {
        return Left(ServerFailure.fromDioError(e));
      } else {
        return Left(GeneralError(e));
      }
    }
  }

  @override
  Future<Either<Failure, List<Testimonials>>> getTestimonials() async {
    try {
      final res = await partnerDataSource.getTestimonials();
      return Right(res);
    } catch (e) {
      if (e is DioException) {
        return Left(ServerFailure.fromDioError(e));
      } else {
        return Left(GeneralError(e));
      }
    }
  }
}
