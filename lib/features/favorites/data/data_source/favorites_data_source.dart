import 'package:heraj/features/products/data/models/product_model.dart';

import '../../../../config/api_path.dart';
import '../../../../core/service/webservice/dio_helper.dart';

abstract class FavoritesDataSource {
  Future<List<ProductModel>> getFavorites();

  Future<bool> addOrDeleteFavorites({required String productId});
}

class FavoritesDataSourceImpl implements FavoritesDataSource {
  final ApiService apiClient;

  FavoritesDataSourceImpl({required this.apiClient});

  @override
  Future<List<ProductModel>> getFavorites() async {
    final response = await apiClient.get(url: ApiPath.getFavorites, returnDataOnly: true);
    final list = response['favorites'] as List<dynamic>;
    return list.map((element) => ProductModel.fromJson(element)).toList();
  }

  @override
  Future<bool> addOrDeleteFavorites({required String productId}) async {
    await apiClient.post(
      url: ApiPath.toggleFavorite,
      requestBody: {"productId": productId},
    );
    return true;
  }
}
