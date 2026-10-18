import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../main.dart';
import '../../domain/use_cases/cart_use_case.dart';
import '../../data/models/cart_model.dart';

final fetchCartProvider = FutureProvider.autoDispose<CartModel>((ref) async {
  final res = await getIt<FetchCartUseCase>().call();
  return res.fold(
    (failure) => throw failure,
    (cart) => cart,
  );
});

final isInCartProductProvider =
    StateProvider.autoDispose.family<bool, String>((ref, productId) {
  final cart = ref.watch(fetchCartProvider).valueOrNull;
  return cart?.items.any((element) => element.productId == productId) ?? false;
});
