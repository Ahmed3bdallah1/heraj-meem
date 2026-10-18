import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/repo/loyalty_points_repo.dart';
import '../data_source/loyalty_points_data_source.dart';
import '../models/loyalty_points_model.dart';

class LoyaltyPointsRepoImp extends LoyaltyPointsRepo {
  final LoyaltyPointsDataSource loyaltyPointsDataSource;

  LoyaltyPointsRepoImp({required this.loyaltyPointsDataSource});

  @override
  Future<Either<Failure, LoyaltyPointsModel>> getLoyaltyPoints() async {
    try {
      final result = await loyaltyPointsDataSource.getLoyaltyPoints();
      return Right(result);
    } catch (e) {
      if (e is DioException) {
        return Left(ServerFailure.fromDioError(e));
      } else {
        return Left(GeneralError(e));
      }
    }
  }
}


