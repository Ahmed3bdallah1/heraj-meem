import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../../data/models/loyalty_points_model.dart';

abstract class LoyaltyPointsRepo {
  Future<Either<Failure, LoyaltyPointsModel>> getLoyaltyPoints();
}


