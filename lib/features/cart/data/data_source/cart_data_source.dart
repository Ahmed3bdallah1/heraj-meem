import '../../../../config/api_path.dart';
import '../../../../core/service/webservice/dio_helper.dart';
import '../models/cart_item_model.dart';
import '../models/cart_model.dart';

abstract class CartDataSource {
  Future<bool> addToCart({required String productId});

  Future<bool> updateQuantity(
      {required String productId, required int quantity});

  Future<bool> removeFromCart({required String productId});

  Future<CartModel> getCart();
}

class CartDataSourceImp extends CartDataSource {
  final ApiService apiService;

  CartDataSourceImp(this.apiService);

  @override
  Future<bool> addToCart({required String productId}) async {
    await apiService
        .post(url: ApiPath.cartActions, requestBody: {"productId": productId});
    return true;
  }

  @override
  Future<CartModel> getCart() async {
    final res =
        await apiService.get(url: ApiPath.getCartItems, returnDataOnly: true);

    if (res is Map<String, dynamic> && res.containsKey("cart")) {
      final cartData = res["cart"];
      if (cartData is Map<String, dynamic>) {
        return CartModel.fromJson(cartData);
      }
    }
    return CartModel.fromJson(res);
  }

  @override
  Future<bool> removeFromCart({
    required String productId,
  }) async {
    await apiService.delete(url: ApiPath.deleteFromCart(productId));
    return true;
  }

  @override
  Future<bool> updateQuantity(
      {required String productId, required int quantity}) async {
    await apiService.patch(
      url: ApiPath.updateCartItem,
      requestBody: {"itemId": productId, "quantity": quantity},
    );
    return true;
  }
}
