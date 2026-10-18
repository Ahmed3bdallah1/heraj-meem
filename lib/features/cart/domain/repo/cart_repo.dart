import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../../data/models/cart_model.dart';

abstract class CartRepo {
  Future<Either<Failure, CartModel>> getCart();

  Future<Either<Failure, bool>> updateQuantity({required String productId, required int quantity});

  Future<Either<Failure, bool>> addToCart({required String productId});

  Future<Either<Failure, bool>> removeFrom({required String productId});
}
