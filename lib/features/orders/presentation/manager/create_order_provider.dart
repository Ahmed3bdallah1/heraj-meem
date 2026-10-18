import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:dio/dio.dart';
import '../../../../core/errors/failure.dart';
import '../../../../main.dart';
import '../../domain/use_case/fetch_orders_use_case.dart';

final checkoutProvider = FutureProvider.family<Either<Failure, Map<String, dynamic>>, Map<String, dynamic>>((ref, checkoutData) async {
  try {
    final res = await getIt<CheckoutUseCase>().call(checkoutData);
    return res;
  } catch (e) {
    if (e is DioException) {
      return Left(ServerFailure.fromDioError(e));
    } else {
      return Left(GeneralError(e));
    }
  }
});

