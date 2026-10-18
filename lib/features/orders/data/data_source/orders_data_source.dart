import 'package:heraj/config/api_path.dart';
import 'package:heraj/core/service/webservice/dio_helper.dart';
import 'package:heraj/features/orders/data/models/order_model.dart';

abstract class OrdersDataSource {
  Future<OrdersPaginatedModel> getOrders();
  Future<Map<String, dynamic>> checkout({
    required String addressId,
    required String paymentMethod,
    String? notes,
    Map<String, dynamic>? shipping,
  });
  Future<Map<String, dynamic>> cancelOrder(String orderId);
}

class OrdersDataSourceImpl extends OrdersDataSource {
  final ApiService apiService;

  OrdersDataSourceImpl({required this.apiService});

  @override
  Future<OrdersPaginatedModel> getOrders() async {
    final res = await apiService.get(url: ApiPath.getOrders);
    return OrdersPaginatedModel.fromJson(res);
  }

  @override
  Future<Map<String, dynamic>> checkout({
    required String addressId,
    required String paymentMethod,
    String? notes,
    Map<String, dynamic>? shipping,
  }) async {
    final requestBody = <String, dynamic>{
      'addressId': addressId,
      'paymentMethod': paymentMethod,
    };
    
    if (notes != null && notes.isNotEmpty) {
      requestBody['notes'] = notes;
    }
    
    if (shipping != null) {
      requestBody['shipping'] = shipping;
    }
    
    final res = await apiService.post(
      url: ApiPath.checkoutOrder,
      requestBody: requestBody,
    );
    return res;
  }

  @override
  Future<Map<String, dynamic>> cancelOrder(String orderId) async {
    final res = await apiService.patch(
      url: ApiPath.cancelOrder(orderId),
      returnDataOnly: true,
    );
    return res;
  }
}
