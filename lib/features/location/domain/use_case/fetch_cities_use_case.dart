import 'package:fpdart/fpdart.dart';
import 'package:heraj_meem/core/errors/failure.dart';
import 'package:heraj_meem/core/use_cases/use_case.dart';
import 'package:heraj_meem/features/location/data/models/city_model.dart';
import 'package:heraj_meem/features/location/domain/repo/location_repo.dart';

class FetchCitiesUseCase extends UseCaseNoParam<CitiesResponse> {
  final LocationRepo _locationRepo;

  FetchCitiesUseCase(this._locationRepo);

  @override
  Future<Either<Failure, CitiesResponse>> call() {
    return _locationRepo.getCities();
  }
}

