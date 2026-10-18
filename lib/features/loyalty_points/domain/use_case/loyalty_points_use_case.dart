import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/use_cases/use_case.dart';
import '../../data/models/loyalty_points_model.dart';
import '../repo/loyalty_points_repo.dart';

class FetchLoyaltyPointsUseCase extends UseCaseNoParam<LoyaltyPointsModel> {
  final LoyaltyPointsRepo loyaltyPointsRepo;

  FetchLoyaltyPointsUseCase(this.loyaltyPointsRepo);

  @override
  Future<Either<Failure, LoyaltyPointsModel>> call() {
    return loyaltyPointsRepo.getLoyaltyPoints();
  }
}


