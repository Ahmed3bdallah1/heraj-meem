import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../../core/errors/failure.dart';
import '../../domain/repositories/home_repo.dart';
import '../data_source/home_data_source.dart';
import '../models/home_data_model.dart';

class HomeRepoImp extends HomeRepo {
  final HomeDataSource homeDataSource;

  HomeRepoImp({required this.homeDataSource});

  @override
  Future<Either<Failure, HomeDataModel>> getHomeData() async {
    try {
      final res = await homeDataSource.getHomeData();
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

