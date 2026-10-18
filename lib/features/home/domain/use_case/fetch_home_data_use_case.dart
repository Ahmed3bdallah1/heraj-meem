import 'package:fpdart/fpdart.dart';
import 'package:heraj/features/home/data/models/home_data_model.dart';
import 'package:heraj/features/home/domain/repositories/home_repo.dart';
import '../../../../../core/errors/failure.dart';
import '../../../../../core/use_cases/use_case.dart';

class FetchHomeDataUseCase extends UseCaseNoParam<HomeDataModel> {
  final HomeRepo homeRepo;

  FetchHomeDataUseCase({required this.homeRepo});

  @override
  Future<Either<Failure, HomeDataModel>> call([void param]) async {
    final res = await homeRepo.getHomeData();
    return res;
  }
}

