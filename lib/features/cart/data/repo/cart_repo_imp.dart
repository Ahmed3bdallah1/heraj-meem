import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/repo/cart_repo.dart';
import '../data_source/cart_data_source.dart';
import '../models/cart_model.dart';

class CartRepoImp extends CartRepo {
  final CartDataSource cartDataSource;

  CartRepoImp(this.cartDataSource);

  @override
  Future<Either<Failure, bool>> addToCart({required String productId}) async {
    try {
      final res = await cartDataSource.addToCart(productId: productId);
      return Right(res);
    } catch (e) {
      if (e is DioException) {
        return Left(ServerFailure.fromDioError(e));
      } else {
        return Left(GeneralError(e));
      }
    }
  }

  @override
  Future<Either<Failure, CartModel>> getCart() async {
    try {
      final res = await cartDataSource.getCart();
      return Right(res);
    } catch (e) {
      if (e is DioException) {
        return Left(ServerFailure.fromDioError(e));
      } else {
        return Left(GeneralError(e));
      }
    }
  }

  @override
  Future<Either<Failure, bool>> removeFrom({required String productId}) async {
    try {
      final res = await cartDataSource.removeFromCart(productId: productId);
      return Right(res);
    } catch (e) {
      if (e is DioException) {
        return Left(ServerFailure.fromDioError(e));
      } else {
        return Left(GeneralError(e));
      }
    }
  }

  @override
  Future<Either<Failure, bool>> updateQuantity({required String productId, required int quantity}) async {
    try {
      final res = await cartDataSource.updateQuantity(productId: productId, quantity: quantity);
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
