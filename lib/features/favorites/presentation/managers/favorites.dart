import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heraj_meem/features/products/data/models/product_model.dart';
import '../../../../main.dart';
import '../../domain/use_case/favorites_use_case.dart';

final favoritesProvider = FutureProvider.autoDispose((ref) async {
  final favorites = await getIt<FetchFavoritesUseCase>().call();
  return favorites.fold(
    (l) => throw l,
    (r) => r,
  );
});

final isFavoritedProduct = StateProvider.family<bool, String>((ref, productId) {
  List<ProductModel>? favoritesList = ref.watch(favoritesProvider).valueOrNull;
  return favoritesList?.any((element) => element.id.toString() == productId) ??
      false;
});
