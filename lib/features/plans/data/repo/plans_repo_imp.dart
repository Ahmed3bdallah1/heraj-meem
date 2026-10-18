import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/repo/plans_repo.dart';
import '../data_source/plans_data_source.dart';
import '../models/plans_model.dart';

class PlansRepoImp extends PlansRepo {
  final PlansDataSource dataSource;

  PlansRepoImp({required this.dataSource});

  @override
  Future<Either<Failure, List<PlanModel>>> getPlans() async {
    try {
      final res = await dataSource.getPlans();
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
  Future<Either<Failure, MySubscriptionModel>> getMySubscription() async {
    try {
      final res = await dataSource.getMySubscription();
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