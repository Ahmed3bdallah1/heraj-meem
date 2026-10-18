import 'package:fpdart/fpdart.dart';
import 'package:tuple/tuple.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/use_cases/use_case.dart';
import '../../data/models/cart_model.dart';
import '../../data/models/cart_item_model.dart';
import '../repo/cart_repo.dart';

class FetchCartUseCase extends UseCaseNoParam<CartModel> {
  final CartRepo cartRepo;

  FetchCartUseCase(this.cartRepo);

  @override
  Future<Either<Failure, CartModel>> call([void param]) {
    return cartRepo.getCart();
  }
}

@Deprecated('Use FetchCartUseCase instead')
class FetchCartItemsUseCase extends UseCaseNoParam<List<CartItemModel>> {
  final CartRepo cartRepo;

  FetchCartItemsUseCase(this.cartRepo);

  @override
  Future<Either<Failure, List<CartItemModel>>> call([void param]) async {
    final cartResult = await cartRepo.getCart();
    return cartResult.map((cart) => cart.items);
  }
}

class AddToCartItemsUseCase extends UseCaseParam<bool, String> {
  final CartRepo cartRepo;

  AddToCartItemsUseCase(this.cartRepo);

  @override
  Future<Either<Failure, bool>> call([String? param]) {
    return cartRepo.addToCart(productId: param ?? "0");
  }
}

class DeleteFromCartItemsUseCase extends UseCaseParam<bool, String> {
  final CartRepo cartRepo;

  DeleteFromCartItemsUseCase(this.cartRepo);

  @override
  Future<Either<Failure, bool>> call([String? param]) {
    return cartRepo.removeFrom(productId: param ?? "0");
  }
}

class UpdateQuantityItemsUseCase
    extends UseCaseParam<bool, Tuple2<String, int>> {
  final CartRepo cartRepo;

  UpdateQuantityItemsUseCase(this.cartRepo);

  @override
  Future<Either<Failure, bool>> call([Tuple2<String, int>? param]) {
    if (param == null) {
      return Future.value(Left(GeneralError("Invalid parameters")));
    }
    return cartRepo.updateQuantity(
        productId: param.item1, quantity: param.item2);
  }
}
