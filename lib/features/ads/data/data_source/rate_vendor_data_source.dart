import '../../../../config/api_path.dart';
import '../../../../core/service/webservice/dio_helper.dart';
import '../../domain/entities/rate_vendor_request.dart';

abstract class RateVendorDataSource {
  Future<void> rateVendor(RateVendorRequest request);
}

class RateVendorDataSourceImpl implements RateVendorDataSource {
  final ApiService apiClient;

  RateVendorDataSourceImpl({required this.apiClient});

  @override
  Future<void> rateVendor(RateVendorRequest request) {
    return apiClient.post(
      url: ApiPath.createReview,
      requestBody: request.toJson(),
    );
  }
}
