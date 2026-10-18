import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tuple/tuple.dart';
import '../../../../main.dart';
import '../../domain/use_cases/cart_use_case.dart';

final quantityProvider = StateNotifierProvider.family<QuantityNotifier,
    Map<String, dynamic>, Tuple2<String,String?>>((ref, productOrCartItem) {
  return QuantityNotifier(productOrCartItem.item1,productOrCartItem.item2);
});

class QuantityNotifier extends StateNotifier<Map<String, dynamic>> {
  final String productId;
  final String? cartItem;
  bool _skipSync = false;

  QuantityNotifier(this.productId, this.cartItem) : super({'loading': false, "quantity": 0});

  Future<void> incrementQuantity() async {
    if (state['loading'] == true) return;

    final currentQuantity = state['quantity'] ?? 0;
    final updatedQuantity = currentQuantity + 1;

    _skipSync = true;
    state = {...state, 'loading': true};

     // Future.delayed(const Duration(milliseconds: 500));
    await _updateState({
      'quantity': updatedQuantity,
      'loading': false,
    });
  }

  Future<void> decrementQuantity() async {
    if (state['loading'] == true) return;

    final currentQuantity = state['quantity'] ?? 0;
    final updatedQuantity = currentQuantity - 1;

    if (updatedQuantity >= 0) {
      _skipSync = true;
      state = {...state, 'loading': true};

      await _updateState({
        'quantity': updatedQuantity,
        'loading': false,
      });
    }
  }

  void syncWithCart(int quantity) {
    if (_skipSync) return;
    _updateState({'quantity': quantity, 'loading': false},
        skipBackendUpdate: true);
  }

  Future<void> _updateState(Map<String, dynamic> newState,
      {bool skipBackendUpdate = false}) async {
    if (!mapEquals(state, newState)) {
      final int newQuantity = newState['quantity'] ?? 0;
      final int oldQuantity = state['quantity'] ?? 0;

      state = newState;

      if (!skipBackendUpdate) {
        if (newQuantity < oldQuantity) {
          if (oldQuantity == 1) {
            print("==================================");
            await getIt<DeleteFromCartItemsUseCase>().call(cartItem);
          } else {
            await getIt<UpdateQuantityItemsUseCase>()
                .call(Tuple2(cartItem??"", newQuantity));
          }
        } else if (newQuantity > oldQuantity) {
          await getIt<AddToCartItemsUseCase>().call(productId);
        }
      }

      _skipSync = false;
    }
  }
}
