import 'dart:io';
import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../../data/models/order_model.dart';

abstract class OrdersRepo {
  Future<Either<Failure,OrdersPaginatedModel>> getOrders();
  Future<Either<Failure, Map<String, dynamic>>> checkout({
    required String addressId,
    required String paymentMethod,
    String? notes,
    Map<String, dynamic>? shipping,
  });
  Future<Either<Failure, Map<String, dynamic>>> cancelOrder(String orderId);
}