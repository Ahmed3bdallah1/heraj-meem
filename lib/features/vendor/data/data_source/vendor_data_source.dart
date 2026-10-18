import 'package:heraj_meem/core/service/webservice/dio_helper.dart';
import 'package:heraj_meem/features/products/data/models/product_model.dart';
import 'package:heraj_meem/features/vendor/data/models/vendor_profile_model.dart';
import '../../../../config/api_path.dart';

abstract class VendorDataSource {
  Future<VendorProfileModel> getVendorProfile();
  Future<ProductPaginatedModel> getMyProducts({
    String? status,
    int page = 1,
    int limit = 20,
    String? search,
  });
}

class VendorDataSourceImpl implements VendorDataSource {
  final ApiService apiService;

  VendorDataSourceImpl({required this.apiService});

  @override
  Future<VendorProfileModel> getVendorProfile() async {
    final res = await apiService.get(url: ApiPath.getVendorProfile);
    return VendorProfileModel.fromJson(res['data']['vendor']);
  }

  @override
  Future<ProductPaginatedModel> getMyProducts({
    String? status,
    int page = 1,
    int limit = 20,
    String? search,
  }) async {
    String queryParams = "?page=$page&limit=$limit";

    if (status != null && status.isNotEmpty) {
      queryParams += "&status=$status";
    }
    if (search != null && search.isNotEmpty) {
      queryParams += "&search=$search";
    }
    final res = await apiService.get(
      url: "${ApiPath.getMyProducts}$queryParams",
    );
    return ProductPaginatedModel.fromJson(res);
  }
}

