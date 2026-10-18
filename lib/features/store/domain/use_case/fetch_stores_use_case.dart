import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/use_cases/use_case.dart';
import '../../data/models/open_store_model.dart';
import '../../data/models/store_details_model.dart';
import '../../data/models/store_model.dart';
import '../repo/stores_repo.dart';

class FetchStoresUseCase extends UseCaseParam<StorePaginatedModel, Map<String, dynamic>> {
  final StoresRepo storesRepo;

  FetchStoresUseCase(this.storesRepo);

  @override
  Future<Either<Failure, StorePaginatedModel>> call(
      Map<String, dynamic> param) {
    return storesRepo.getAllStores(param);
  }
}

class FetchStoreDetailsUseCase extends UseCaseParam<StoreDetailsModel, String> {
  final StoresRepo storesRepo;

  FetchStoreDetailsUseCase(this.storesRepo);

  @override
  Future<Either<Failure, StoreDetailsModel>> call(String param) {
    return storesRepo.getStoreById(param);
  }
}

class FetchStorePageUseCase extends UseCaseNoParam<OpenStoreModel> {
  final StoresRepo storesRepo;

  FetchStorePageUseCase(this.storesRepo);

  @override
  Future<Either<Failure, OpenStoreModel>> call() {
    return storesRepo.getStorePage();
  }
}
