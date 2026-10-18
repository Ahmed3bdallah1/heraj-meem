import '../../../../config/api_path.dart';
import '../../../../core/service/webservice/dio_helper.dart';
import '../models/shipping_model.dart';

abstract class ShippingDataSource {
  Future<List<ShippingCompanyModel>> getShippingCompanies();
  Future<List<ShippingCompanyModel>> calculateShipping({
    required String countryCode,
    required String provinceCode,
    required double orderTotal,
    String? vendorId,
  });
}

class ShippingDataSourceImpl extends ShippingDataSource {
  final ApiService apiService;

  ShippingDataSourceImpl({required this.apiService});

  @override
  Future<List<ShippingCompanyModel>> getShippingCompanies() async {
    final res = await apiService.get<Map<String, dynamic>>(
      url: ApiPath.shippingCompanies,
      returnDataOnly: true,
    );
    
    final List<dynamic> companies = res['data'] as List? ?? [];
    
    return companies
        .map((e) => ShippingCompanyModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<ShippingCompanyModel>> calculateShipping({
    required String countryCode,
    required String provinceCode,
    required double orderTotal,
    String? vendorId,
  }) async {
    final res = await apiService.post<Map<String, dynamic>>(
      url: ApiPath.shippingCalculate,
      requestBody: {
        'countryCode': countryCode,
        'provinceCode': provinceCode,
        'orderTotal': orderTotal,
        if (vendorId != null) 'vendorId': vendorId,
      },
      returnDataOnly: true,
    );
    
    final List<dynamic> companies = res['data'] as List<dynamic>? ?? [];
    
    return companies
        .map((e) => ShippingCompanyModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

