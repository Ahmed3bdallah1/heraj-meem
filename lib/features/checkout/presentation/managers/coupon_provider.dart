import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:dio/dio.dart';
import '../../../../core/errors/failure.dart';
import '../../../../main.dart';
import '../../data/data_source/check_out_data_source.dart';
import '../../data/models/coupon_applied_model.dart';

final applyCouponProvider = FutureProvider.family<Either<Failure, CouponAppliedModel>, String>((ref, code) async {
  try {
    final res = await getIt<CheckOutDataSource>().applyCoupon(code: code);
    return Right(res);
  } catch (e) {
    if (e is DioException) {
      return Left(ServerFailure.fromDioError(e));
    } else {
      return Left(GeneralError(e));
    }
  }
});

final couponStateProvider = StateProvider<CouponAppliedModel?>((ref) => null);
final couponCodeProvider = StateProvider<String?>((ref) => null);

