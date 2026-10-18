import 'package:fpdart/fpdart.dart';
import 'package:heraj_meem/core/errors/failure.dart';
import 'package:heraj_meem/features/categories/data/models/main_category_model.dart';
import 'package:heraj_meem/features/store/data/models/open_store_model.dart';

abstract class CategoriesRepo {
  Future<Either<Failure, List<CategoryModel>>> getFeaturedCategories();
  Future<Either<Failure, List<CategoryModel>>> getAllCategories();
  Future<Either<Failure, List<CategoryModel>>> getCategoriesTree();
  Future<Either<Failure, List<CategoryModel>>> getAdminCategoriesTree();
  Future<Either<Failure, StoreCategoryDetailsModel>> getCategoryDetails(
      String catId);
}
