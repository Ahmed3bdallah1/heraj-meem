import 'dart:io';
import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/repo/orders_repo.dart';
import '../data_source/orders_data_source.dart';
import '../models/order_model.dart';

class OrdersRepoImpl extends OrdersRepo {
  final OrdersDataSource dataSource;

  OrdersRepoImpl({required this.dataSource});

  @override
  Future<Either<Failure, OrdersPaginatedModel>> getOrders() async {
    try {
      final res = await dataSource.getOrders();
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
  Future<Either<Failure, Map<String, dynamic>>> checkout({
    required String addressId,
    required String paymentMethod,
    String? notes,
    Map<String, dynamic>? shipping,
  }) async {
    try {
      final res = await dataSource.checkout(
        addressId: addressId,
        paymentMethod: paymentMethod,
        notes: notes,
        shipping: shipping,
      );
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
  Future<Either<Failure, Map<String, dynamic>>> cancelOrder(String orderId) async {
    try {
      final res = await dataSource.cancelOrder(orderId);
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