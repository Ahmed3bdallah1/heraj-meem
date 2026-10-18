import '../../../../config/api_path.dart';
import '../../../../core/service/webservice/dio_helper.dart';
import '../models/coupon_applied_model.dart';

abstract class CheckOutDataSource {
  Future<CouponAppliedModel> applyCoupon({required String code});
}

class CheckOutDataSourceImpl extends CheckOutDataSource {
  final ApiService apiService;

  CheckOutDataSourceImpl({required this.apiService});

  @override
  Future<CouponAppliedModel> applyCoupon({required String code}) async {
    final res = await apiService.post(
      url: ApiPath.applyCoupon,
      requestBody: {'code': code},
    );
    return CouponAppliedModel.fromJson(res);
  }
}