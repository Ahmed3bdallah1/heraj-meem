import 'package:fpdart/fpdart.dart';
import 'package:heraj_meem/features/home/data/models/home_data_model.dart';
import '../../../../../core/errors/failure.dart';

abstract class HomeRepo {
  Future<Either<Failure, HomeDataModel>> getHomeData();
}

