import 'package:heraj_meem/features/categories/data/models/main_category_model.dart';
import 'package:heraj_meem/features/store/data/models/open_store_model.dart';
import '../../../../config/api_path.dart';
import '../../../../core/service/webservice/dio_helper.dart';

abstract class CategoriesDataSource {
  Future<List<CategoryModel>> getFeaturedCategories();
  Future<List<CategoryModel>> getAllCategories();
  Future<List<CategoryModel>> getCategoriesTree();
  Future<List<CategoryModel>> getAllAdminCategories();
  Future<StoreCategoryDetailsModel> getCategoryDetails(String catId);
}

class CategoriesDataSourceImpl extends CategoriesDataSource {
  final ApiService apiService;

  CategoriesDataSourceImpl(this.apiService);

  @override
  Future<List<CategoryModel>> getFeaturedCategories() async {
    final response = await apiService.get(
        url: "${ApiPath.getCategories}?level=1", returnDataOnly: true);
    final list = response["categories"] as List<dynamic>? ?? [];
    final categories = list.map((e) => CategoryModel.fromJson(e)).toList();
    return categories;
  }

  @override
  Future<List<CategoryModel>> getAllCategories() async {
    final response =
        await apiService.get(url: ApiPath.getCategories, returnDataOnly: true);
    final list = response["categories"] as List<dynamic>? ?? [];
    final categories = list.map((e) => CategoryModel.fromJson(e)).toList();
    return categories;
  }

  @override
  Future<List<CategoryModel>> getCategoriesTree() async {
    final response = await apiService.get(
        url: ApiPath.getCategoriesTree, returnDataOnly: true);
    final list = response["categories"] as List<dynamic>? ?? [];
    final categories = list.map((e) => CategoryModel.fromJson(e)).toList();
    return categories;
  }

  @override
  Future<List<CategoryModel>> getAllAdminCategories() async {
    final response = await apiService.get(
        url: ApiPath.getAdminCategories, returnDataOnly: true);
    final list = response["categories"] as List<dynamic>? ?? [];
    final categories = list.map((e) => CategoryModel.fromJson(e)).toList();
    return categories;
  }

  @override
  Future<StoreCategoryDetailsModel> getCategoryDetails(String catId) async {
    final response = await apiService.get(
      url: ApiPath.getCategoryDetails(catId),
      returnDataOnly: true,
    );
    return StoreCategoryDetailsModel.fromJson(response);
  }
}
