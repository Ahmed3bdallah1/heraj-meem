import 'package:fpdart/fpdart.dart';
import 'package:heraj_meem/features/products/data/models/product_model.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/use_cases/use_case.dart';
import '../repo/favorites_repo.dart';

class FetchFavoritesUseCase extends UseCaseNoParam<List<ProductModel>> {
  final FavoritesRepo favoritesRepo;

  FetchFavoritesUseCase(this.favoritesRepo);

  @override
  Future<Either<Failure, List<ProductModel>>> call() {
    return favoritesRepo.getFavorites();
  }
}

class AddOrDeleteFavoritesUseCase extends UseCaseParam<bool, String> {
  final FavoritesRepo favoritesRepo;

  AddOrDeleteFavoritesUseCase(this.favoritesRepo);

  @override
  Future<Either<Failure, bool>> call([String? param]) {
    return favoritesRepo.addOrDeleteFavorite(
      productId: param ?? "",
    );
  }
}
