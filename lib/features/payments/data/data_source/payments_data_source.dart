import '../../../../config/api_path.dart';
import '../../../../core/service/webservice/dio_helper.dart';
import '../models/payment_model.dart';

abstract class PaymentsDataSource {
  Future<PaymentPaginatedModel> getMyPayments();
}

class PaymentsDataSourceImpl implements PaymentsDataSource {
  final ApiService apiService;

  PaymentsDataSourceImpl({required this.apiService});

  @override
  Future<PaymentPaginatedModel> getMyPayments() async {
    final res = await apiService.get(
      url: ApiPath.getMyPayments,
      returnDataOnly: false,
    );
    return PaymentPaginatedModel.fromJson(res);
  }
}

